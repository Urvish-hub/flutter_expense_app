import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/expense.dart';
import 'package:flutter_application_1/services/firestore_services.dart';

/// Screen to add or edit an expense
class AddExpenseScreen extends StatefulWidget {
  final VoidCallback onSave;
  final Expense? expenseToEdit; // If null, we're adding a new expense
  
  const AddExpenseScreen({
    Key? key,
    required this.onSave,
    this.expenseToEdit,
  }) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  // Form validation key
  final formKey = GlobalKey<FormState>();
  
  // Database service
  final service = FirestoreServices();
  
  // Text controllers for input fields
  late TextEditingController titleController;
  late TextEditingController amountController;
  
  // Dropdown selection
  String selectedCategory = 'Other';
  
  // Date picker
  DateTime selectedDate = DateTime.now();
  
  // Category options
  final categories = ['Food', 'Travel', 'Shopping', 'Bills', 'Other'];

  @override
  void initState() {
    super.initState();
    
    // If editing, load the expense data
    if (widget.expenseToEdit != null) {
      titleController = TextEditingController(text: widget.expenseToEdit!.title);
      amountController = TextEditingController(text: widget.expenseToEdit!.amount.toString());
      selectedCategory = widget.expenseToEdit!.category;
      selectedDate = widget.expenseToEdit!.date;
    } else {
      // If adding, create empty controllers
      titleController = TextEditingController();
      amountController = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Clean up controllers
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  /// Open date picker
  void pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  /// Save or update expense
  void saveExpense() async {
    // Check if form is valid
    if (!formKey.currentState!.validate()) return;

    try {
      // Create expense object
      final expense = Expense(
        id: widget.expenseToEdit?.id ?? '',
        title: titleController.text,
        amount: double.parse(amountController.text),
        category: selectedCategory,
        date: selectedDate,
      );

      // Save to Firebase
      if (widget.expenseToEdit != null) {
        // Update existing
        await service.updateExpense(expense);
      } else {
        // Add new
        await service.addExpense(expense);
      }
      
      // Notify parent and close
      widget.onSave();
      if (mounted) Navigator.pop(context);
      
    } catch (e) {
      // Show error message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expenseToEdit != null;
    
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                isEditing ? 'Edit Expense' : 'Add Expense',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Title input field
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.edit),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Amount input field
              TextFormField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Amount (₹)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.currency_rupee),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter an amount';
                  }
                  
                  final amount = double.tryParse(value!);
                  if (amount == null) {
                    return 'Please enter a valid number';
                  }
                  
                  if (amount <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Category dropdown
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Date picker button
              GestureDetector(
                onTap: pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(
                        'Date: ${selectedDate.toString().split(' ')[0]}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel button
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                  ),
                  
                  // Save/Update button
                  ElevatedButton.icon(
                    onPressed: saveExpense,
                    icon: const Icon(Icons.check),
                    label: Text(isEditing ? 'Update' : 'Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}