import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/expense.dart';
import 'package:intl/intl.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExpenseCard({
    Key? key,
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i =
        {
          'Food': Icons.restaurant,
          'Transport': Icons.directions_car,
          'Shopping': Icons.shopping_bag,
          'Bills': Icons.receipt_long,
          'Entertainment': Icons.movie,
          'Other': Icons.miscellaneous_services,
        }[expense.category] ??
        Icons.category;
    final c =
        {
          'Food': Colors.red,
          'Transport': Colors.blue,
          'Shopping': Colors.purple,
          'Bills': Colors.orange,
          'Entertainment': Colors.green,
          'Other': Colors.grey,
        }[expense.category] ??
        Colors.black;

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: c.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(i, color: c),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Text(
                    expense.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '₹${expense.amount.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14, color: Colors.lightGreen),
                  ),
                  SizedBox(height: 2),
                  Text(expense.category, style: TextStyle(fontSize: 12)),
                  SizedBox(height: 2),
                  Text(
                    DateFormat('MMM dd, yyyy').format(expense.date),
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete, size: 18, color: Colors.red),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 32, 
                    minHeight: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}