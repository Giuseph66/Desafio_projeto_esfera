/// Configurações de ambiente da aplicação
/// 
/// Centraliza variáveis de configuração como URL do backend,
/// permitindo fácil alteração entre ambientes de desenvolvimento e produção
class Env {
  /// URL base do backend configurável via --dart-define
  /// Fallback para localhost:3001 em desenvolvimento
  static const String backendBase = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://localhost:3001',
  );
  
  /// Timeout padrão para requisições HTTP (30 segundos)
  static const Duration httpTimeout = Duration(seconds: 30);
}
