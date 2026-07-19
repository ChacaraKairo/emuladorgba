import 'package:flutter/material.dart';

import '../models/game_entry.dart';
import '../theme/app_colors.dart';

class GameDetailsScreen extends StatelessWidget {
  const GameDetailsScreen({
    required this.game,
    required this.onPlay,
    required this.onRemove,
    super.key,
  });

  final GameEntry game;
  final Future<void> Function() onPlay;
  final Future<void> Function() onRemove;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do jogo')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _GameHero(game: game),
                const SizedBox(height: 24),
                SizedBox(
                  height: 60,
                  child: FilledButton.icon(
                    onPressed: onPlay,
                    icon: const Icon(Icons.play_arrow_rounded, size: 30),
                    label: Text(
                      game.lastPlayedAt == null ? 'Jogar agora' : 'Continuar jogando',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _InformationCard(game: game),
                const SizedBox(height: 16),
                const _SaveStatusCard(),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () async {
                    await onRemove();
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remover da biblioteca'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: AppColors.brandRed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameHero extends StatelessWidget {
  const _GameHero({required this.game});

  final GameEntry game;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 132,
          height: 132,
          decoration: BoxDecoration(
            color: AppColors.brandBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppColors.brandYellow,
              width: 4,
            ),
          ),
          child: const Icon(
            Icons.catching_pokemon,
            size: 72,
            color: AppColors.brandBlue,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          game.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          game.lastPlayedAt == null
              ? 'Pronto para sua primeira partida'
              : 'Seu progresso está pronto para continuar',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({required this.game});

  final GameEntry game;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.folder_outlined,
              label: 'Arquivo da ROM',
              value: game.romPath,
            ),
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.schedule,
              label: 'Última partida',
              value: game.lastPlayedAt == null
                  ? 'Ainda não jogado'
                  : _formatDate(game.lastPlayedAt!),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} às $hour:$minute';
  }
}

class _SaveStatusCard extends StatelessWidget {
  const _SaveStatusCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.brandGreen.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: AppColors.brandGreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Proteção de progresso',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Backups e gerenciamento próprio de saves serão conectados na próxima integração nativa.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.brandBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              SelectableText(value),
            ],
          ),
        ),
      ],
    );
  }
}
