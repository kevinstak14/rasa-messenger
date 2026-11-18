const fs = require('fs');
const path = require('path');
const Database = require('better-sqlite3');
const db = new Database(path.join(__dirname, 'rasa.sqlite'));
db.pragma('journal_mode = WAL');
db.exec(fs.readFileSync(path.join(__dirname, 'schema.sql'), 'utf8'));
module.exports = db;
