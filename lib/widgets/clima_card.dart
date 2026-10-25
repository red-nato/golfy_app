import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/clima.dart';
import '../providers/clima_provider.dart';
import '../services/clima_service.dart';

class ClimaCard extends StatelessWidget {
  const ClimaCard({super.key, this.resumen = false});
  final bool resumen;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClimaProvider>();
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(20),
      ),
      child: FutureBuilder<Clima>(
        future: provider.clima,
        builder: (context, snapshot) {
          final cargando = snapshot.connectionState == ConnectionState.waiting;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.wb_sunny_outlined, color: scheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clima de hoy',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${ClimaService.ciudad}, Chile',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Actualizar clima',
                    onPressed: cargando ? null : provider.actualizar,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Los tres casos de FutureBuilder, igual que en la clase.
              if (cargando)
                const Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Expanded(child: Text('Consultando el clima…')),
                  ],
                )
              else if (snapshot.hasError || !snapshot.hasData) ...[
                const Text(
                  'No pudimos cargar el clima. Revisa tu conexión e inténtalo otra vez.',
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: provider.actualizar,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                ),
              ] else ...[
                _DatosClima(clima: snapshot.data!, resumen: resumen),
                const SizedBox(height: 14),
                Text(
                  '${snapshot.data!.fechaTexto} · hora de Santiago',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                SelectableText(
                  'Fuente: Open-Meteo · CC BY 4.0\nhttps://open-meteo.com/',
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _DatosClima extends StatelessWidget {
  const _DatosClima({required this.clima, required this.resumen});
  final Clima clima;
  final bool resumen;

  String _decimal(double numero) =>
      numero.toStringAsFixed(1).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    if (resumen) {
      return Text(
        '${_decimal(clima.temperatura)} °C · UV ${_decimal(clima.indiceUv)}',
        style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.w700),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnas = constraints.maxWidth >= 540 ? 3 : 2;
        final ancho = (constraints.maxWidth - 16 * (columnas - 1)) / columnas;
        final datos = [
          _DatoClima(
            Icons.thermostat_rounded,
            'Temperatura',
            '${_decimal(clima.temperatura)} °C',
          ),
          _DatoClima(
            Icons.water_drop_outlined,
            'Humedad',
            '${clima.humedad.round()} %',
          ),
          _DatoClima(
            Icons.wb_sunny_outlined,
            'Índice UV',
            _decimal(clima.indiceUv),
          ),
          _DatoClima(
            Icons.air_rounded,
            'Viento',
            '${_decimal(clima.viento)} km/h',
          ),
          _DatoClima(
            Icons.umbrella_outlined,
            'Prob. de lluvia',
            '${clima.probabilidadLluvia.round()} %',
          ),
        ];
        return Wrap(
          spacing: 16,
          runSpacing: 18,
          children: [
            for (final dato in datos) SizedBox(width: ancho, child: dato),
          ],
        );
      },
    );
  }
}

class _DatoClima extends StatelessWidget {
  const _DatoClima(this.icono, this.nombre, this.valor);
  final IconData icono;
  final String nombre;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 20, color: scheme.primary),
        const SizedBox(height: 5),
        Text(
          nombre,
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
        Text(
          valor,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
