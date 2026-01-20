import 'package:flutter/material.dart';
import '../services/expense_service.dart';

const LinearGradient darkGradient = LinearGradient(
  colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class EditExpensePage extends StatelessWidget {
  final Map expense;
  const EditExpensePage({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final titleCtrl = TextEditingController(text: expense['title']);
    final categoryCtrl = TextEditingController(text: expense['category']);
    final amountCtrl = TextEditingController(
      text: expense['amount'].toString(),
    );

    final service = ExpenseService();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Edit Expense"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(gradient: darkGradient),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
            child: Card(
              color: Colors.black.withOpacity(0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _input(titleCtrl, "Title"),
                    const SizedBox(height: 12),
                    _input(categoryCtrl, "Category"),
                    const SizedBox(height: 12),
                    _input(amountCtrl, "Amount", isNumber: true),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text("Update Expense"),
                        onPressed: () async {
                          await service.updateExpense(
                            expense['id'],
                            titleCtrl.text,
                            categoryCtrl.text,
                            double.parse(amountCtrl.text),
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController ctrl,
    String label, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white30),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.tealAccent),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
