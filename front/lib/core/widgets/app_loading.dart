import 'package:flutter/material.dart';

/// Widget padrão para exibição de loading
/// 
/// Centraliza o design de indicadores de carregamento
class AppLoading extends StatelessWidget {
  final String? message;
  final double? size;
  
  const AppLoading({
    super.key,
    this.message,
    this.size,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size ?? 32,
              height: size ?? 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget de loading para botões
/// 
/// Substitui conteúdo do botão por indicador de loading
class ButtonLoading extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final double size;
  
  const ButtonLoading({
    super.key,
    required this.isLoading,
    required this.child,
    this.size = 16,
  });
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      );
    }
    
    return child;
  }
}
