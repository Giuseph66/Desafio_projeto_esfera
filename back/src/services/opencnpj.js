/**
 * Serviço para integração com a API OpenCNPJ
 */

import axios from 'axios';
import pino from 'pino';
import { HttpError, RateLimitError, ExternalServiceError, NotFoundError } from '../utils/errors.js';
import { apenasDigitos } from '../utils/cnpj.js';

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

export class ServicoOpenCnpj {
  constructor() {
    this.urlBase = process.env.OPEN_CNPJ_BASE_URL || 'https://api.opencnpj.org';
    this.timeout = 10000; // 10 segundos
  }

  /**
   * Consulta dados de CNPJ na API OpenCNPJ
   * @param {string} cnpjBruto - CNPJ em qualquer formato (com ou sem máscara)
   * @returns {Promise<Object|null>} Dados da empresa ou null se não encontrado
   * @throws {HttpError} Para erros de API
   */
  async consultarCnpj(cnpjBruto) {
    try {
      logger.info(`Consultando CNPJ na API OpenCNPJ: ${cnpjBruto}`);

      const response = await axios.get(`${this.urlBase}/${cnpjBruto}`, {
        timeout: this.timeout,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Desafio-Esfera-Solar/1.0',
        },
      });

      logger.info(`CNPJ encontrado: ${cnpjBruto}`);
      
      // Injetar CNPJ normalizado na resposta
      const data = response.data;
      data.cnpj_normalizado = apenasDigitos(cnpjBruto).padStart(14, '0');
      
      return data;
    } catch (error) {
      if (axios.isAxiosError(error)) {
        const codigoStatus = error.response?.status || 500;
        const mensagem = error.response?.data?.message || error.message;

        logger.warn(`Erro na API OpenCNPJ para CNPJ ${cnpjBruto}:`, {
          status: codigoStatus,
          message: mensagem,
        });

        // Mapeia erros específicos da API externa
        switch (codigoStatus) {
          case 404:
            return null; // CNPJ não encontrado
          case 429:
            throw new RateLimitError('Limite de requisições excedido');
          case 500:
          case 502:
          case 503:
          case 504:
            throw new ExternalServiceError('Serviço externo indisponível. Tente novamente mais tarde');
          default:
            throw new ExternalServiceError('Falha ao consultar serviço externo');
        }
      }

      logger.error(`Erro inesperado ao consultar CNPJ ${cnpjBruto}:`, error);
      throw new ExternalServiceError('Erro interno do servidor');
    }
  }

  /**
   * Testa conectividade com a API OpenCNPJ
   * @returns {Promise<boolean>} true se a API está acessível
   */
  async testarConexao() {
    try {
      // Usa um CNPJ de teste conhecido (se existir) ou faz uma requisição simples
      await axios.get(this.urlBase, {
        timeout: 5000,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Desafio-Esfera-Solar/1.0',
        },
      });
      
      logger.info('Conexão com API OpenCNPJ testada com sucesso');
      return true;
    } catch (error) {
      logger.warn('Falha ao testar conexão com API OpenCNPJ:', error);
      return false;
    }
  }
}

// Instância singleton do serviço
export const servicoOpenCnpj = new ServicoOpenCnpj();
