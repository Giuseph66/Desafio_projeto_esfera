import 'package:flutter/material.dart';
import '../../../core/models/company.dart';
import '../../../core/utils/cnpj.dart';

/// Item da lista de empresas para exibição em tabela
/// 
/// Mostra dados principais da empresa de forma compacta
class CompanyListItem extends StatelessWidget {
  final Company company;
  final VoidCallback? onTap;
  
  const CompanyListItem({
    super.key,
    required this.company,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Ícone da empresa
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.business,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Dados principais
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Razão social
                  Text(
                    company.razaoSocial,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // CNPJ e CNAE
                  Row(
                    children: [
                      Text(
                        CnpjUtils.formatarCnpj(company.cnpj),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (company.cnaePrincipal != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'CNAE: ${company.cnaePrincipal}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Município/UF e situação
                  Row(
                    children: [
                      if (company.municipio != null) ...[
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${company.municipio}${company.uf != null ? '/${company.uf}' : ''}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (company.situacaoCadastral != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getSituacaoColor(context, company.situacaoCadastral!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            company.situacaoCadastral!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Data de atualização
            if (company.updatedAt != null) ...[
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Atualizado em',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    CnpjUtils.formatarData(company.updatedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Color _getSituacaoColor(BuildContext context, String situacao) {
    switch (situacao.toLowerCase()) {
      case 'ativa':
        return Colors.green;
      case 'inativa':
        return Colors.red;
      case 'suspensa':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.surfaceVariant;
    }
  }
}

/// Item da lista para exibição em cartão (mobile)
/// 
/// Versão adaptada para telas menores
class CompanyCardItem extends StatelessWidget {
  final Company company;
  final VoidCallback? onTap;
  
  const CompanyCardItem({
    super.key,
    required this.company,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com razão social
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.business,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      company.razaoSocial,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // CNPJ
              _construirLinhaInfo(
                context,
                'CNPJ',
                CnpjUtils.formatarCnpj(company.cnpj),
                Icons.credit_card,
              ),
              
              // Nome fantasia
              if (company.nomeFantasia != null) ...[
                const SizedBox(height: 8),
                _construirLinhaInfo(
                  context,
                  'Nome Fantasia',
                  company.nomeFantasia!,
                  Icons.business_center,
                ),
              ],
              
              // CNAE Principal
              if (company.cnaePrincipal != null) ...[
                const SizedBox(height: 8),
                _construirLinhaInfo(
                  context,
                  'CNAE Principal',
                  company.cnaePrincipal!,
                  Icons.category,
                ),
              ],
              
              // CNAEs Secundários
              if (company.cnaesSecundariosCount != null && company.cnaesSecundariosCount! > 0) ...[
                const SizedBox(height: 8),
                _construirLinhaInfo(
                  context,
                  'CNAEs Secundários',
                  '${company.cnaesSecundariosCount} atividades',
                  Icons.list_alt,
                ),
              ],
              
              // Natureza Jurídica
              if (company.naturezaJuridica != null) ...[
                const SizedBox(height: 8),
                _construirLinhaInfo(
                  context,
                  'Natureza Jurídica',
                  company.naturezaJuridica!,
                  Icons.gavel,
                ),
              ],
              
              // Endereço completo
              if (company.logradouro != null) ...[
                const SizedBox(height: 8),
                _construirLinhaInfo(
                  context,
                  'Endereço',
                  _construirEnderecoCompleto(),
                  Icons.location_on,
                ),
              ],
              
              // Email
              if (company.email != null) ...[
                const SizedBox(height: 8),
                _construirLinhaInfo(
                  context,
                  'Email',
                  company.email!,
                  Icons.email,
                ),
              ],
              
              // Telefones
              if (company.telefones != null && company.telefones!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _construirLinhaInfo(
                  context,
                  'Telefone',
                  _construirTelefones(),
                  Icons.phone,
                ),
              ],
              
              // Capital Social
              if (company.capitalSocial != null) ...[
                const SizedBox(height: 8),
                _construirLinhaInfo(
                  context,
                  'Capital Social',
                  'R\$ ${company.capitalSocial!.toStringAsFixed(2).replaceAll('.', ',')}',
                  Icons.attach_money,
                ),
              ],
              
              // Porte da Empresa
              if (company.porteEmpresa != null) ...[
                const SizedBox(height: 8),
                _construirLinhaInfo(
                  context,
                  'Porte',
                  company.porteEmpresa!,
                  Icons.scale,
                ),
              ],
              
              // Opção Simples
              if (company.opcaoSimples != null) ...[
                const SizedBox(height: 8),
                _construirLinhaInfo(
                  context,
                  'Simples Nacional',
                  company.opcaoSimples!,
                  Icons.check_circle,
                ),
              ],
              
              // MEI
              if (company.opcaoMei != null) ...[
                const SizedBox(height: 8),
                _construirLinhaInfo(
                  context,
                  'MEI',
                  company.opcaoMei!,
                  Icons.person,
                ),
              ],
              
              // Situação e data
              const SizedBox(height: 12),
              Row(
                children: [
                  if (company.situacaoCadastral != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getSituacaoColor(context, company.situacaoCadastral!),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        company.situacaoCadastral!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                  if (company.updatedAt != null)
                    Text(
                      'Atualizado em ${CnpjUtils.formatarData(company.updatedAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _construirLinhaInfo(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
  
  String _construirEnderecoCompleto() {
    final endereco = <String>[];
    
    if (company.logradouro != null) {
      endereco.add(company.logradouro!);
    }
    
    if (company.numero != null) {
      endereco.add(company.numero!);
    }
    
    if (company.complemento != null) {
      endereco.add(company.complemento!);
    }
    
    if (company.bairro != null) {
      endereco.add(company.bairro!);
    }
    
    if (company.cep != null) {
      endereco.add('CEP: ${company.cep!}');
    }
    
    if (company.municipio != null) {
      endereco.add(company.municipio!);
    }
    
    if (company.uf != null) {
      endereco.add(company.uf!);
    }
    
    return endereco.join(', ');
  }
  
  String _construirTelefones() {
    if (company.telefones == null || company.telefones!.isEmpty) {
      return '';
    }
    
    return company.telefones!.map((telefone) {
      final ddd = telefone['ddd']?.toString() ?? '';
      final numero = telefone['numero']?.toString() ?? '';
      final isFax = telefone['is_fax'] == true;
      final tipo = isFax ? 'Fax' : 'Tel';
      return '$tipo: ($ddd) $numero';
    }).join(', ');
  }
  
  Color _getSituacaoColor(BuildContext context, String situacao) {
    switch (situacao.toLowerCase()) {
      case 'ativa':
        return Colors.green;
      case 'inativa':
        return Colors.red;
      case 'suspensa':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.surfaceVariant;
    }
  }
}
