/**
 * Utilitários para manipulação de CNPJ
 */

/**
 * Remove todos os caracteres não numéricos de uma string
 * @param {string} str - String de entrada
 * @returns {string} String com apenas dígitos
 */
export function apenasDigitos(str) {
  if (!str || typeof str !== 'string') return '';
  return str.replace(/\D/g, '');
}

/**
 * Normaliza CNPJ removendo caracteres não numéricos e validando tamanho
 * @param {string} cnpj - CNPJ em qualquer formato
 * @returns {string} CNPJ com 14 dígitos
 * @throws {Error} Se CNPJ for inválido
 */
export function normalizarCnpj(cnpj) {
  if (!cnpj || typeof cnpj !== 'string') {
    throw new Error('CNPJ deve ser uma string válida');
  }

  const digitos = apenasDigitos(cnpj);

  if (digitos.length !== 14) {
    throw new Error('CNPJ inválido: deve ter exatamente 14 dígitos');
  }

  return digitos;
}

/**
 * Normaliza CEP removendo caracteres não numéricos
 * @param {string} cep - CEP em qualquer formato
 * @returns {string|null} CEP com 8 dígitos ou null se inválido
 */
export function normalizarCep(cep) {
  if (!cep || typeof cep !== 'string') return null;
  
  const digitos = apenasDigitos(cep);
  return digitos.length === 8 ? digitos : null;
}

/**
 * Converte string de moeda brasileira para número
 * @param {string} valor - String no formato "1.234,56"
 * @returns {number|null} Número no formato 1234.56 ou null se inválido
 */
export function converterMoedaBrParaNumero(valor) {
  if (!valor || typeof valor !== 'string') return null;

  // Remove pontos de milhares e substitui vírgula por ponto
  const limpo = valor.replace(/\./g, '').replace(',', '.');
  const parseado = parseFloat(limpo);

  return isNaN(parseado) ? null : parseado;
}

/**
 * Converte string de data ISO para Date
 * @param {string} stringData - String no formato YYYY-MM-DD
 * @returns {Date|null} Date ou null se inválido
 */
export function converterDataIsoParaDate(stringData) {
  if (!stringData || typeof stringData !== 'string') return null;

  const data = new Date(stringData);
  return isNaN(data.getTime()) ? null : data;
}
