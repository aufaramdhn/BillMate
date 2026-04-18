import 'package:billmate/data/repositories/in_memory_bills_repository.dart';
import 'package:billmate/domain/entities/bill_entity.dart';
import 'package:billmate/presentation/blocs/bills/bills_bloc.dart';
import 'package:billmate/presentation/screens/bills/add_bill_screen.dart';
import 'package:billmate/presentation/screens/bills/widgets/bill_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('S2-T10 add form renders fields and submit button',
      (WidgetTester tester) async {
    final bloc = BillsBloc(InMemoryBillsRepository());

    await tester.pumpWidget(
      MaterialApp(
        home: AddBillScreen(
          bloc: bloc,
          userId: 'test-user',
        ),
      ),
    );

    expect(find.byKey(const Key('add_bill_title_field')), findsOneWidget);
    expect(find.byKey(const Key('add_bill_amount_field')), findsOneWidget);
    expect(find.byKey(const Key('add_bill_category_field')), findsOneWidget);
    expect(find.byKey(const Key('add_bill_submit_button')), findsOneWidget);
    expect(find.text('Simpan Tagihan'), findsOneWidget);
  });

  testWidgets('S2-T10 bill card renders content and actions',
      (WidgetTester tester) async {
    final bill = BillEntity(
      id: 'bill-1',
      userId: 'user-1',
      title: 'Internet Bulanan',
      amount: 350000,
      category: BillCategory.internet,
      dueDate: DateTime(2026, 4, 25),
      isPaid: false,
      isRecurring: true,
      recurrenceInterval: RecurrenceInterval.monthly,
      notes: 'Prioritas bayar tepat waktu',
      createdAt: DateTime(2026, 4, 1),
      updatedAt: DateTime(2026, 4, 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillCard(
            bill: bill,
            onMarkPaid: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('Internet Bulanan'), findsOneWidget);
    expect(find.text('Kategori: internet'), findsOneWidget);
    expect(find.text('Tandai Lunas'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });
}
