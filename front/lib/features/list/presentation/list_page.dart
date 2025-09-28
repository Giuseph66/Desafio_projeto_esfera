import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/company.dart';
import '../../../core/utils/cnpj.dart';
import '../../../core/widgets/app_error.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_empty.dart';
import '../widgets/company_list_item.dart';

/// Página para listagem de empresas salvas
/// 
/// Exibe empresas com busca, paginação e responsividade
class ListPage extends StatefulWidget {
  const ListPage({super.key});
  
  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final _apiClient = ApiClient();
  final _searchController = TextEditingController();
  
  List<Company> _companies = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  int _pageSize = 20;
  
  Timer? _searchTimer;
  
  @override
  void initState() {
    super.initState();
    _carregarEmpresas();
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    _apiClient.dispose();
    super.dispose();
  }
  
  /// Listener para mudanças no campo de busca com debounce
  void _onSearchChanged() {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      _executarBusca();
    });
  }

  /// Carrega lista de empresas
  Future<void> _carregarEmpresas({bool resetarPagina = false}) async {
    if (resetarPagina) {
      _currentPage = 1;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final response = await _apiClient.listCompanies(
        page: _currentPage,
        pageSize: _pageSize,
        search: _searchController.text.trim(),
      );
      
      final companyListResponse = CompanyListResponse.fromJson(response);
      
      setState(() {
        _companies = companyListResponse.data;
        _totalItems = companyListResponse.total;
        _totalPages = (_totalItems / _pageSize).ceil();
        if (_totalPages == 0) _totalPages = 1;
      });
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
        _isLoading = false;
      });
    }
  }
  
  /// Executa busca
  void _executarBusca() {
    _carregarEmpresas(resetarPagina: true);
  }
  
  /// Limpa busca
  void _limparBusca() {
    _searchController.clear();
    _carregarEmpresas(resetarPagina: true);
  }
  
  /// Vai para página específica
  void _irParaPagina(int pagina) {
    if (pagina >= 1 && pagina <= _totalPages && pagina != _currentPage) {
      setState(() {
        _currentPage = pagina;
      });
      _carregarEmpresas();
    }
  }
  
  /// Altera tamanho da página
  void _alterarTamanhoPagina(int novoTamanho) {
    setState(() {
      _pageSize = novoTamanho;
      _currentPage = 1;
    });
    _carregarEmpresas();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empresas Salvas'),
        actions: [
          IconButton(
            onPressed: _carregarEmpresas,
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de busca
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar por CNPJ ou Razão Social',
                      hintText: 'Digite para buscar...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE5E7EB), // outline
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE5E7EB), // outline
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF2240FE), // primary
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _executarBusca(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _executarBusca,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _limparBusca,
                  icon: const Icon(Icons.clear),
                  label: const Text('Limpar'),
                ),
              ],
            ),
          ),
          
          // Controles de paginação (topo)
          if (_totalItems > 0) _construirControlesPaginacao(true),
          
          // Conteúdo principal
          Expanded(
            child: _construirConteudo(),
          ),
          
          // Controles de paginação (rodapé)
          if (_totalItems > 0) _construirControlesPaginacao(false),
        ],
      ),
    );
  }
  
  Widget _construirConteudo() {
    if (_isLoading) {
      return const AppLoading(message: 'Carregando empresas...');
    }
    
    if (_errorMessage != null) {
      return AppError(
        message: _errorMessage!,
        onRetry: _carregarEmpresas,
      );
    }
    
    if (_companies.isEmpty) {
      return AppEmpty(
        message: _searchController.text.isNotEmpty
            ? 'Nenhuma empresa encontrada para "${_searchController.text}"'
            : 'Nenhuma empresa salva ainda',
        icon: _searchController.text.isNotEmpty ? Icons.search_off : Icons.inbox,
        onAction: _searchController.text.isNotEmpty ? _limparBusca : null,
        actionLabel: _searchController.text.isNotEmpty ? 'Limpar Busca' : null,
      );
    }
    
    // Lista responsiva
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Layout mobile - cartões
          return ListView.builder(
            itemCount: _companies.length,
            itemBuilder: (context, index) {
              return CompanyCardItem(
                company: _companies[index],
                onTap: () => _mostrarDetalhesEmpresa(_companies[index]),
              );
            },
          );
        } else {
          // Layout desktop - tabela com scroll horizontal
          return Column(
            children: [
              // Tabela com scroll e barra de rolagem
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Scrollbar(
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: 8,
                      radius: const Radius.circular(4),
                      child: DataTable(
                        columnSpacing: 20,
                        horizontalMargin: 16,
                        columns: const [
                          DataColumn(label: Text('Razão Social')),
                          DataColumn(label: Text('CNPJ')),
                          DataColumn(label: Text('Situação')),
                          DataColumn(label: Text('CNAE Principal')),
                          DataColumn(label: Text('Natureza Jurídica')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Capital Social')),
                          DataColumn(label: Text('Atualizado em')),
                        ],
                        rows: _companies.map((company) {
                          return DataRow(
                            cells: [
                              DataCell(
                                InkWell(
                                  onTap: () => _mostrarDetalhesEmpresa(company),
                                  child: Text(
                                    company.razaoSocial,
                                  ),
                                ),
                              ),
                              DataCell(
                                InkWell(
                                  onTap: () => _mostrarDetalhesEmpresa(company),
                                  child: Text(CnpjUtils.formatarCnpj(company.cnpj)),
                                ),
                              ),
                              DataCell(
                                InkWell(
                                  onTap: () => _mostrarDetalhesEmpresa(company),
                                  child: Text(company.situacaoCadastral ?? '-'),
                                ),
                              ),
                              DataCell(
                                InkWell(
                                  onTap: () => _mostrarDetalhesEmpresa(company),
                                  child: Text(company.cnaePrincipal ?? '-'),
                                ),
                              ),
                              DataCell(
                                InkWell(
                                  onTap: () => _mostrarDetalhesEmpresa(company),
                                  child: Text(company.naturezaJuridica ?? '-'),
                                ),
                              ),
                               DataCell(
                                 InkWell(
                                   onTap: () => _mostrarDetalhesEmpresa(company),
                                   child: Text(company.email ?? '-'),
                                 ),
                               ),
                               DataCell(
                                 InkWell(
                                   onTap: () => _mostrarDetalhesEmpresa(company),
                                   child: Text(
                                     company.capitalSocial != null
                                         ? 'R\$ ${company.capitalSocial!.toStringAsFixed(2).replaceAll('.', ',')}'
                                         : '-',
                                   ),
                                 ),
                               ),
                               DataCell(
                                 InkWell(
                                   onTap: () => _mostrarDetalhesEmpresa(company),
                                   child: Text(
                                     company.updatedAt != null
                                         ? CnpjUtils.formatarData(company.updatedAt)
                                         : '-',
                                   ),
                      ),
                    ),
                  ],
                );
                }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
  
  Widget _construirControlesPaginacao(bool isTop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        border: isTop
            ? Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              )
            : Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
      ),
      child: Row(
        children: [
          // Informações da página
          Text(
            'Página $_currentPage de $_totalPages ($_totalItems itens)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          
          const Spacer(),
          
          // Controles de página
          Row(
            children: [
              // Primeira página
              IconButton(
                onPressed: _currentPage > 1 ? () => _irParaPagina(1) : null,
                icon: const Icon(Icons.first_page),
                tooltip: 'Primeira página',
              ),
              
              // Página anterior
              IconButton(
                onPressed: _currentPage > 1 ? () => _irParaPagina(_currentPage - 1) : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Página anterior',
              ),
              
              // Página atual
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$_currentPage',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Próxima página
              IconButton(
                onPressed: _currentPage < _totalPages ? () => _irParaPagina(_currentPage + 1) : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Próxima página',
              ),
              
              // Última página
              IconButton(
                onPressed: _currentPage < _totalPages ? () => _irParaPagina(_totalPages) : null,
                icon: const Icon(Icons.last_page),
                tooltip: 'Última página',
              ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Seletor de tamanho da página
          DropdownButton<int>(
            value: _pageSize,
            items: const [
              DropdownMenuItem(value: 10, child: Text('10 por página')),
              DropdownMenuItem(value: 20, child: Text('20 por página')),
              DropdownMenuItem(value: 50, child: Text('50 por página')),
            ],
            onChanged: _isLoading ? null : (value) {
              if (value != null) _alterarTamanhoPagina(value);
            },
          ),
        ],
      ),
    );
  }
  
  void _mostrarDetalhesEmpresa(Company company) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(company.razaoSocial),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Informações básicas
              _construirLinhaDetalhe('CNPJ', CnpjUtils.formatarCnpj(company.cnpj)),
              if (company.nomeFantasia != null)
                _construirLinhaDetalhe('Nome Fantasia', company.nomeFantasia!),
              if (company.situacaoCadastral != null)
                _construirLinhaDetalhe('Situação Cadastral', company.situacaoCadastral!),
              if (company.dataSituacaoCadastral != null)
                _construirLinhaDetalhe('Data Situação', CnpjUtils.formatarData(company.dataSituacaoCadastral)),
              if (company.matrizFilial != null)
                _construirLinhaDetalhe('Matriz/Filial', company.matrizFilial!),
              if (company.dataInicioAtividade != null)
                _construirLinhaDetalhe('Início Atividade', CnpjUtils.formatarData(company.dataInicioAtividade)),
              
              // Atividades econômicas
              if (company.cnaePrincipal != null)
                _construirLinhaDetalhe('CNAE Principal', company.cnaePrincipal!),
              if (company.cnaesSecundariosCount != null && company.cnaesSecundariosCount! > 0)
                _construirLinhaDetalhe('CNAEs Secundários', '${company.cnaesSecundariosCount} atividades'),
              if (company.naturezaJuridica != null)
                _construirLinhaDetalhe('Natureza Jurídica', company.naturezaJuridica!),
              
              // Endereço completo
              if (company.logradouro != null) ...[
                _construirLinhaDetalhe('Logradouro', company.logradouro!),
                if (company.numero != null)
                  _construirLinhaDetalhe('Número', company.numero!),
                if (company.complemento != null)
                  _construirLinhaDetalhe('Complemento', company.complemento!),
                if (company.bairro != null)
                  _construirLinhaDetalhe('Bairro', company.bairro!),
                if (company.cep != null)
                  _construirLinhaDetalhe('CEP', company.cep!),
                if (company.municipio != null)
                  _construirLinhaDetalhe('Município', company.municipio!),
                if (company.uf != null)
                  _construirLinhaDetalhe('UF', company.uf!),
              ],
              
              // Contato
              if (company.email != null)
                _construirLinhaDetalhe('Email', company.email!),
              if (company.telefones != null && company.telefones!.isNotEmpty)
                _construirLinhaDetalhe('Telefones', _construirTelefonesDetalhes(company)),
              
              // Informações financeiras
              if (company.capitalSocial != null)
                _construirLinhaDetalhe('Capital Social', 'R\$ ${company.capitalSocial!.toStringAsFixed(2).replaceAll('.', ',')}'),
              if (company.porteEmpresa != null)
                _construirLinhaDetalhe('Porte da Empresa', company.porteEmpresa!),
              
              // Regimes especiais
              if (company.opcaoSimples != null)
                _construirLinhaDetalhe('Simples Nacional', company.opcaoSimples!),
              if (company.dataOpcaoSimples != null)
                _construirLinhaDetalhe('Data Opção Simples', CnpjUtils.formatarData(company.dataOpcaoSimples)),
              if (company.opcaoMei != null)
                _construirLinhaDetalhe('MEI', company.opcaoMei!),
              if (company.dataOpcaoMei != null)
                _construirLinhaDetalhe('Data Opção MEI', CnpjUtils.formatarData(company.dataOpcaoMei)),
              
              // Quadro societário
              if (company.qsa != null && company.qsa!.isNotEmpty)
                _construirLinhaDetalhe('QSA', '${company.qsa!.length} sócio(s)'),
              
              // Datas do sistema
              if (company.createdAt != null)
                _construirLinhaDetalhe('Salvo no sistema em', CnpjUtils.formatarDataHora(company.createdAt)),
              if (company.updatedAt != null)
                _construirLinhaDetalhe('Atualizado em', CnpjUtils.formatarDataHora(company.updatedAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
  
  Widget _construirLinhaDetalhe(String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$rotulo:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(valor),
          ),
        ],
      ),
    );
  }
  
  
  String _construirTelefonesDetalhes(Company company) {
    if (company.telefones == null || company.telefones!.isEmpty) {
      return '-';
    }
    
    return company.telefones!.map((telefone) {
      final ddd = telefone['ddd']?.toString() ?? '';
      final numero = telefone['numero']?.toString() ?? '';
      final isFax = telefone['is_fax'] == true;
      final tipo = isFax ? 'Fax' : 'Telefone';
      return '$tipo: ($ddd) $numero';
    }).join('\n');
  }
}
