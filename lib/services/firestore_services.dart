import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

class FirestoreServices {
  static final FirestoreServices _instance = FirestoreServices._internal();

  factory FirestoreServices() {
    return _instance;
  }

  FirestoreServices._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String collectionPath = 'expenses';

  //Get All Expenses
  Stream<List<Expense>> getAllExpenses() {
    return _db
        .collection(collectionPath)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Expense.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  //Get Total Expenses By Month
  Stream<double> getTotalExpensesByMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final firstDayStr = firstDay.toIso8601String();
    final lastDayStr = lastDay.toIso8601String();

    return _db
        .collection(collectionPath)
        .where('date', isGreaterThanOrEqualTo: firstDayStr)
        .where('date', isLessThanOrEqualTo: lastDayStr)
        .snapshots()
        .map((snapshot) {
          double total = 0.0;
          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            total += (data['amount'] as num?)?.toDouble() ?? 0.0;
          }
          return total;
        });
  }

  //Get Total Expenses Overall
  Stream<double> getTotalExpenses() {
    return _db.collection(collectionPath).snapshots().map((snapshot) {
      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['amount'] as num?)?.toDouble() ?? 0.0;
      }
      return total;
    });
  }

  //Get Expenses for specific month
  Stream<List<Expense>> getExpensesByMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final firstDayStr = firstDay.toIso8601String();
    final lastDayStr = lastDay.toIso8601String();

    return _db
        .collection(collectionPath)
        .where('date', isGreaterThanOrEqualTo: firstDayStr)
        .where('date', isLessThanOrEqualTo: lastDayStr)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Expense.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  //Add Expense
  Future<void> addExpense(Expense expense) async {
    await _db.collection(collectionPath).add(expense.toFirestore());
  }

  //Update Expense
  Future<void> updateExpense(Expense expense) async {
    await _db
        .collection(collectionPath)
        .doc(expense.id)
        .update(expense.toFirestore());
  }

  //Delete Expense
  Future<void> deleteExpense(String id) async {
    await _db.collection(collectionPath).doc(id).delete();
  }
}