import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/company.dart';
import '../../../core/utils/cnpj.dart';
import '../../../core/widgets/app_error.dart';
import '../../../core/widgets/app_loading.dart';
import '../widgets/cnpj_input.dart';
import '../widgets/result_card.dart';

/// Página principal para consulta de CNPJ
/// 
/// Permite buscar dados de CNPJ e salvar no banco de dados
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _formKey = GlobalKey<FormState>();
  final _cnpjController = TextEditingController();
  final _apiClient = ApiClient();
  
  Company? _searchResult;
  bool _isSearching = false;
  bool _isSaving = false;
  String? _errorMessage;
  
  @override
  void dispose() {
    _cnpjController.dispose();
    _apiClient.dispose();
    super.dispose();
  }
  
  /// Busca dados do CNPJ na API
  Future<void> _buscarCnpj() async {
    if (!_formKey.currentState!.validate()) return;
    
    final digitosCnpj = CnpjUtils.apenasDigitos(_cnpjController.text);
    
    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _searchResult = null;
    });
    
    try {
      final data = await _apiClient.getCnpj(digitosCnpj);
      
      if (data == null) {
        setState(() {
          _errorMessage = 'CNPJ não encontrado.';
        });
      } else {
        setState(() {
          _searchResult = Company.fromCnpjData(data);
        });
      }
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro inesperado. Tente novamente.';
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }
  
  /// Salva empresa no banco de dados
  Future<void> _salvarEmpresa() async {
    if (_searchResult == null) return;
    
    final digitosCnpj = CnpjUtils.apenasDigitos(_searchResult!.cnpj);
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      await _apiClient.saveCompanyByCnpj(digitosCnpj);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Empresa salva com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar empresa. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
  
  /// Limpa o formulário e resultados
  void _limparFormulario() {
    _cnpjController.clear();
    setState(() {
      _searchResult = null;
      _errorMessage = null;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta CNPJ'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/companies');
            },
            icon: const Icon(Icons.list),
            label: const Text('Ver Salvos'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título da seção
              Text(
                'Desafio Esfera Solar',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Consulte dados de CNPJ e salve no banco de dados',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Campo de entrada CNPJ e botões na mesma linha
              Row(
                children: [
                  // Campo de entrada CNPJ
                  Expanded(
                    child: CnpjInput(
                      controller: _cnpjController,
                      enabled: !_isSearching,
                      autofocus: true,
                      onSubmitted: _buscarCnpj,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Botão Buscar
                  FilledButton.icon(
                    onPressed: _isSearching ? null : _buscarCnpj,
                    icon: _isSearching
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(_isSearching ? 'Buscando...' : 'Buscar'),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Botão Limpar
                  OutlinedButton.icon(
                    onPressed: _isSearching ? null : _limparFormulario,
                    icon: const Icon(Icons.clear),
                    label: const Text('Limpar'),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Conteúdo baseado no estado
              if (_isSearching)
                const AppLoading(message: 'Consultando CNPJ...')
              else if (_errorMessage != null)
                AppError(
                  message: _errorMessage!,
                  onRetry: _buscarCnpj,
                )
              else if (_searchResult != null)
                ResultCard(
                  company: _searchResult!,
                  onSave: _salvarEmpresa,
                  isSaving: _isSaving,
                )
              else
                _construirEstadoVazio(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _construirEstadoVazio() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Digite um CNPJ para consultar',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Informe o CNPJ no campo acima e clique em "Buscar" para consultar os dados da empresa.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
