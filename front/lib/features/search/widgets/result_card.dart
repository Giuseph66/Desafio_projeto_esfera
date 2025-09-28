import 'package:flutter/material.dart';
import '../../../core/models/company.dart';
import '../../../core/utils/cnpj.dart';

/// Card para exibição dos dados de CNPJ consultado
/// 
/// Mostra informações principais da empresa de forma organizada
class ResultCard extends StatelessWidget {
  final Company company;
  final VoidCallback? onSave;
  final bool isSaving;
  
  const ResultCard({
    super.key,
    required this.company,
    this.onSave,
    this.isSaving = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com razão social
            Row(
              children: [
                Icon(
                  Icons.business,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    company.razaoSocial,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Nome fantasia (se disponível)
            if (company.nomeFantasia != null && company.nomeFantasia!.isNotEmpty) ...[
              _construirLinhaInfo(
                context,
                'Nome Fantasia',
                company.nomeFantasia!,
                Icons.store,
              ),
              const SizedBox(height: 12),
            ],
            
            // CNPJ formatado
            _construirLinhaInfo(
              context,
              'CNPJ',
              CnpjUtils.formatarCnpj(company.cnpj),
              Icons.credit_card,
            ),
            
            const SizedBox(height: 12),
            
            // CNAE principal
            if (company.cnaePrincipal != null && company.cnaePrincipal!.isNotEmpty) ...[
              _construirLinhaInfo(
                context,
                'CNAE Principal',
                company.cnaePrincipal!,
                Icons.category,
              ),
              const SizedBox(height: 12),
            ],
            
            // Situação cadastral
            if (company.situacaoCadastral != null && company.situacaoCadastral!.isNotEmpty) ...[
              _construirLinhaInfo(
                context,
                'Situação',
                company.situacaoCadastral!,
                Icons.verified_user,
              ),
              const SizedBox(height: 16),
            ],
            
            // Botão de salvar
            if (onSave != null) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isSaving ? null : onSave,
                  icon: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(isSaving ? 'Salvando...' : 'Salvar Empresa'),
                ),
              ),
            ],
          ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
