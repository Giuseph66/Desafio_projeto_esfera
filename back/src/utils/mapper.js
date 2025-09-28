/**
 * Mapeadores para conversão de dados entre APIs e banco de dados
 */

import { normalizarCnpj, normalizarCep, converterMoedaBrParaNumero, converterDataIsoParaDate } from './cnpj.js';

/**
 * Mapeia dados da API OpenCNPJ para formato do banco de dados
 * @param {Object} dadosApi - Dados retornados pela API OpenCNPJ
 * @returns {Object} Dados formatados para inserção no banco
 */
export function mapearOpenCnpjParaLinhaEmpresa(dadosApi) {
  // Normaliza CNPJ para 14 dígitos
  const cnpjNormalizado = normalizarCnpj(dadosApi.cnpj);

  return {
    cnpj: cnpjNormalizado,
    razao_social: dadosApi.razao_social || null,
    nome_fantasia: dadosApi.nome_fantasia || null,
    situacao_cadastral: dadosApi.situacao_cadastral || null,
    data_situacao_cadastral: converterDataIsoParaDate(dadosApi.data_situacao_cadastral || ''),
    matriz_filial: dadosApi.matriz_filial || null,
    data_inicio_atividade: converterDataIsoParaDate(dadosApi.data_inicio_atividade || ''),
    cnae_principal_code: dadosApi.cnae_principal || null,
    cnaes_secundarios: dadosApi.cnaes_secundarios ? JSON.stringify(dadosApi.cnaes_secundarios) : null,
    cnaes_secundarios_count: dadosApi.cnaes_secundarios_count || null,
    natureza_juridica: dadosApi.natureza_juridica || null,
    logradouro: dadosApi.logradouro || null,
    numero: dadosApi.numero || null,
    complemento: dadosApi.complemento || null,
    bairro: dadosApi.bairro || null,
    cep: normalizarCep(dadosApi.cep || ''),
    uf: dadosApi.uf || null,
    municipio: dadosApi.municipio || null,
    email: dadosApi.email || null,
    telefones: dadosApi.telefones ? JSON.stringify(dadosApi.telefones) : null,
    capital_social: converterMoedaBrParaNumero(dadosApi.capital_social || ''),
    porte_empresa: dadosApi.porte_empresa || null,
    opcao_simples: dadosApi.opcao_simples || null,
    data_opcao_simples: converterDataIsoParaDate(dadosApi.data_opcao_simples || ''),
    opcao_mei: dadosApi.opcao_mei || null,
    data_opcao_mei: converterDataIsoParaDate(dadosApi.data_opcao_mei || ''),
    qsa: dadosApi.QSA ? JSON.stringify(dadosApi.QSA) : null,
    raw: JSON.stringify(dadosApi),
  };
}

/**
 * Processa dados retornados do banco de dados para formato da API
 * @param {Object} dadosBanco - Dados retornados do banco de dados
 * @returns {Object} Dados formatados para resposta da API
 */
export function processarDadosEmpresa(dadosBanco) {
  // Função auxiliar para fazer parse seguro de JSON
  const parseJsonSafely = (jsonString) => {
    if (!jsonString || typeof jsonString !== 'string') {
      return null;
    }
    
    try {
      return JSON.parse(jsonString);
    } catch (error) {
      console.warn('Erro ao fazer parse de JSON:', jsonString, error.message);
      return null;
    }
  };

  return {
    id: dadosBanco.id,
    cnpj: dadosBanco.cnpj,
    razao_social: dadosBanco.razao_social,
    nome_fantasia: dadosBanco.nome_fantasia,
    situacao_cadastral: dadosBanco.situacao_cadastral,
    data_situacao_cadastral: dadosBanco.data_situacao_cadastral,
    matriz_filial: dadosBanco.matriz_filial,
    data_inicio_atividade: dadosBanco.data_inicio_atividade,
    cnae_principal_code: dadosBanco.cnae_principal_code,
    cnaes_secundarios: parseJsonSafely(dadosBanco.cnaes_secundarios),
    cnaes_secundarios_count: dadosBanco.cnaes_secundarios_count,
    natureza_juridica: dadosBanco.natureza_juridica,
    logradouro: dadosBanco.logradouro,
    numero: dadosBanco.numero,
    complemento: dadosBanco.complemento,
    bairro: dadosBanco.bairro,
    cep: dadosBanco.cep,
    uf: dadosBanco.uf,
    municipio: dadosBanco.municipio,
    email: dadosBanco.email,
    telefones: parseJsonSafely(dadosBanco.telefones),
    capital_social: dadosBanco.capital_social,
    porte_empresa: dadosBanco.porte_empresa,
    opcao_simples: dadosBanco.opcao_simples,
    data_opcao_simples: dadosBanco.data_opcao_simples,
    opcao_mei: dadosBanco.opcao_mei,
    data_opcao_mei: dadosBanco.data_opcao_mei,
    qsa: parseJsonSafely(dadosBanco.qsa),
    created_at: dadosBanco.created_at,
    updated_at: dadosBanco.updated_at,
  };
}
