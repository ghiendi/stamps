import get_redis from './redis';
const redis = get_redis();
const NAMESPACE = process.env.REDIS_NAMESPACE || '';

/**
 * General rate limit middleware for Next.js API routes (Node.js)
 * @param {Object} opts
 * @param {number} opts.limit - Max requests per window
 * @param {number} opts.window - Window in seconds
 * @param {function} [opts.key_generator] - Function to generate key (default: by IP)
 * @returns Middleware function (req, res, next)
 */
export default function rate_limit({ limit = 60, window = 60, key_generator } = {}) {
  return async function (req, res, next) {
    try {
      const ip =
        req.headers['x-forwarded-for']?.split(',')[0]?.trim() ||
        req.connection?.remoteAddress ||
        req.socket?.remoteAddress ||
        'unknown';
      const key =
        (typeof key_generator === 'function'
          ? key_generator(req)
          : `${NAMESPACE}rl:${ip}:${req.url}`);
      const now = Math.floor(Date.now() / 1000);
      const ttl = window;
      const count = await redis.incr(key);
      if (count === 1) {
        await redis.expire(key, ttl);
      }
      if (count > limit) {
        const retry_after = await redis.ttl(key);
        res.setHeader('Retry-After', retry_after);
        res.status(429).json({
          error: 'Too many requests',
          message: `Rate limit exceeded. Try again in ${retry_after} seconds.`
        });
        return;
      }
      next();
    } catch (err) {
      // Nếu Redis lỗi, cho phép request (fail open)
      next();
    }
  };
}
