import assert from 'node:assert/strict';
export async function checkContract(base:string, log=(message:string)=>console.log(message)) {
  let count=0;const ok=(label:string)=>{count++;log(`PASS ${String(count).padStart(2,'0')} ${label}`)};
  async function req(path:string,method='GET',body?:unknown,token?:string) {
    const res=await fetch(base+path,{method,headers:{...(body?{'Content-Type':'application/json'}:{}),...(token?{Authorization:`Bearer ${token}`}:{})},body:body?JSON.stringify(body):undefined});
    return {status:res.status,data:res.status===204?null:await res.json() as any};
  }
  assert.deepEqual((await req('/health')).data,{status:'ok'});ok('health');
  assert.equal((await req('/notes')).status,401);ok('private endpoint requires token');
  assert.equal((await req('/auth/register','POST',{email:'invalid'})).status,400);ok('registration validation');
  const email=`check-${crypto.randomUUID()}@example.com`,password='runbaza26',name='API Check';
  const reg=await req('/auth/register','POST',{email,password,name});assert.equal(reg.status,201);assert.equal(typeof reg.data.token,'string');ok('registration and JWT');
  const token=reg.data.token as string;
  assert.equal((await req('/auth/register','POST',{email,password,name})).status,409);ok('duplicate email');
  assert.equal((await req('/auth/login','POST',{email,password:'wrong'})).status,401);ok('wrong password');
  assert.equal((await req('/auth/login','POST',{email,password})).status,200);ok('login');
  const other=await req('/auth/register','POST',{email:`other-${email}`,password,name});const tokenB=other.data.token;
  const races=await req('/races?limit=20','GET',undefined,token);assert.equal(races.data.items.length,20);assert(races.data.total>20);ok('server page one');
  const page2=await req('/races?page=2&limit=20','GET',undefined,token);assert(page2.data.items.length>0);assert(!races.data.items.some((a:any)=>page2.data.items.some((b:any)=>a.id===b.id)));ok('non-overlapping page two');
  assert.equal((await req('/races?page=0','GET',undefined,token)).status,400);ok('invalid pagination');
  const searched=await req('/races?search='+encodeURIComponent('Chișinău'),'GET',undefined,token);assert(searched.data.items.length>0);assert(searched.data.items.every((r:any)=>r.city==='Chișinău'));ok('Unicode search on server');
  const filtered=await req('/races?country=romania','GET',undefined,token);assert(filtered.data.items.every((r:any)=>r.country==='romania'));ok('country filter on server');
  const race=races.data.items[0],{id:oldId,...raceDraft}=race;
  const drafts:Record<string,any>={notes:{title:'Покупки',content:'вода'},races:{...raceDraft,title:'Private race'},plans:{raceId:race.id,reminderDays:2,distance:race.distances[0],pace:'6:00',visibility:'private'},offers:{raceId:race.id,driverName:'Oleg',departureTime:'07:00',pickupPoint:'Circ',freeSeats:3,contribution:80,departureCity:'Chișinău',phone:'+37369123456'},requests:{raceId:race.id,passengerName:'Nichita',seats:1,pickupPoint:'Circ',departureCity:'Chișinău',departureTime:'07:00',phone:'+37369123456'}};
  for(const [resource,draft] of Object.entries(drafts)) {
    const created=await req(`/${resource}`,'POST',{id:'client-forged',...draft},token);assert.equal(created.status,201,JSON.stringify(created));assert.notEqual(created.data.id,'client-forged');ok(`${resource} create, server-generated ID`);
    const id=created.data.id;
    assert.equal((await req(`/${resource}/${id}`,'GET',undefined,token)).status,200);ok(`${resource} get by ID`);
    assert.equal((await req(`/${resource}/${id}`,'GET',undefined,tokenB)).status,404);ok(`${resource} cross-user privacy`);
    assert.equal((await req(`/${resource}/${id}`,'PUT',draft,tokenB)).status,404);ok(`${resource} cross-user update rejected`);
    assert.equal((await req(`/${resource}/${id}`,'PUT',draft,token)).status,200);ok(`${resource} update`);
    assert.equal((await req(`/${resource}/${id}`,'DELETE',undefined,token)).status,204);ok(`${resource} delete`);
    assert.equal((await req(`/${resource}/${id}`,'GET',undefined,token)).status,404);ok(`${resource} deleted record`);
  }
  const profiles=await req('/profiles','GET',undefined,token);assert.equal(profiles.data.items.length,1);ok('profile created with account');
  const profile=profiles.data.items[0];assert.equal((await req(`/profiles/${profile.id}`,'PUT',{...profile,bio:'Runner'},token)).status,200);ok('profile update');
  assert.equal((await req(`/profiles/${profile.id}`,'GET',undefined,tokenB)).status,404);ok('profile privacy');
  assert.equal((await req('/plans','POST',{...drafts.plans,raceId:'missing'},token)).status,400);ok('foreign key validation');
  const plan=await req('/plans','POST',drafts.plans,token);
  assert.equal((await req('/plans','POST',drafts.plans,token)).status,409);ok('duplicate participation prevented');
  await req(`/plans/${plan.data.id}`,'DELETE',undefined,token);
  const form=new FormData();form.append('file',new File(['hello'],'test.txt',{type:'text/plain'}));
  const uploaded=await fetch(base+'/files',{method:'POST',headers:{Authorization:`Bearer ${token}`},body:form});assert.equal(uploaded.status,201);const file=await uploaded.json() as any;ok('multipart upload');
  const downloaded=await fetch(base+file.url,{headers:{Authorization:`Bearer ${token}`}});assert.equal(await downloaded.text(),'hello');assert.match(downloaded.headers.get('Content-Disposition')!,/^attachment/);ok('file bytes and safe download headers');
  assert.equal((await fetch(base+file.url,{headers:{Authorization:`Bearer ${tokenB}`}})).status,404);ok('file privacy');
  const large=new FormData();large.append('file',new File([new Uint8Array(5*1024*1024+1)],'big.bin'));
  assert.equal((await fetch(base+'/files',{method:'POST',headers:{Authorization:`Bearer ${token}`},body:large})).status,400);ok('upload size limit');
  const malformed=await fetch(base+'/notes',{method:'POST',headers:{Authorization:`Bearer ${token}`,'Content-Type':'application/json'},body:'{broken'});assert.equal(malformed.status,400);ok('malformed JSON envelope');
  assert.equal((await req('/notes','GET',undefined,token+'x')).status,401);ok('bad token signature');
  log(`PASS ${count}/${count} RunBaza project checks (not the course kit suite)`);return count;
}
