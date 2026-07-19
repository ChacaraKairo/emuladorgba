import 'package:flutter/material.dart';

class SavesScreen extends StatelessWidget {
  const SavesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saves e backups')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Proteção do seu progresso',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'O aplicativo mantém o save normal separado dos save states e cria cópias antes e depois das partidas.',
              ),
              const SizedBox(height: 24),
              const _SaveFeatureCard(
                icon: Icons.shield_outlined,
                title: 'Save normal do jogo',
                description: 'Arquivo .sav usado pelo próprio jogo e portável entre plataformas.',
              ),
              const SizedBox(height: 12),
              const _SaveFeatureCard(
                icon: Icons.history,
                title: 'Backups automáticos',
                description: 'Cópias com data e hora antes e depois de cada partida.',
              ),
              const SizedBox(height: 12),
              const _SaveFeatureCard(
                icon: Icons.photo_library_outlined,
                title: 'Save states',
                description: 'Serão adicionados após a integração embarcada com o libmgba.',
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Como acessar os backups',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Abra os detalhes de um jogo e selecione “Gerenciar saves”. A lista mostrará o save atual, tamanho, data e backups disponíveis.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveFeatureCard extends StatelessWidget {
  const _SaveFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
