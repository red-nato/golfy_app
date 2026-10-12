import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../pages/inicio_page.dart';
import '../pages/placeholder_page.dart';
import '../theme.dart';

class GolfyMain extends StatefulWidget {
  const GolfyMain({super.key});

  @override
  State<GolfyMain> createState() => _GolfyMainState();
}

class _GolfyMainState extends State<GolfyMain> {
  int _selectedIndex = 0;

  // Una pantalla por pestaña, en el MISMO orden que los items de abajo.
  final _pages = const [
    InicioPage(),
    PlaceholderPage('Mediciones'),
    PlaceholderPage('Carga'),
    PlaceholderPage('Bienestar'),
    PlaceholderPage('Perfil'),
  ];

  final _items = [
    SalomonBottomBarItem(
      icon: const Icon(Icons.home),
      title: const Text('Inicio'),
      selectedColor: Colors.green,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.insights),
      title: const Text('Mediciones'),
      selectedColor: Colors.orange,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.monitor_heart),
      title: const Text('Carga'),
      selectedColor: Colors.teal,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.favorite_border),
      title: const Text('Bienestar'),
      selectedColor: Colors.pink,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.person),
      title: const Text('Perfil'),
      selectedColor: Colors.purple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Golfy'),
        actions: [
          IconButton(
            tooltip: 'Cambiar tema',
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: _items,
      ),
    );
  }
}