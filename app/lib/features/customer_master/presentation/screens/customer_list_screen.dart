import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/customer_model.dart';
import '../../logic/customer_providers.dart';
import 'customer_detail_screen.dart';
import 'customer_form_screen.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  String _searchQuery = '';
  String _selectedCityFilter = 'All Cities';
  String _selectedStatusFilter = 'All Statuses';

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Master Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(customersStreamProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CustomerFormScreen()),
        ),
        icon: const Icon(Icons.add_business),
        label: const Text('New Customer'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by Company Name, Customer Code, or Contact Person...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _selectedCityFilter,
                        decoration: const InputDecoration(labelText: 'Filter by Location / City', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                        items: const [
                          DropdownMenuItem(value: 'All Cities', child: Text('All Locations')),
                          DropdownMenuItem(value: 'Mumbai', child: Text('Mumbai')),
                          DropdownMenuItem(value: 'Thane', child: Text('Thane')),
                          DropdownMenuItem(value: 'Ankleshwar', child: Text('Ankleshwar')),
                        ],
                        onChanged: (val) => setState(() => _selectedCityFilter = val!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _selectedStatusFilter,
                        decoration: const InputDecoration(labelText: 'Customer Status', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                        items: const [
                          DropdownMenuItem(value: 'All Statuses', child: Text('All Statuses')),
                          DropdownMenuItem(value: 'active', child: Text('Active Only')),
                          DropdownMenuItem(value: 'inactive', child: Text('Inactive Only')),
                        ],
                        onChanged: (val) => setState(() => _selectedStatusFilter = val!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: customersAsync.when(
              data: (customers) {
                final filtered = customers.where((c) {
                  if (_selectedCityFilter != 'All Cities' && !c.billingAddress.city.toLowerCase().contains(_selectedCityFilter.toLowerCase())) return false;
                  if (_selectedStatusFilter != 'All Statuses' && c.status.toLowerCase() != _selectedStatusFilter.toLowerCase()) return false;
                  if (_searchQuery.isEmpty) return true;
                  return c.companyName.toLowerCase().contains(_searchQuery) ||
                      c.customerCode.toLowerCase().contains(_searchQuery) ||
                      c.primaryContact.name.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return _EmptyCustomersState(isSearching: _searchQuery.isNotEmpty);
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _CustomerCard(customer: filtered[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Error loading customers.\n$error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.danger),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCustomersState extends StatelessWidget {
  const _EmptyCustomersState({required this.isSearching});

  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline, size: 56, color: AppTheme.textSecondary),
          const SizedBox(height: 12),
          Text(
            isSearching ? 'No matching customers found' : 'No customers registered yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            isSearching
                ? 'Try searching with a different term.'
                : 'Click "New Customer" to register your first client.',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer});

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    final isActive = customer.status == CustomerStatus.active;

    return Card(
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isActive ? AppTheme.primary.withAlpha(25) : Colors.grey.withAlpha(50),
          child: Text(
            customer.customerCode.isNotEmpty
                ? customer.customerCode
                : customer.companyName.substring(0, 1).toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? AppTheme.primary : AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                customer.companyName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isActive ? Colors.green : Colors.red),
              ),
              child: Text(
                customer.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.green.shade800 : Colors.red.shade800,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (customer.primaryContact.name.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text('${customer.primaryContact.name} (${customer.primaryContact.phone})',
                        style: const TextStyle(fontSize: 13)),
                  ],
                ),
              if (customer.gstNo != null && customer.gstNo!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_outlined, size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text('GST: ${customer.gstNo}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CustomerDetailScreen(customer: customer),
          ),
        ),
      ),
    );
  }
}
