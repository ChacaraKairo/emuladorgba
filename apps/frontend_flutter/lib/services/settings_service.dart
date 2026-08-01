import 'package:shared_preferences/shared_preferences.dart';

enum AppThemePreference { system, light, dark }

class AppSettings {
  const AppSettings({
    this.theme = AppThemePreference.system,
    this.dataDirectory = '',
    this.emulatorExecutable = '',
    this.maximumBackups = 10,
  });

  final AppThemePreference theme;
  final String dataDirectory;
  final String emulatorExecutable;
  final int maximumBackups;

  AppSettings copyWith({
    AppThemePreference? theme,
    String? dataDirectory,
    String? emulatorExecutable,
    int? maximumBackups,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      dataDirectory: dataDirectory ?? this.dataDirectory,
      emulatorExecutable: emulatorExecutable ?? this.emulatorExecutable,
      maximumBackups: maximumBackups ?? this.maximumBackups,
    );
  }
}

class SettingsService {
  static const _themeKey = 'settings.theme';
  static const _dataDirectoryKey = 'settings.dataDirectory';
  static const _emulatorExecutableKey = 'settings.emulatorExecutable';
  static const _maximumBackupsKey = 'settings.maximumBackups';

  Future<AppSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    final themeName = preferences.getString(_themeKey);
    return AppSettings(
      theme: AppThemePreference.values.firstWhere(
        (value) => value.name == themeName,
        orElse: () => AppThemePreference.system,
      ),
      dataDirectory: preferences.getString(_dataDirectoryKey) ?? '',
      emulatorExecutable:
          preferences.getString(_emulatorExecutableKey) ?? '',
      maximumBackups: preferences.getInt(_maximumBackupsKey) ?? 10,
    );
  }

  Future<void> save(AppSettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeKey, settings.theme.name);
    await preferences.setString(_dataDirectoryKey, settings.dataDirectory);
    await preferences.setString(
      _emulatorExecutableKey,
      settings.emulatorExecutable,
    );
    await preferences.setInt(_maximumBackupsKey, settings.maximumBackups);
  }
}
