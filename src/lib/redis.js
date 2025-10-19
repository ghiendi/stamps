import Redis from 'ioredis';

// Singleton Redis client using globalThis
function get_redis() {
  if (!globalThis._sg_redis) {
    const url = process.env.REDIS_URL;
    if (!url) throw new Error('REDIS_URL not set');
    globalThis._sg_redis = new Redis(url);
  }
  return globalThis._sg_redis;
}

export default get_redis;
