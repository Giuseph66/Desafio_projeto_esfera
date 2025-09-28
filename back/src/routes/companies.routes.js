/**
 * Rotas para gerenciamento de empresas
 */

import { Router } from 'express';
import { z } from 'zod';
import { pool } from '../db.js';
import { servicoOpenCnpj } from '../services/opencnpj.js';
import { mapearOpenCnpjParaLinhaEmpresa, processarDadosEmpresa } from '../utils/mapper.js';
import { ValidationError, NotFoundError } from '../utils/errors.js';
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

// Schema para validação do corpo da requisição POST /companies
const schemaCriarEmpresa = z.object({
  cnpj: z.string().min(1, 'CNPJ é obrigatório'),
});

// Schema para validação de query parameters de listagem
const schemaListarEmpresas = z.object({
  search: z.string().optional(),
  page: z.string().regex(/^\d+$/).transform(Number).refine(n => n >= 1, 'Página deve ser >= 1').optional(),
  pageSize: z.string().regex(/^\d+$/).transform(Number).refine(n => n >= 1 && n <= 100, 'PageSize deve estar entre 1 e 100').optional(),
});

/**
 * POST /companies
 * Salva empresa no banco de dados após consultar na API OpenCNPJ
 */
router.post('/', async (req, res) => {
  const client = await pool.connect();
  
  try {
    // Validar corpo da requisição
    const dadosValidados = schemaCriarEmpresa.parse(req.body);
    const { cnpj } = dadosValidados;
    
    logger.info(`Salvando empresa com CNPJ: ${cnpj}`);

    // Consulta dados na API OpenCNPJ
    const dadosApi = await servicoOpenCnpj.consultarCnpj(cnpj);
    
    if (!dadosApi) {
      throw new NotFoundError('CNPJ não encontrado');
    }

    // Mapeia dados para formato do banco
    const dadosEmpresa = mapearOpenCnpjParaLinhaEmpresa(dadosApi);

    // Query de upsert (INSERT ... ON CONFLICT ... DO UPDATE)
    const upsertQuery = `
      INSERT INTO companies (
        cnpj, razao_social, nome_fantasia, situacao_cadastral, data_situacao_cadastral,
        matriz_filial, data_inicio_atividade, cnae_principal_code, cnaes_secundarios,
        cnaes_secundarios_count, natureza_juridica, logradouro, numero, complemento,
        bairro, cep, uf, municipio, email, telefones, capital_social, porte_empresa,
        opcao_simples, data_opcao_simples, opcao_mei, data_opcao_mei, qsa, raw
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28
      )
      ON CONFLICT (cnpj) DO UPDATE SET
        razao_social = EXCLUDED.razao_social,
        nome_fantasia = EXCLUDED.nome_fantasia,
        situacao_cadastral = EXCLUDED.situacao_cadastral,
        data_situacao_cadastral = EXCLUDED.data_situacao_cadastral,
        matriz_filial = EXCLUDED.matriz_filial,
        data_inicio_atividade = EXCLUDED.data_inicio_atividade,
        cnae_principal_code = EXCLUDED.cnae_principal_code,
        cnaes_secundarios = EXCLUDED.cnaes_secundarios,
        cnaes_secundarios_count = EXCLUDED.cnaes_secundarios_count,
        natureza_juridica = EXCLUDED.natureza_juridica,
        logradouro = EXCLUDED.logradouro,
        numero = EXCLUDED.numero,
        complemento = EXCLUDED.complemento,
        bairro = EXCLUDED.bairro,
        cep = EXCLUDED.cep,
        uf = EXCLUDED.uf,
        municipio = EXCLUDED.municipio,
        email = EXCLUDED.email,
        telefones = EXCLUDED.telefones,
        capital_social = EXCLUDED.capital_social,
        porte_empresa = EXCLUDED.porte_empresa,
        opcao_simples = EXCLUDED.opcao_simples,
        data_opcao_simples = EXCLUDED.data_opcao_simples,
        opcao_mei = EXCLUDED.opcao_mei,
        data_opcao_mei = EXCLUDED.data_opcao_mei,
        qsa = EXCLUDED.qsa,
        raw = EXCLUDED.raw,
        updated_at = NOW()
      RETURNING id, cnpj, razao_social, nome_fantasia, situacao_cadastral,
        data_situacao_cadastral, matriz_filial, data_inicio_atividade,
        cnae_principal_code, cnaes_secundarios, cnaes_secundarios_count,
        natureza_juridica, logradouro, numero, complemento, bairro,
        cep, uf, municipio, email, telefones, capital_social,
        porte_empresa, opcao_simples, data_opcao_simples, opcao_mei,
        data_opcao_mei, qsa, created_at, updated_at
    `;

    const valores = [
      dadosEmpresa.cnpj,
      dadosEmpresa.razao_social,
      dadosEmpresa.nome_fantasia,
      dadosEmpresa.situacao_cadastral,
      dadosEmpresa.data_situacao_cadastral,
      dadosEmpresa.matriz_filial,
      dadosEmpresa.data_inicio_atividade,
      dadosEmpresa.cnae_principal_code,
      dadosEmpresa.cnaes_secundarios,
      dadosEmpresa.cnaes_secundarios_count,
      dadosEmpresa.natureza_juridica,
      dadosEmpresa.logradouro,
      dadosEmpresa.numero,
      dadosEmpresa.complemento,
      dadosEmpresa.bairro,
      dadosEmpresa.cep,
      dadosEmpresa.uf,
      dadosEmpresa.municipio,
      dadosEmpresa.email,
      dadosEmpresa.telefones,
      dadosEmpresa.capital_social,
      dadosEmpresa.porte_empresa,
      dadosEmpresa.opcao_simples,
      dadosEmpresa.data_opcao_simples,
      dadosEmpresa.opcao_mei,
      dadosEmpresa.data_opcao_mei,
      dadosEmpresa.qsa,
      dadosEmpresa.raw,
    ];

    const resultado = await client.query(upsertQuery, valores);
    const empresaSalva = resultado.rows[0];

    logger.info(`Empresa salva com sucesso: ${empresaSalva.id}`);

    // Processa os dados para retornar no formato correto
    const empresaProcessada = processarDadosEmpresa(empresaSalva);
    res.status(201).json(empresaProcessada);
  } catch (error) {
    if (error instanceof z.ZodError) {
      const message = error.errors.map(e => e.message).join(', ');
      throw new ValidationError(message);
    }
    logger.error('Erro ao salvar empresa:', error);
    throw error;
  } finally {
    client.release();
  }
});

/**
 * GET /companies
 * Lista empresas com paginação e busca
 */
router.get('/', async (req, res) => {
  const client = await pool.connect();
  
  try {
    // Validar query parameters
    const dadosValidados = schemaListarEmpresas.parse(req.query);
    const { search = '', page = 1, pageSize = 20 } = dadosValidados;

    logger.info(`Listando empresas: search="${search}", page=${page}, pageSize=${pageSize}`);

    // Calcula offset para paginação
    const offset = (page - 1) * pageSize;

    // Constrói query de busca
    let clausulaWhere = '';
    let parametrosQuery = [];
    let contadorParametros = 0;

    if (search) {
      // Busca por CNPJ (dígitos) ou razão social (ILIKE)
      const digitosBusca = search.replace(/\D/g, '');
      const padraoBusca = `%${search}%`;
      
      if (digitosBusca.length > 0) {
        // Busca por CNPJ com dígitos
        clausulaWhere = `WHERE cnpj LIKE $${++contadorParametros} OR razao_social ILIKE $${++contadorParametros}`;
        parametrosQuery = [`%${digitosBusca}%`, padraoBusca];
      } else {
        // Busca apenas por razão social se não há dígitos
        clausulaWhere = `WHERE razao_social ILIKE $${++contadorParametros}`;
        parametrosQuery = [padraoBusca];
      }
    }

    // Query para contar total de registros
    const queryContagem = `SELECT COUNT(*) as total FROM companies ${clausulaWhere}`;
    const resultadoContagem = await client.query(queryContagem, parametrosQuery);
    const total = parseInt(resultadoContagem.rows[0].total);

    // Query para buscar dados paginados
    const queryDados = `
      SELECT 
        id, cnpj, razao_social, nome_fantasia, situacao_cadastral,
        data_situacao_cadastral, matriz_filial, data_inicio_atividade,
        cnae_principal_code, cnaes_secundarios, cnaes_secundarios_count,
        natureza_juridica, logradouro, numero, complemento, bairro,
        cep, uf, municipio, email, telefones, capital_social,
        porte_empresa, opcao_simples, data_opcao_simples, opcao_mei,
        data_opcao_mei, qsa, created_at, updated_at
      FROM companies 
      ${clausulaWhere}
      ORDER BY updated_at DESC
      LIMIT $${++contadorParametros} OFFSET $${++contadorParametros}
    `;

    const parametrosDados = [...parametrosQuery, pageSize, offset];
    const resultadoDados = await client.query(queryDados, parametrosDados);

    // Processa os dados de cada empresa
    const empresasProcessadas = resultadoDados.rows.map(empresa => processarDadosEmpresa(empresa));

    const resposta = {
      total,
      page,
      pageSize,
      data: empresasProcessadas,
    };

    logger.info(`Retornando ${empresasProcessadas.length} empresas de ${total} total`);

    res.json(resposta);
  } catch (error) {
    if (error instanceof z.ZodError) {
      const message = error.errors.map(e => e.message).join(', ');
      throw new ValidationError(message);
    }
    logger.error('Erro ao listar empresas:', error);
    throw error;
  } finally {
    client.release();
  }
});

export default router;
