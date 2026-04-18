import 'package:flutter/material.dart';

import '../../../domain/entities/bill_entity.dart';
import '../../blocs/bills/bills_bloc.dart';
import 'add_bill_screen.dart';
import 'bill_detail_screen.dart';
import 'widgets/bill_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.bloc,
    required this.userId,
  });

  final BillsBloc bloc;
  final String userId;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    widget.bloc.loadBills();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.bloc,
      builder: (context, _) {
        final state = widget.bloc.state;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard Tagihan'),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openAddBill,
            icon: const Icon(Icons.add),
            label: const Text('Tambah'),
          ),
          body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: DropdownButtonFormField<BillCategory?>(
                            value: state.selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Kategori',
                            ),
                            items: <DropdownMenuItem<BillCategory?>>[
                              const DropdownMenuItem<BillCategory?>(
                                value: null,
                                child: Text('Semua'),
                              ),
                              ...BillCategory.values.map(
                                (category) => DropdownMenuItem<BillCategory?>(
                                  value: category,
                                  child: Text(category.name),
                                ),
                              ),
                            ],
                            onChanged: widget.bloc.setCategoryFilter,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<BillPaymentFilter>(
                            value: state.paymentFilter,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                            ),
                            items: BillPaymentFilter.values
                                .map(
                                  (filter) => DropdownMenuItem<BillPaymentFilter>(
                                    value: filter,
                                    child: Text(_paymentFilterLabel(filter)),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                widget.bloc.setPaymentFilter(value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<BillSortOption>(
                      value: state.sortOption,
                      decoration: const InputDecoration(labelText: 'Urutkan'),
                      items: BillSortOption.values
                          .map(
                            (sort) => DropdownMenuItem<BillSortOption>(
                              value: sort,
                              child: Text(_sortLabel(sort)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          widget.bloc.setSortOption(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.visibleBills.isEmpty
                        ? const Center(
                            child: Text('Belum ada tagihan. Tekan Tambah.'),
                          )
                        : RefreshIndicator(
                            onRefresh: widget.bloc.loadBills,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: state.visibleBills.length,
                              itemBuilder: (context, index) {
                                final bill = state.visibleBills[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  child: BillCard(
                                    bill: bill,
                                    onTap: () => _openDetail(bill.id),
                                    onMarkPaid: () => widget.bloc.markAsPaid(bill.id),
                                    onDelete: () => widget.bloc.deleteBill(bill.id),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Text(
                    state.errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openAddBill() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AddBillScreen(
          bloc: widget.bloc,
          userId: widget.userId,
        ),
      ),
    );
  }

  Future<void> _openDetail(String billId) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BillDetailScreen(
          bloc: widget.bloc,
          billId: billId,
        ),
      ),
    );
  }

  String _paymentFilterLabel(BillPaymentFilter filter) {
    switch (filter) {
      case BillPaymentFilter.all:
        return 'Semua';
      case BillPaymentFilter.paid:
        return 'Lunas';
      case BillPaymentFilter.unpaid:
        return 'Belum Lunas';
    }
  }

  String _sortLabel(BillSortOption sort) {
    switch (sort) {
      case BillSortOption.dueDateAsc:
        return 'Jatuh Tempo Terdekat';
      case BillSortOption.dueDateDesc:
        return 'Jatuh Tempo Terjauh';
      case BillSortOption.amountAsc:
        return 'Nominal Terkecil';
      case BillSortOption.amountDesc:
        return 'Nominal Terbesar';
    }
  }
}
