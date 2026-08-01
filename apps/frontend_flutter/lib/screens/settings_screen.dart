import 'package:flutter/material.dart';

import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _service = SettingsService();
  final _dataController = TextEditingController();
  final _emulatorController = TextEditingController();
  AppSettings _settings = const AppSettings();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await _service.load();
    _dataController.text = settings.dataDirectory;
    _emulatorController.text = settings.emulatorExecutable;
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final settings = _settings.copyWith(
      dataDirectory: _dataController.text.trim(),
      emulatorExecutable: _emulatorController.text.trim(),
    );
    await _service.save(settings);
    if (!mounted) return;
    setState(() => _settings = settings);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configurações salvas.')),
    );
  }

  @override
  void dispose() {
    _dataController.dispose();
    _emulatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('Aparência', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              SegmentedButton<AppThemePreference>(
                segments: const [
                  ButtonSegment(value: AppThemePreference.system, label: Text('Sistema')),
                  ButtonSegment(value: AppThemePreference.light, label: Text('Claro')),
                  ButtonSegment(value: AppThemePreference.dark, label: Text('Escuro')),
                ],
                selected: <AppThemePreference>{_settings.theme},
                onSelectionChanged: (selection) {
                  setState(() => _settings = _settings.copyWith(theme: selection.first));
                },
              ),
              const SizedBox(height: 28),
              Text('Pastas e emulador', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                controller: _dataController,
                decoration: const InputDecoration(
                  labelText: 'Pasta principal de dados',
                  prefixIcon: Icon(Icons.folder_outlined),
                  helperText: 'Onde saves, backups e metadados serão guardados.',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emulatorController,
                decoration: const InputDecoration(
                  labelText: 'Executável do mGBA',
                  prefixIcon: Icon(Icons.sports_esports_outlined),
                  helperText: 'Deixe vazio para detecção automática.',
                ),
              ),
              const SizedBox(height: 28),
              Text('Proteção de saves', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const Expanded(child: Text('Quantidade máxima de backups')),
                      DropdownButton<int>(
                        value: _settings.maximumBackups,
                        items: const [5, 10, 20, 50]
                            .map((value) => DropdownMenuItem(value: value, child: Text('$value')))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _settings = _settings.copyWith(maximumBackups: value));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Salvar configurações'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
