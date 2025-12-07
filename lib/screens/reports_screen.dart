import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 100, color: Colors.grey[400]),
              const SizedBox(height: 24),
              Text('Reportes en Desarrollo', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              const Text(
                'Los reportes y estadísticas se implementarán próximamente',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
