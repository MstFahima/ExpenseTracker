import 'package:flutter/material.dart';
import '../services/budget_service.dart';

const LinearGradient darkGradient = LinearGradient(
  colors: [Color(0xFF0F2027), Color(0xFF203A43), Color.fromARGB(255, 102, 154, 177)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class AddBudgetPage extends StatelessWidget {
  const AddBudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final category = TextEditingController();
    final limit = TextEditingController();
    final service = BudgetService();//to handle buget options

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Add Budget"),
        backgroundColor: Colors.transparent,//
        elevation: 0,
        centerTitle: true,
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(gradient: darkGradient),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 120, 20, 40),
              child: Card(
                color: Colors.black.withOpacity(0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _input(category, "Category"),
                      const SizedBox(height: 15),
                      _input(limit, "Limit Amount", isNumber: true),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text("Save Budget"),
                          onPressed: () async {
                            await service.addBudget(
                              category.text,
                              double.parse(limit.text),
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
