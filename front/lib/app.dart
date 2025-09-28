import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/search/presentation/search_page.dart';
import 'features/list/presentation/list_page.dart';

/// Configuração principal da aplicação
/// 
/// Define tema Material 3, rotas e configurações globais
class App extends StatelessWidget {
  const App({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desafio Esfera Solar',
      debugShowCheckedModeBanner: false,
      
      // Tema personalizado da aplicação
      theme: AppTheme.lightTheme,
      
      // Tema escuro personalizado
      darkTheme: AppTheme.darkTheme,
      
      // Tema segue preferências do sistema
      themeMode: ThemeMode.system,
      
      // Rotas da aplicação
      initialRoute: '/',
      routes: {
        '/': (context) => const SearchPage(),
        '/companies': (context) => const ListPage(),
      },
      
      // Página 404
      onUnknownRoute: (context) => MaterialPageRoute(
        builder: (context) => const NotFoundPage(),
      ),
    );
  }
}

/// Página 404 para rotas não encontradas
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página não encontrada'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Página não encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'A página que você está procurando não existe.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                '/',
                (route) => false,
              ),
              icon: const Icon(Icons.home),
              label: const Text('Voltar ao início'),
            ),
          ],
        ),
      ),
    );
  }
}
