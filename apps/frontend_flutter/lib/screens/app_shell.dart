import 'package:flutter/material.dart';

import 'library_screen.dart';
import 'saves_screen.dart';
import 'settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _destinations = <NavigationDestination>[
    NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Biblioteca'),
    NavigationDestination(icon: Icon(Icons.save_outlined), label: 'Saves'),
    NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Configurações'),
  ];

  static const _pages = <Widget>[
    LibraryScreen(),
    SavesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 900;
        if (!desktop) {
          return Scaffold(
            body: IndexedStack(index: _index, children: _pages),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              destinations: _destinations,
              onDestinationSelected: (value) => setState(() => _index = value),
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 1180,
                  selectedIndex: _index,
                  minExtendedWidth: 220,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Icon(Icons.catching_pokemon, size: 42),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.grid_view_rounded),
                      label: Text('Biblioteca'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.save_outlined),
                      label: Text('Saves'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      label: Text('Configurações'),
                    ),
                  ],
                  onDestinationSelected: (value) => setState(() => _index = value),
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: IndexedStack(index: _index, children: _pages)),
            ],
          ),
        );
      },
    );
  }
}
