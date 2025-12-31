import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lelochat/pages/domain/repositories/expense_repos.dart';

import '../../domain/entities/expense.dart';

/* EVENTS */
abstract class ExpenseEvent {}

class LoadExpenses extends ExpenseEvent {}

class AddExpense extends ExpenseEvent {
  final String title;
  final double amount;

  AddExpense(this.title, this.amount);
}

class DeleteExpense extends ExpenseEvent {
  final int index;
  DeleteExpense(this.index);
}

/* STATE */
class ExpenseState {
  final List<Expense> expenses;
  final double total;

  ExpenseState({required this.expenses, required this.total});
}

/* BLOC */
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository repository;

  ExpenseBloc(this.repository) : super(ExpenseState(expenses: [], total: 0)) {
    on<LoadExpenses>((event, emit) {
      emit(
        ExpenseState(
          expenses: repository.getExpenses(),
          total: repository.getTotal(),
        ),
      );
    });

    on<AddExpense>((event, emit) {
      repository.addExpense(Expense(title: event.title, amount: event.amount));
      emit(
        ExpenseState(
          expenses: repository.getExpenses(),
          total: repository.getTotal(),
        ),
      );
    });

    on<DeleteExpense>((event, emit) {
      repository.deleteExpense(event.index);
      emit(
        ExpenseState(
          expenses: repository.getExpenses(),
          total: repository.getTotal(),
        ),
      );
    });
  }
}
