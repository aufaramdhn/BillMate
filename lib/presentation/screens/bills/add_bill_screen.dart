import 'package:flutter/material.dart';

import '../../../domain/entities/bill_entity.dart';
import '../../blocs/bills/bills_bloc.dart';

class AddBillScreen extends StatefulWidget {
  const AddBillScreen({
    super.key,
    required this.bloc,
    required this.userId,
  });

  final BillsBloc bloc;
  final String userId;

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  BillCategory _selectedCategory = BillCategory.listrik;
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 7));
  bool _isRecurring = false;
  RecurrenceInterval _selectedRecurrence = RecurrenceInterval.monthly;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Tagihan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              key: const Key('add_bill_title_field'),
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Tagihan',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Judul wajib diisi.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('add_bill_amount_field'),
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Nominal',
                prefixText: 'Rp',
              ),
              validator: (value) {
                final parsed = double.tryParse(value ?? '');
                if (parsed == null || parsed <= 0) {
                  return 'Nominal harus lebih dari 0.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<BillCategory>(
              key: const Key('add_bill_category_field'),
              initialValue: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: BillCategory.values
                  .map(
                    (category) => DropdownMenuItem<BillCategory>(
                      value: category,
                      child: Text(category.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tanggal jatuh tempo'),
              subtitle: Text(_formatDate(_selectedDueDate)),
              trailing: const Icon(Icons.calendar_month),
              onTap: _pickDueDate,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tagihan berulang'),
              value: _isRecurring,
              onChanged: (value) {
                setState(() {
                  _isRecurring = value;
                });
              },
            ),
            if (_isRecurring)
              DropdownButtonFormField<RecurrenceInterval>(
                initialValue: _selectedRecurrence,
                decoration: const InputDecoration(labelText: 'Interval ulang'),
                items: RecurrenceInterval.values
                    .map(
                      (interval) => DropdownMenuItem<RecurrenceInterval>(
                        value: interval,
                        child: Text(interval.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedRecurrence = value;
                  });
                },
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('add_bill_submit_button'),
              onPressed: _isSubmitting ? null : _submit,
              child: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan Tagihan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _selectedDueDate = picked;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await widget.bloc.addBill(
      userId: widget.userId,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      category: _selectedCategory,
      dueDate: _selectedDueDate,
      isRecurring: _isRecurring,
      recurrenceInterval: _isRecurring ? _selectedRecurrence : null,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });
    Navigator.of(context).pop(true);
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
