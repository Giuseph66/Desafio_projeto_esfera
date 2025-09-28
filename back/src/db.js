/**
 * Configuração e conexão com PostgreSQL
 */

import pkg from 'pg';
const { Pool } = pkg;
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

const dbConfig = {
  connectionString: process.env.DATABASE_URL,
  max: 10, // Máximo de conexões no pool
  idleTimeoutMillis: 30000, // Fecha conexões inativas após 30s
  connectionTimeoutMillis: 2000, // Timeout de conexão de 2s
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
};

export const pool = new Pool(dbConfig);

// Event listeners para monitoramento
pool.on('connect', () => {
  logger.info('Nova conexão com PostgreSQL estabelecida');
});

pool.on('error', (err) => {
  logger.error('Erro inesperado no pool de conexões PostgreSQL:', err);
});

pool.on('remove', () => {
  logger.info('Conexão PostgreSQL removida do pool');
});

/**
 * Testa a conexão com o banco de dados
 * @returns {Promise<boolean>} true se conectado com sucesso
 */
export async function testarConexao() {
  try {
    const client = await pool.connect();
    await client.query('SELECT NOW()');
    client.release();
    logger.info('Conexão com PostgreSQL testada com sucesso');
    return true;
  } catch (error) {
    logger.error('Falha ao conectar com PostgreSQL:', error);
    return false;
  }
}

/**
 * Fecha todas as conexões do pool
 */
export async function fecharPool() {
  await pool.end();
  logger.info('Pool de conexões PostgreSQL fechado');
}
