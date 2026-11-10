const {chromium}=require('../../.tools/qa/node_modules/playwright');
const sharp=require('../node_modules/sharp');
const fs=require('node:fs');
(async()=>{
 const health=await(await fetch('http://localhost:3000/api/health')).json();if(health.testEnvironment!=='local-ephemeral')throw Error('Refuse: requires backend/scripts/qa-local.js, never run against Atlas.');const browser=await chromium.launch({headless:true,executablePath:process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe'});
 const type=async(page,locator,text)=>{await locator.click();await page.waitForTimeout(150);await page.keyboard.press('Control+A');await page.keyboard.insertText(text);await page.waitForTimeout(150);}; const results=[];const shot=async(page,name)=>page.screenshot({path:`docs/screenshots/local-qa/${name}.png`,fullPage:true});
 try{
 const page=await browser.newPage({viewport:{width:1440,height:1000}});
 page.on('pageerror',e=>{throw e});page.on('response',r=>{if(r.url().includes('/api/'))console.log('API',r.status(),r.url())});
 await page.goto('http://localhost:8080');await page.waitForTimeout(2500);
 await page.locator('flt-semantics-placeholder').evaluate(e=>e.click());
 await type(page,page.getByLabel('Email Admin',{exact:true}),'admin@example.com');
 await type(page,page.getByLabel('Mật khẩu',{exact:true}),'wrong');
 await page.getByRole('button',{name:'Đăng nhập',exact:true}).click();
 await page.getByText('Email hoặc mật khẩu Admin không đúng.',{exact:true}).waitFor();results.push('login sai: PASS');
 await type(page,page.getByLabel('Mật khẩu',{exact:true}),'DemoAdmin@123');
 await page.getByRole('button',{name:'Đăng nhập',exact:true}).click();
 await page.getByRole('button',{name:'Thêm người dùng',exact:true}).waitFor();results.push('login đúng: PASS');
 await shot(page,'web-empty');
 await page.getByRole('button',{name:'Thêm người dùng',exact:true}).click();
 await type(page,page.getByLabel('Email',{exact:true}),'web.qa@example.com');
 await type(page,page.getByLabel('Mật khẩu demo',{exact:true}),'Demo123456');
 await type(page,page.getByLabel('Họ tên',{exact:true}),'Nguyễn Kiểm Thử Web');
 const fixture=await sharp({create:{width:1200,height:800,channels:3,background:'#207e75'}}).png().toBuffer();
 const chooser=page.waitForEvent('filechooser');
 await page.getByRole('button',{name:'Chọn ảnh',exact:true}).click();
 await (await chooser).setFiles({name:'qa-avatar.png',mimeType:'image/png',buffer:fixture});
 await page.getByRole('button',{name:'Lưu người dùng',exact:true}).waitFor({state:'visible'});await page.waitForTimeout(1500);
 await shot(page,'web-add-image');
 await page.getByRole('button',{name:'Lưu người dùng',exact:true}).click();
 await page.getByText('web.qa@example.com',{exact:true}).waitFor();
 const login=await (await fetch('http://localhost:3000/api/auth/login',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({email:'admin@example.com',matkhau:'DemoAdmin@123'})})).json();
 const get=async()=> (await fetch('http://localhost:3000/api/users',{headers:{Authorization:`Bearer ${login.token}`}})).json();
 let data=await get();const row=data.users.find(u=>u.email==='web.qa@example.com');
 if(!row||row.hoten!=='Nguyễn Kiểm Thử Web'||!row.hinhanh.startsWith('data:image/jpeg;base64,'))throw Error('Persist/UTF8/image failed');
 if(Object.keys(row).sort().join(',')!=='_id,email,hinhanh,hoten,matkhau')throw Error('Extra database fields');
 results.push('thêm bằng UI, UTF-8, upload/nén ảnh, đọc lại API MongoDB local và bốn trường: PASS');
 await shot(page,'web-list-image');
 await page.getByRole('button',{name:'Sửa',exact:true}).click();
 await type(page,page.getByLabel('Họ tên',{exact:true}),'Nguyễn Đã Cập Nhật');
 await page.getByRole('button',{name:'Lưu người dùng',exact:true}).click();
 await page.getByText('Nguyễn Đã Cập Nhật',{exact:true}).waitFor();
 data=await get();if(data.users[0].hoten!=='Nguyễn Đã Cập Nhật')throw Error('Update not persisted');results.push('sửa bằng UI và đọc lại API: PASS');
 await page.waitForTimeout(700);const search=page.getByRole('textbox').first();const emptyResponse=page.waitForResponse(r=>r.url().includes('/api/users?q=khongco'));await type(page,search,'khongco');const emptyData=await(await emptyResponse).json();if(emptyData.users.length!==0)throw Error('Search empty failed');await page.waitForTimeout(500);await shot(page,'web-search-debug');
 await page.waitForTimeout(1000);
 const foundResponse=page.waitForResponse(r=>r.url().includes('/api/users?q=web.qa'));await type(page,search,'web.qa');const foundData=await(await foundResponse).json();if(foundData.users.length!==1)throw Error('Search match failed');await page.waitForTimeout(500);await page.mouse.click(160,130);results.push('tìm kiếm có/không kết quả: PASS');
 await shot(page,'web-search');
 await page.getByRole('button',{name:'Xóa',exact:true}).click();
 await page.getByRole('button',{name:'Hủy',exact:true}).click();
 await page.getByText('web.qa@example.com',{exact:true}).waitFor();results.push('hủy xóa: PASS');
 await page.getByRole('button',{name:'Xóa',exact:true}).click();await shot(page,'web-delete-confirm');
 console.log('DIALOG',await page.locator('body').innerText());
 await page.getByRole('button',{name:'Xóa',exact:true}).last().click();
 await page.waitForTimeout(1000);
 data=await get();if(data.users.length!==0)throw Error('Delete not persisted');results.push('xóa bằng UI và kiểm tra DB local: PASS');
 await page.getByRole('button',{name:'Đăng xuất',exact:true}).click();await page.getByRole('button',{name:'Đăng nhập',exact:true}).waitFor();results.push('đăng xuất: PASS');
 await page.setViewportSize({width:390,height:844});await shot(page,'web-login-mobile');
 console.log(results.join('\n'));
 fs.writeFileSync('docs/test-results/web-local-qa.json',JSON.stringify({date:'2026-11-10',database:'MongoDB temporary local; NOT Atlas',browser:'Chrome headless',results},null,2));
 }finally{await browser.close()}
})().catch(e=>{console.error(e);process.exitCode=1});








