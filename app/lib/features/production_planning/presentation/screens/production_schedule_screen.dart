import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/production_schedule_model.dart';
import '../../logic/production_providers.dart';
import 'production_log_form_screen.dart';

class ProductionScheduleScreen extends ConsumerStatefulWidget {
  const ProductionScheduleScreen({super.key});

  @override
  ConsumerState<ProductionScheduleScreen> createState() => _ProductionScheduleScreenState();
}

class _ProductionScheduleScreenState extends ConsumerState<ProductionScheduleScreen> {
  String? _selectedMachineId;

  @override
  Widget build(BuildContext context) {
    final machinesAsync = ref.watch(machinesStreamProvider);
    final schedulesAsync = ref.watch(productionSchedulesStreamProvider(_selectedMachineId));

    return Scaffold(
      appBar: AppBar(title: const Text('Production Planning & Machine Queue')),
      body: Column(
        children: [
          machinesAsync.when(
            data: (machines) {
              if (machines.isEmpty) return const SizedBox.shrink();
              return Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ChoiceChip(
                      label: const Text('All Machines'),
                      selected: _selectedMachineId == null,
                      onSelected: (_) => setState(() => _selectedMachineId = null),
                    ),
                    const SizedBox(width: 8),
                    ...machines.map((m) {
                      final isSelected = _selectedMachineId == m.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(m.machineName),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedMachineId = m.id),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (err, _) => const SizedBox.shrink(),
          ),
          Expanded(
            child: schedulesAsync.when(
              data: (schedules) {
                if (schedules.isEmpty) {
                  return const Center(child: Text('No scheduled production jobs in queue.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: schedules.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _ScheduleCard(schedule: schedules[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading schedule: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends ConsumerWidget {
  const _ScheduleCard({required this.schedule});

  final ProductionScheduleModel schedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRunning = schedule.status == 'Running';

    return Card(
      elevation: isRunning ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isRunning ? Colors.orange : Colors.transparent,
          width: isRunning ? 2 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppTheme.primary.withAlpha(30),
                      child: Text(
                        '#${schedule.queuePriority}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(schedule.jobCardNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Chip(
                  label: Text(schedule.status.toUpperCase()),
                  backgroundColor: _getStatusColor(schedule.status).withAlpha(25),
                  labelStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(schedule.status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(schedule.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text('Customer: ${schedule.customerName} | SKU: ${schedule.internalSkuCode}',
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('Machine: ${schedule.machineName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(width: 16),
                Text('Shift: ${schedule.shift}', style: const TextStyle(fontSize: 12)),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Target: ${schedule.targetQuantity.toInt()} pcs (${schedule.plannedRmt.toInt()} RMT)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary)),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ProductionLogFormScreen(schedule: schedule)),
                  ),
                  icon: const Icon(Icons.playlist_add_check, size: 18),
                  label: const Text('Log Output / Run Data'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Running':
        return Colors.orange.shade800;
      case 'InSetup':
        return Colors.blue.shade800;
      case 'Completed':
        return Colors.green.shade800;
      case 'OnHold':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade800;
    }
  }
}
