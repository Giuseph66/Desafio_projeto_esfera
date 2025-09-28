import 'package:intl/intl.dart';

/// Utilitários para manipulação de CNPJ
/// 
/// Inclui validação, formatação e limpeza de dados
class CnpjUtils {
  /// Remove todos os caracteres não numéricos de uma string
  /// 
  /// Útil para limpar CNPJ antes de enviar para API
  static String apenasDigitos(String entrada) {
    return entrada.replaceAll(RegExp(r'[^0-9]'), '');
  }
  
  /// Valida se uma string contém exatamente 14 dígitos
  /// 
  /// Verificação básica de formato antes de enviar para API
  static bool temTamanhoValidoCnpj(String cnpj) {
    final digitos = apenasDigitos(cnpj);
    return digitos.length == 14;
  }
  
  /// Valida dígitos verificadores do CNPJ
  /// 
  /// Implementa algoritmo oficial de validação de CNPJ
  static bool temDigitosVerificadoresValidos(String cnpj) {
    final digitos = apenasDigitos(cnpj);
    
    if (digitos.length != 14) return false;
    
    // Verifica se todos os dígitos são iguais (CNPJ inválido)
    if (digitos.split('').every((digito) => digito == digitos[0])) {
      return false;
    }
    
    // Calcula primeiro dígito verificador
    int soma = 0;
    int peso = 5;
    
    for (int i = 0; i < 12; i++) {
      soma += int.parse(digitos[i]) * peso;
      peso = peso == 2 ? 9 : peso - 1;
    }
    
    int primeiroDigito = soma % 11;
    primeiroDigito = primeiroDigito < 2 ? 0 : 11 - primeiroDigito;
    
    if (int.parse(digitos[12]) != primeiroDigito) return false;
    
    // Calcula segundo dígito verificador
    soma = 0;
    peso = 6;
    
    for (int i = 0; i < 13; i++) {
      soma += int.parse(digitos[i]) * peso;
      peso = peso == 2 ? 9 : peso - 1;
    }
    
    int segundoDigito = soma % 11;
    segundoDigito = segundoDigito < 2 ? 0 : 11 - segundoDigito;
    
    return int.parse(digitos[13]) == segundoDigito;
  }
  
  /// Formata CNPJ para exibição (##.###.###/####-##)
  /// 
  /// Aplica máscara de formatação para melhor legibilidade
  static String formatarCnpj(String cnpj) {
    final digitos = apenasDigitos(cnpj);
    
    if (digitos.length != 14) return cnpj;
    
    return '${digitos.substring(0, 2)}.${digitos.substring(2, 5)}.${digitos.substring(5, 8)}/${digitos.substring(8, 12)}-${digitos.substring(12, 14)}';
  }
  
  /// Valida CNPJ completo (formato + dígitos verificadores)
  /// 
  /// Combina validação de formato e dígitos verificadores
  static bool ehCnpjValido(String cnpj) {
    return temTamanhoValidoCnpj(cnpj) && temDigitosVerificadoresValidos(cnpj);
  }
  
  /// Formata data para exibição brasileira
  /// 
  /// Converte DateTime para formato dd/MM/yyyy HH:mm
  static String formatarDataHora(DateTime? dataHora) {
    if (dataHora == null) return '';
    
    final formatador = DateFormat('dd/MM/yyyy HH:mm');
    return formatador.format(dataHora);
  }
  
  /// Formata data para exibição brasileira (apenas data)
  /// 
  /// Converte DateTime para formato dd/MM/yyyy
  static String formatarData(DateTime? data) {
    if (data == null) return '';
    
    final formatador = DateFormat('dd/MM/yyyy');
    return formatador.format(data);
  }
}
