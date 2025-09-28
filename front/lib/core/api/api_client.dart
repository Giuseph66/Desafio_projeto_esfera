import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environment.dart';

/// Cliente HTTP centralizado para comunicação com a API
/// 
/// Encapsula todas as chamadas HTTP, tratamento de erros e conversão de dados
class ApiClient {
  final http.Client _client;
  
  ApiClient({http.Client? client}) : _client = client ?? http.Client();
  
  /// Busca dados de CNPJ na API externa
  /// 
  /// Retorna null se CNPJ não encontrado (404)
  /// Lança ApiException para outros erros
  Future<Map<String, dynamic>?> getCnpj(String cnpjRaw) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${Env.backendBase}/cnpj/$cnpjRaw'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(Env.httpTimeout);
      
      if (response.statusCode == 404) {
        return null; // CNPJ não encontrado
      }
      
      if (response.statusCode == 429) {
        throw ApiException('Muitas consultas em sequência. Tente novamente em instantes.');
      }
      
      if (response.statusCode != 200) {
        throw ApiException('Falha ao consultar CNPJ. Tente novamente.');
      }
      
      return json.decode(response.body) as Map<String, dynamic>;
    } on http.ClientException {
      throw ApiException('Verifique sua conexão e tente novamente.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Não foi possível concluir a operação. Tente novamente.');
    }
  }
  
  /// Salva empresa no banco de dados via CNPJ
  /// 
  /// Retorna dados da empresa salva
  Future<Map<String, dynamic>> saveCompanyByCnpj(String cnpjRaw) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${Env.backendBase}/companies'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'cnpj': cnpjRaw}),
          )
          .timeout(Env.httpTimeout);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      
      throw ApiException('Falha ao salvar empresa. Tente novamente.');
    } on http.ClientException {
      throw ApiException('Verifique sua conexão e tente novamente.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Não foi possível salvar a empresa. Tente novamente.');
    }
  }
  
  /// Lista empresas salvas com paginação e busca
  /// 
  /// Retorna dados paginados das empresas
  Future<Map<String, dynamic>> listCompanies({
    int page = 1,
    int pageSize = 20,
    String search = '',
  }) async {
    try {
      final uri = Uri.parse('${Env.backendBase}/companies').replace(
        queryParameters: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
          if (search.isNotEmpty) 'search': search,
        },
      );
      
      final response = await _client
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(Env.httpTimeout);
      
      if (response.statusCode != 200) {
        throw ApiException('Falha ao carregar empresas. Tente novamente.');
      }
      
      return json.decode(response.body) as Map<String, dynamic>;
    } on http.ClientException {
      throw ApiException('Verifique sua conexão e tente novamente.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Não foi possível carregar as empresas. Tente novamente.');
    }
  }
  
  void dispose() {
    _client.close();
  }
}

/// Exceção customizada para erros da API
class ApiException implements Exception {
  final String message;
  
  const ApiException(this.message);
  
  @override
  String toString() => message;
}
