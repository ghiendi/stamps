// Mariadb connection/query library for Next.js
// DBR_* for read, DBW_* for write (wire)
// Use globalThis for connection reuse


import mariadb from 'mariadb';

function get_config(prefix) {
  const env_map = {
    host: `${prefix}_HOST`,
    port: `${prefix}_PORT`,
    user: `${prefix}_USER`,
    password: `${prefix}_PASS`,
    database: `${prefix}_NAME`,
    connection_limit: `${prefix}_CONN_LIMIT`,
  };
  return {
    host: process.env[env_map.host],
    port: process.env[env_map.port] ? Number(process.env[env_map.port]) : 3306,
    user: process.env[env_map.user],
    password: process.env[env_map.password],
    database: process.env[env_map.database],
    connectionLimit: process.env[env_map.connection_limit] ? Number(process.env[env_map.connection_limit]) : 5,
  };
}

export function get_pool(prefix) {
  const key = `__mariadb_pool_${prefix}`;
  if (!globalThis[key]) {
    globalThis[key] = mariadb.createPool(get_config(prefix));
  }
  return globalThis[key];
}

export async function db_query(sql, params = [], { wire = false } = {}) {
  const pool = get_pool(wire ? 'DBW' : 'DBR');
  let conn;
  try {
    conn = await pool.getConnection();
    const res = await conn.query(sql, params);
    return res;
  } finally {
    if (conn) conn.release();
  }
}

export function db_read(sql, params = []) {
  return db_query(sql, params, { wire: false });
}

export function db_write(sql, params = []) {
  return db_query(sql, params, { wire: true });
}

export async function db_transaction(queries) {
  const pool = get_pool('DBW');
  let conn;
  try {
    conn = await pool.getConnection();
    await conn.beginTransaction();
    let results = [];
    for (const { sql, params } of queries) {
      const res = await conn.query(sql, params);
      results.push(res);
    }
    await conn.commit();
    return results;
  } catch (err) {
    if (conn) await conn.rollback();
    throw err;
  } finally {
    if (conn) conn.release();
  }
}
