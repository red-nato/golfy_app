import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../pages/bienestar_page.dart';
import '../pages/carga_page.dart';
import '../pages/inicio_page.dart';
import '../pages/mediciones_page.dart';
import '../pages/perfil_page.dart';
import '../theme.dart';

class GolfyMain extends StatefulWidget {
  const GolfyMain({super.key});

  @override
  State<GolfyMain> createState() => _GolfyMainState();
}

class _GolfyMainState extends State<GolfyMain> {
  int _selectedIndex = 0;

  // Una pantalla por pestaña, en el MISMO orden que los items de abajo.
  // Inicio recibe una función para saltar a la pestaña Perfil (la última).
  late final List<Widget> _pages = [
    InicioPage(onPerfil: () => setState(() => _selectedIndex = 4)),
    const MedicionesPage(),
    const CargaPage(),
    const BienestarPage(),
    const PerfilPage(),
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
      // IndexedStack mantiene viva cada pestaña: no pierdes lo que registraste
      // en Carga ni lo que editaste en Perfil al cambiar de pestaña.
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: _items,
      ),
    );
  }
}