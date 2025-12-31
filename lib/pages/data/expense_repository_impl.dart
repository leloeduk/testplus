import 'package:hive/hive.dart';
import 'package:lelochat/pages/domain/repositories/expense_repos.dart';
import 'package:lelochat/pages/domain/entities/expense.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final Box box;
  ExpenseRepositoryImpl(this.box);
  @override
  List<Expense> getExpenses() {
    return box.values.map((e) {
      final data = e as Map;
      return Expense(title: data['title'], amount: data['amount']);
    }).toList();
  }

  @override
  void addExpense(Expense expense) {
    box.add({'title': expense.title, 'amount': expense.amount});
  }

  @override
  void deleteExpense(int index) {
    box.deleteAt(index);
  }

  @override
  double getTotal() {
    return getExpenses().fold(0.0, (sum, item) => sum + item.amount);
  }
}
