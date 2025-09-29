/**
 * Servidor principal da aplicação
 */

import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { testarConexao } from './db.js';
import { requestLogger } from './middlewares/requestLogger.js';
import { errorHandler, notFoundHandler } from './middlewares/errorHandler.js';
import cnpjRoutes from './routes/cnpj.routes.js';
import companiesRoutes from './routes/companies.routes.js';
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

const app = express();
const PORT = process.env.PORT || 3001;

// Middlewares de parsing
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true }));

// Middleware de CORS
app.use(cors({
  origin: true, 
  //caso queria limitar o acesso a apenas alguns dominios use - origin:['http://localhost:3000', 'http://127.0.0.1:3000'],
  credentials: true,
}));

// Middleware de logging
app.use(requestLogger);

// Rota de health check
app.get('/', async (req, res) => {
  try {
    const bancoConectado = await testarConexao();
    
    res.json({
      ok: true,
      name: 'Desafio Esfera Solar API',
      timestamp: new Date().toISOString(),
      database: bancoConectado ? 'connected' : 'disconnected',
      version: process.env.npm_package_version || '1.0.0',
    });
  } catch (error) {
    logger.error('Health check failed:', error);
    res.status(503).json({
      ok: false,
      name: 'Desafio Esfera Solar API',
      timestamp: new Date().toISOString(),
      database: 'disconnected',
    });
  }
});

// Rotas da API
app.use('/cnpj', cnpjRoutes);
app.use('/companies', companiesRoutes);

// Middleware para rotas não encontradas
app.use(notFoundHandler);

// Middleware global de tratamento de erros
app.use(errorHandler);

// Inicia o servidor
async function iniciarServidor() {
  try {
    // Testa conexão com o banco
    const bancoConectado = await testarConexao();
    if (!bancoConectado) {
      logger.warn('Aviso: Banco de dados não conectado. Algumas funcionalidades podem não funcionar.');
    }

    // Inicia o servidor
    app.listen(PORT, () => {
      logger.info(`Servidor rodando na porta ${PORT}`);
      logger.info(`Health check: http://localhost:${PORT}/`);
      logger.info(`API CNPJ: http://localhost:${PORT}/cnpj/:cnpj`);
      logger.info(`API Companies: http://localhost:${PORT}/companies`);
    });
  } catch (error) {
    logger.error('Falha ao iniciar servidor:', error);
    process.exit(1);
  }
}

// Tratamento de sinais para shutdown graceful
process.on('SIGTERM', () => {
  logger.info('SIGTERM recebido, encerrando servidor...');
  process.exit(0);
});

process.on('SIGINT', () => {
  logger.info('SIGINT recebido, encerrando servidor...');
  process.exit(0);
});

// Inicia o servidor se este arquivo for executado diretamente
if (import.meta.url === `file://${process.argv[1]}`) {
  iniciarServidor();
}

export default app;
