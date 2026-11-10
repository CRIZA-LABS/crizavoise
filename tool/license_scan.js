const fs=require('fs'),path=require('path');
const lines=fs.readFileSync('pubspec.lock','utf8').split(/\r?\n/);
const cache=path.join(process.env.LOCALAPPDATA,'Pub','Cache','hosted','pub.dev');
const pk=[];let cur=null;
for(const l of lines){let m;
 if((m=/^  ([a-z0-9_]+):$/.exec(l))){cur={name:m[1]};pk.push(cur);continue;}
 if(!cur)continue;
 if((m=/^    dependency: "?([^"]+)"?$/.exec(l)))cur.dep=m[1];
 if((m=/^    source: (\w+)$/.exec(l)))cur.source=m[1];
 if((m=/^    version: "([^"]+)"$/.exec(l)))cur.ver=m[1];
}
const classify=t=>/Syncfusion/i.test(t)?'SYNCFUSION-COMMERCIAL':/Apache License/i.test(t)?'Apache-2.0':/Permission is hereby granted, free of charge/i.test(t)?'MIT':/Redistribution and use in source and binary forms/i.test(t)?'BSD':/Mozilla Public License/i.test(t)?'MPL-2.0':/LESSER GENERAL/i.test(t)?'LGPL':/GENERAL PUBLIC LICENSE/i.test(t)?'GPL':/zlib/i.test(t)?'Zlib':'OTHER';
const counts={};const attn=[];
for(const p of pk){ if(p.source!=='hosted'){p.lic='sdk';} else {
  const dir=path.join(cache,`${p.name}-${p.ver}`);p.lic='MISSING';
  for(const f of ['LICENSE','LICENSE.md','LICENSE.txt','COPYING']){const fp=path.join(dir,f);if(fs.existsSync(fp)){p.lic=classify(fs.readFileSync(fp,'utf8'));break}}}
 counts[p.lic]=(counts[p.lic]||0)+1;
 if(!['MIT','BSD','Apache-2.0','sdk'].includes(p.lic))attn.push(`${p.name} ${p.ver} [${p.dep}] -> ${p.lic}`);
}
console.log('packages:',pk.length,JSON.stringify(counts));console.log(attn.join('\n'));
fs.writeFileSync(path.join(process.env.TMP || '.','licenses.json'),JSON.stringify(pk,null,1));
