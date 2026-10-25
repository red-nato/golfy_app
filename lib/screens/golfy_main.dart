import 'package:flutter/material.dart';

import '../widgets/golf_identity.dart';
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: isDark ? const Color(0xFF0D1611) : const Color(0xFFE9EEDF),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: golfGreen,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.golf_course_rounded,
                      color: golfLime,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'golfy',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                            color: scheme.primary,
                          ),
                        ),
                        Text(
                          'JUEGA BIEN. SIÉNTETE MEJOR.',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 8,
                            letterSpacing: 1.3,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Cambiar tema',
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: Icon(
                      isDark
                          ? Icons.wb_sunny_outlined
                          : Icons.nightlight_outlined,
                      key: ValueKey(isDark),
                    ),
                  ),
                  onPressed: () {
                    themeNotifier.value = isDark
                        ? ThemeMode.light
                        : ThemeMode.dark;
                  },
                ),
              ],
            ),
            // IndexedStack mantiene viva cada pestaña: no pierdes lo que registraste
            // en Carga ni lo que editaste en Perfil al cambiar de pestaña.
            body: SafeArea(
              top: false,
              bottom: false,
              child: GolfEntrance(
                page: _selectedIndex,
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    for (var i = 0; i < _pages.length; i++)
                      TickerMode(
                        enabled: i == _selectedIndex,
                        child: _pages[i],
                      ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: scheme.outlineVariant)),
              ),
              child: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) =>
                    setState(() => _selectedIndex = index),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.golf_course_outlined),
                    selectedIcon: Icon(Icons.golf_course_rounded),
                    label: 'Inicio',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.insights_outlined),
                    selectedIcon: Icon(Icons.insights_rounded),
                    label: 'Mediciones',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.sports_golf_outlined),
                    selectedIcon: Icon(Icons.sports_golf_rounded),
                    label: 'Carga',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.spa_outlined),
                    selectedIcon: Icon(Icons.spa_rounded),
                    label: 'Bienestar',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Perfil',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
