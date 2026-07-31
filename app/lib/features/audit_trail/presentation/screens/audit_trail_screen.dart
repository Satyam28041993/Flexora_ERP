import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../logic/audit_providers.dart';

class AuditTrailScreen extends ConsumerStatefulWidget {
  const AuditTrailScreen({super.key});

  @override
  ConsumerState<AuditTrailScreen> createState() => _AuditTrailScreenState();
}

class _AuditTrailScreenState extends ConsumerState<AuditTrailScreen> {
  String? _selectedModule;

  @override
  Widget build(BuildContext context) {
    final auditLogsAsync = ref.watch(auditLogsStreamProvider(_selectedModule));

    return Scaffold(
      appBar: AppBar(title: const Text('System Audit Trail & History')),
      body: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ChoiceChip(
                  label: const Text('All Modules'),
                  selected: _selectedModule == null,
                  onSelected: (_) => setState(() => _selectedModule = null),
                ),
                const SizedBox(width: 8),
                ...['Orders', 'Customers', 'Products', 'JobCards', 'Tooling', 'Production', 'Stores', 'QC', 'Dispatch']
                    .map((mod) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(mod),
                            selected: _selectedModule == mod,
                            onSelected: (_) => setState(() => _selectedModule = mod),
                          ),
                        )),
              ],
            ),
          ),
          Expanded(
            child: auditLogsAsync.when(
              data: (logs) {
                if (logs.isEmpty) {
                  return const Center(child: Text('No audit log entries recorded.'));
                }

                final dateFormat = DateFormat('dd-MM-yyyy HH:mm:ss');

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: logs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return Card(
                      elevation: 1,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primary.withAlpha(20),
                          child: Text(
                            log.module.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${log.module} — ${log.action}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(dateFormat.format(log.timestamp), style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${log.entityCode}: ${log.details} (User: ${log.performedBy})',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading Audit Logs: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
