import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final appointments = List.generate(
      8,
      (index) => {
        'time': now.add(Duration(hours: index + 1)),
        'client': 'Client ${index + 1}',
        'pet': 'Doggo ${index + 1}',
        'service': index % 2 == 0 ? 'Grooming' : 'Checkup',
        'status': index < 2 ? 'Completed' : 'Scheduled',
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final apt = appointments[index];
          final time = DateFormat('HH:mm').format(apt['time'] as DateTime);

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              title: Text('${apt['service']} - ${apt['pet']}'),
              subtitle: Text('Client: ${apt['client']}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: apt['status'] == 'Completed' ? Colors.green.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  apt['status'] as String,
                  style: TextStyle(
                    color: apt['status'] == 'Completed' ? Colors.green : Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
