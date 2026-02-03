import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/screens/expense_card.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/SplaceScreen.dart';
import 'package:flutter_application_1/services/firestore_services.dart';
import 'package:flutter_application_1/models/expense.dart';
import 'package:flutter_application_1/screens/add_expense.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ExpTrck());
}

class ExpTrck extends StatelessWidget {
  const ExpTrck({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: SplaceScreen(),
      routes: {'/home': (context) => ExpenseTrackerHome()},
    );
  }
}

class ExpenseTrackerHome extends StatefulWidget {
  const ExpenseTrackerHome({super.key});

  @override
  State<ExpenseTrackerHome> createState() => _ExpenseTrackerHomeState();
}

class _ExpenseTrackerHomeState extends State<ExpenseTrackerHome> {
  late DateTime _month = DateTime.now();
  bool _monthView = false;
  final _service = FirestoreServices();

  void _chgMonth(int o) => setState(() {
    _month = DateTime(_month.year, _month.month + o, 1);
  });

  void _snack(String msg, [bool err = false]) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: err ? Colors.red : null),
      );

  void _sheet([Expense? e]) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (c) => AddExpenseScreen(
      onSave: () => _snack(e == null ? 'Expense Added' : 'Expense Updated'),
      expenseToEdit: e,
    ),
  );
  void _delete(String id) => showDialog(
    context: context,
    builder: (c) => AlertDialog(
      title: Text('Delete Expense'),
      content: Text('Are you sure you want to delete this expense?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: Text('Cancel')),
        TextButton(
          onPressed: () async {
            Navigator.pop(c);
            await _service.deleteExpense(id);
            Navigator.pop(c);
            _snack('Expense Deleted');
          },
          child: Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _monthView = !_monthView;
              });
            },
            icon: Icon(
              _monthView ? Icons.calendar_month : Icons.calendar_today,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_monthView)
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _chgMonth(-1);
                        });
                      },
                      icon: Icon(Icons.arrow_back),
                    ),
                    Text(
                      '${['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][_month.month - 1]} ${_month.year}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _chgMonth(1);
                        });
                      },
                      icon: Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: StreamBuilder(
              stream: _monthView
                  ? _service.getTotalExpensesByMonth(_month)
                  : _service.getTotalExpenses(),
              builder: (c, s) => Card(
                elevation: 8,
                color: Colors.orange,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        _monthView ? 'Monthly Expense' : 'Total Expense',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${(s.data ?? 0.0).toStringAsFixed(2)} Rs',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Expense>>(
              stream: _monthView
                  ? _service.getExpensesByMonth(_month)
                  : _service.getAllExpenses(),
              builder: (c, s) {
                if (s.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final exp = s.data ?? [];
                if (exp.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 70, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No expenses found.'),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: exp.length,
                  itemBuilder: (c, i) => ExpenseCard(
                    expense: exp[i],
                    onEdit: () => _sheet(exp[i]),
                    onDelete: () => _delete(exp[i].id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _sheet(),
        child: Icon(Icons.add),
      ),
    );
  }
}
