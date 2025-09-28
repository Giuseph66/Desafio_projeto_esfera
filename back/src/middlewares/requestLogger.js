/**
 * Middleware para logging de requisições
 */

import pino from 'pino';

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  transport: {
    target: 'pino-pretty',
    options: {
      colorize: true,
      translateTime: 'SYS:standard',
      ignore: 'pid,hostname',
    },
  },
});

export function requestLogger(req, res, next) {
  const start = Date.now();
  const { method, url, ip } = req;
  const userAgent = req.get('User-Agent') || '';

  // Log da requisição
  logger.info('Requisição recebida', {
    method,
    url,
    ip,
    userAgent,
  });

  // Intercepta o fim da resposta
  const originalSend = res.send;
  res.send = function (body) {
    const duration = Date.now() - start;
    
    // Log da resposta
    logger.info('Resposta enviada', {
      method,
      url,
      status: res.statusCode,
      duration: `${duration}ms`,
      ip,
    });

    return originalSend.call(this, body);
  };

  next();
}
