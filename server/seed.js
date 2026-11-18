const db = require('./db');
const users = [
 ['09120000001','علی','ali','🧑🏻'], ['09120000002','سارا','sara','👩🏻'],
 ['09120000003','رضا','reza','🧔🏻']
];
const addUser = db.prepare('INSERT OR IGNORE INTO users(phone,name,username,avatar,bio) VALUES(?,?,?,?,?)');
users.forEach(u => addUser.run(...u,'عضو رسا'));
const ids = db.prepare('SELECT id FROM users ORDER BY id').all().map(x=>x.id);
if (db.prepare('SELECT count(*) n FROM chats').get().n === 0) {
 const addChat = db.prepare('INSERT INTO chats(title,type,created_by) VALUES(?,?,?)');
 const member = db.prepare('INSERT INTO chat_members(chat_id,user_id,role) VALUES(?,?,?)');
 const c1=addChat.run(null,'private',ids[0]).lastInsertRowid;
 const c2=addChat.run(null,'private',ids[0]).lastInsertRowid;
 const c3=addChat.run('تیم رسا','group',ids[0]).lastInsertRowid;
 [[c1,ids[0]],[c1,ids[1]],[c2,ids[0]],[c2,ids[2]],[c3,ids[0]],[c3,ids[1]],[c3,ids[2]]].forEach(([c,u])=>member.run(c,u,'member'));
 const msg=db.prepare('INSERT INTO messages(chat_id,sender_id,body,type) VALUES(?,?,?,?)');
 msg.run(c1,ids[1],'سلام! به رسا خوش اومدی 🌱','text');
 msg.run(c2,ids[2],'همه‌چی آماده‌ست؟','text');
 msg.run(c3,ids[0],'به گروه تیم رسا خوش آمدید!','text');
}
console.log('داده‌های نمونه آماده شد.');
