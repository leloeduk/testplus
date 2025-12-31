import 'package:lelochat/pages/domain/entities/expense.dart';

abstract class ExpenseRepository {
  List<Expense> getExpenses();
  void addExpense(Expense expense);
  void deleteExpense(int index);
  double getTotal();
}
