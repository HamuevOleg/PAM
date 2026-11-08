import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { bodyLimit } from 'hono/body-limit';
import { sign, verify } from 'hono/jwt';
import { randomBytes, scrypt as scryptCallback, timingSafeEqual, randomUUID } from 'node:crypto';
import { promisify } from 'node:util';
import { DatabaseSync } from 'node:sqlite';
import { z } from 'zod';
import { schemas, registration, credentials, type Resource } from './schema.js';
import { searchText } from './database.js';
const scrypt = promisify(scryptCallback);
type Row = {id:string;user_id:number;data:string};
class ApiError extends Error {constructor(public status:400|401|404|409,public code:string,message:string){super(message)}}
const missing=()=>new ApiError(404,'NOT_FOUND','Record not found');
const invalid=(message='Invalid request')=>new ApiError(400,'VALIDATION_ERROR',message);
export function createApp(db:DatabaseSync, secret:string) {
  const app=new Hono<{Variables:{userId:number}}>();
  app.use('*',cors());
  app.use('*',bodyLimit({maxSize:6*1024*1024,onError:c=>c.json({error:{code:'VALIDATION_ERROR',message:'Request too large'}},400)}));
  app.onError((e,c)=>{
    if(e instanceof ApiError)return c.json({error:{code:e.code,message:e.message}},e.status);
    if(e instanceof z.ZodError||e instanceof SyntaxError)return c.json({error:{code:'VALIDATION_ERROR',message:'Invalid request fields'}},400);
    console.error(e.name,e.message);
    return c.json({error:{code:'INTERNAL_ERROR',message:'Server error'}},500);
  });
  app.notFound(c=>c.json({error:{code:'NOT_FOUND',message:'Route not found'}},404));
  app.get('/health',c=>c.json({status:'ok'}));
  const tokenFor=(id:number)=>sign({sub:String(id),iat:Math.floor(Date.now()/1000),exp:Math.floor(Date.now()/1000)+86400},secret,'HS256');
  app.post('/auth/register',async c=>{
    const {email,password,name}=registration.parse(await c.req.json());
    if(db.prepare('SELECT id FROM users WHERE email=?').get(email))throw new ApiError(409,'EMAIL_TAKEN','Email already registered');
    const salt=randomBytes(16).toString('hex');
    const hash=(await scrypt(password,salt,64) as Buffer).toString('hex');
    // Recheck after the asynchronous hash before the synchronous transaction.
    if(db.prepare('SELECT id FROM users WHERE email=?').get(email))throw new ApiError(409,'EMAIL_TAKEN','Email already registered');
    db.exec('BEGIN');
    let id:number;
    try {
      id=Number(db.prepare('INSERT INTO users(email,name,password_hash) VALUES(?,?,?)').run(email,name,`${salt}:${hash}`).lastInsertRowid);
      const profile={name,email,city:'Chișinău',pace:'6:00',bio:'',preferredDistance:10,seasonGoal:8,avatar:0,appearance:'system',publicPlan:false};
      db.prepare('INSERT INTO profiles(id,user_id,data,search_text) VALUES(?,?,?,?)').run(randomUUID(),id,JSON.stringify(profile),searchText(profile));
      db.exec('COMMIT');
    }catch(e){db.exec('ROLLBACK');throw e;}
    return c.json({token:await tokenFor(id),user:{id,email,name}},201);
  });
  app.post('/auth/login',async c=>{
    const {email,password}=credentials.parse(await c.req.json());
    const user=db.prepare('SELECT * FROM users WHERE email=?').get(email) as {id:number;name:string;password_hash:string}|undefined;
    const [salt,hash]=(user?.password_hash??`${'0'.repeat(32)}:${'0'.repeat(128)}`).split(':');
    const actual=await scrypt(password,salt,64) as Buffer;
    if(!user||!timingSafeEqual(actual,Buffer.from(hash,'hex')))throw new ApiError(401,'UNAUTHORIZED','Invalid email or password');
    return c.json({token:await tokenFor(user.id),user:{id:user.id,email,name:user.name}});
  });
  app.use('*',async(c,next)=>{
    const bearer=c.req.header('Authorization');
    if(!bearer?.startsWith('Bearer '))throw new ApiError(401,'UNAUTHORIZED','Authentication required');
    let payload;
    try{payload=await verify(bearer.slice(7),secret,'HS256');}catch{throw new ApiError(401,'UNAUTHORIZED','Invalid or expired token');}
    const userId=Number(payload.sub);
    if(!Number.isSafeInteger(userId)||!db.prepare('SELECT id FROM users WHERE id=?').get(userId))throw new ApiError(401,'UNAUTHORIZED','User not found');
    c.set('userId',userId);await next();
  });
  for(const resource of Object.keys(schemas) as Resource[]) {
    const access=resource==='races'?'(user_id=? OR user_id IS NULL)':'user_id=?';
    const view=(row:Row)=>({id:row.id,...JSON.parse(row.data)});
    app.get(`/${resource}`,c=>{
      const integer=(raw:string|undefined,fallback:number,max:number)=>{if(raw===undefined)return fallback;if(!/^\d+$/.test(raw))throw invalid();const n=Number(raw);if(n<1||n>max)throw invalid();return n;};
      const page=integer(c.req.query('page'),1,100000),limit=integer(c.req.query('limit'),20,100);
      const search=(c.req.query('search')??'').toLocaleLowerCase();if(search.length>200)throw invalid();
      const country=c.req.query('country');if(country&&!['moldova','romania'].includes(country))throw invalid();
      const where=`${access} AND instr(search_text,?)>0${resource==='races'&&country?' AND json_extract(data,\'$.country\')=?':''}`;
      const args:(string|number)[]=[c.get('userId'),search];if(resource==='races'&&country)args.push(country);
      const total=Number(db.prepare(`SELECT count(*) AS total FROM ${resource} WHERE ${where}`).get(...args)!.total);
      const items=(db.prepare(`SELECT * FROM ${resource} WHERE ${where} ORDER BY rowid LIMIT ? OFFSET ?`).all(...args,limit,(page-1)*limit) as Row[]).map(view);
      return c.json({items,page,limit,total});
    });
    app.get(`/${resource}/:id`,c=>{
      const row=db.prepare(`SELECT * FROM ${resource} WHERE id=? AND ${access}`).get(c.req.param('id'),c.get('userId')) as Row|undefined;
      if(!row)throw missing();return c.json(view(row));
    });
    const validate=(input:unknown,userId:number)=>{
      const data=schemas[resource].parse(input) as Record<string,unknown>;
      if(typeof data.raceId==='string') {
        const race=db.prepare('SELECT data FROM races WHERE id=? AND (user_id=? OR user_id IS NULL)').get(data.raceId,userId);
        if(!race)throw invalid('Unknown race');
        if(resource==='plans'&&data.distance!==null&&!(JSON.parse(String(race.data)).distances as number[]).includes(Number(data.distance)))throw invalid('Distance not offered by race');
      }
      if(resource==='profiles') {
        const user=db.prepare('SELECT email FROM users WHERE id=?').get(userId)!;
        if(data.email!==user.email)throw invalid('Account email cannot be changed in profile');
      }
      return data;
    };
    app.post(`/${resource}`,async c=>{
      const uid=c.get('userId'),data=validate(await c.req.json(),uid),id=randomUUID();
      if(resource==='profiles')throw new ApiError(409,'CONFLICT','Profile already exists');
      if(resource==='plans'&&db.prepare('SELECT id FROM plans WHERE user_id=? AND race_id=?').get(uid,String(data.raceId)))throw new ApiError(409,'CONFLICT','Race already in plan');
      db.prepare(`INSERT INTO ${resource}(id,user_id,race_id,data,search_text) VALUES(?,?,?,?,?)`).run(id,uid,typeof data.raceId==='string'?data.raceId:null,JSON.stringify(data),searchText(data));
      return c.json({id,...data},201);
    });
    app.put(`/${resource}/:id`,async c=>{
      const id=c.req.param('id'),uid=c.get('userId');
      if(!db.prepare(`SELECT id FROM ${resource} WHERE id=? AND user_id=?`).get(id,uid))throw missing();
      const data=validate(await c.req.json(),uid);
      if(resource==='plans'&&db.prepare('SELECT id FROM plans WHERE user_id=? AND race_id=? AND id<>?').get(uid,String(data.raceId),id))throw new ApiError(409,'CONFLICT','Race already in plan');
      db.prepare(`UPDATE ${resource} SET race_id=?,data=?,search_text=? WHERE id=? AND user_id=?`).run(typeof data.raceId==='string'?data.raceId:null,JSON.stringify(data),searchText(data),id,uid);
      return c.json({id,...data});
    });
    app.delete(`/${resource}/:id`,c=>{
      const id=c.req.param('id'),uid=c.get('userId');
      if(!db.prepare(`SELECT id FROM ${resource} WHERE id=? AND user_id=?`).get(id,uid))throw missing();
      if(resource==='races'&&['plans','offers','requests'].some(table=>db.prepare(`SELECT id FROM ${table} WHERE race_id=?`).get(id)))throw new ApiError(409,'CONFLICT','Race has related records');
      db.prepare(`DELETE FROM ${resource} WHERE id=? AND user_id=?`).run(id,uid);return c.body(null,204);
    });
  }
  app.post('/files',async c=>{
    let form:FormData;try{form=await c.req.raw.formData();}catch{throw invalid('Invalid multipart body');}
    const file=form.get('file');if(!(file instanceof File)||file.size>5*1024*1024||file.size===0)throw invalid('Expected a file of 1 byte to 5 MB');
    const name=file.name.replace(/[^\p{L}\p{N} ._-]/gu,'_').slice(0,150)||'file';
    const id=Number(db.prepare('INSERT INTO files(user_id,name,type,bytes) VALUES(?,?,?,?)').run(c.get('userId'),name,file.type||'application/octet-stream',Buffer.from(await file.arrayBuffer())).lastInsertRowid);
    return c.json({id,name,size:file.size,type:file.type,url:`/files/${id}`},201);
  });
  app.get('/files/:id',c=>{
    const file=db.prepare('SELECT * FROM files WHERE id=? AND user_id=?').get(c.req.param('id'),c.get('userId'));
    if(!file)throw missing();
    c.header('Content-Type',String(file.type));c.header('Content-Disposition',`attachment; filename*=UTF-8''${encodeURIComponent(String(file.name))}`);c.header('Content-Security-Policy',"default-src 'none'; sandbox");c.header('X-Content-Type-Options','nosniff');
    return c.body(new Uint8Array(file.bytes as Uint8Array));
  });
  return app;
}
