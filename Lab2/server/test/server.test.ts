import { test } from 'node:test';
import assert from 'node:assert/strict';
import { serve } from '@hono/node-server';
import { mkdtempSync,rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { openDatabase } from '../src/database.js';
import { createApp } from '../src/app.js';
import { checkContract } from './checks.js';
test('HTTP contract against a real listening Hono server',async()=>{
 const db=openDatabase(':memory:');const app=createApp(db,'test-secret');const server=serve({fetch:app.fetch,port:0,hostname:'127.0.0.1'});
 try {if(!server.listening)await new Promise<void>(resolve=>server.once('listening',resolve));const port=(server.address() as {port:number}).port;assert((await checkContract(`http://127.0.0.1:${port}`))>50)}finally{await new Promise<void>(resolve=>server.close(()=>resolve()));db.close()}
});
test('SQLite restart preserves records and changed JWT secret rejects the old session',async()=>{
 const folder=mkdtempSync(join(tmpdir(),'runbaza-')),path=join(folder,'test.db');let db=openDatabase(path),app=createApp(db,'first-secret');
 const res=await app.request('/auth/register',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({email:'restart@example.com',password:'runbaza26',name:'Restart'})});const {token}=await res.json() as {token:string};
 const headers={Authorization:`Bearer ${token}`,'Content-Type':'application/json'};
 await app.request('/notes',{method:'POST',headers,body:JSON.stringify({title:'Persisted'})});db.close();
 db=openDatabase(path);app=createApp(db,'first-secret');assert.equal(((await (await app.request('/notes',{headers})).json()) as any).items[0].title,'Persisted');
 app=createApp(db,'second-secret');assert.equal((await app.request('/notes',{headers})).status,401);db.close();rmSync(folder,{recursive:true});
});
