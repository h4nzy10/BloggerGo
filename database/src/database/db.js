import mysql from 'mysql2/promise';

const pool = mysql.createPool({
  host                : 'localhost',
  user                : 'root',
  database            : 'blog_app_db',
  waitForConnections  : true
});

export default pool;