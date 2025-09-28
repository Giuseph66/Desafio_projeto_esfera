/**
 * Rotas para consulta de CNPJ
 */

import { Router } from 'express';
import { servicoOpenCnpj } from '../services/opencnpj.js';
import pino from 'pino';

const router = Router();

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

/**
 * GET /cnpj/:cnpj
 * Consulta dados de CNPJ na API OpenCNPJ
 */
router.get('/:cnpj', async (req, res) => {
  try {
    const { cnpj } = req.params;
    
    logger.info(`Consultando CNPJ: ${cnpj}`);

    // Consulta na API OpenCNPJ
    const dados = await servicoOpenCnpj.consultarCnpj(cnpj);

    if (!dados) {
      return res.status(404).json({
        error: 'CNPJ não encontrado',
      });
    }

    // Retorna dados como vieram da API, mas com CNPJ normalizado
    res.json(dados);
  } catch (error) {
    logger.error(`Erro ao consultar CNPJ ${req.params.cnpj}:`, error);
    throw error; // Será capturado pelo errorHandler
  }
});

export default router;
