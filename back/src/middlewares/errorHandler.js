/**
 * Middleware global para tratamento de erros
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

export function errorHandler(error, req, res, next) {
  // Log do erro
  logger.error('Erro capturado pelo middleware:', {
    error: error.message,
    stack: error.stack,
    url: req.url,
    method: req.method,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
  });

  // Se é um HttpError (erro operacional)
  if (error.status) {
    res.status(error.status).json({
      error: error.message,
      status: error.status,
    });
    return;
  }

  // Se é um erro de validação do Zod
  if (error.name === 'ZodError') {
    res.status(400).json({
      error: 'Dados inválidos',
      details: error.message,
      status: 400,
    });
    return;
  }

  // Erro interno do servidor
  res.status(500).json({
    error: 'Erro interno do servidor',
    status: 500,
  });
}

/**
 * Middleware para capturar rotas não encontradas
 */
export function notFoundHandler(req, res) {
  logger.warn(`Rota não encontrada: ${req.method} ${req.url}`);
  
  res.status(404).json({
    error: 'Rota não encontrada',
    status: 404,
  });
}
