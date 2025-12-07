import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final timeFormatter = DateFormat('hh:mm a');

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Asistencias')),
      body: attendanceProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : attendanceProvider.records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 100, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Sin registros de asistencia',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: attendanceProvider.records.length,
              itemBuilder: (context, index) {
                final attendance = attendanceProvider.records[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dateFormatter.format(attendance.clockIn),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(attendance.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getStatusLabel(attendance.status),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.login, size: 20, color: Colors.green),
                            const SizedBox(width: 8),
                            Text('Entrada: ${timeFormatter.format(attendance.clockIn)}'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              attendance.isClockedOut ? Icons.logout : Icons.timer,
                              size: 20,
                              color: attendance.isClockedOut ? Colors.red : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              attendance.isClockedOut
                                  ? 'Salida: ${timeFormatter.format(attendance.clockOut!)}'
                                  : 'En turno',
                            ),
                          ],
                        ),
                        if (attendance.isClockedOut) ...[
                          const SizedBox(height: 8),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Horas trabajadas:',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${attendance.calculatedHours.toStringAsFixed(2)} hrs',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'absent':
        return Colors.red;
      case 'half-day':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return 'Presente';
      case 'late':
        return 'Tarde';
      case 'absent':
        return 'Ausente';
      case 'half-day':
        return 'Medio día';
      default:
        return status;
    }
  }
}
