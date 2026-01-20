import 'package:flutter/material.dart';
import '../services/budget_service.dart';
import 'add_budget_page.dart';
//import 'package:flutter/material.dart';
//import 'package:fl_chart/fl_chart.dart';


const LinearGradient darkGradient = LinearGradient(
  colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final service = BudgetService();
  List budgets = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    budgets = await service.getBudgets();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Budgets"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.tealAccent,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBudgetPage()),
          );
          load();
        },
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: darkGradient),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 110, 16, 16),
          children: budgets.map((b) {
            return Card(
              color: Colors.black.withOpacity(0.35),
              child: ListTile(
                leading: const Icon(Icons.category, color: Colors.orangeAccent),
                title: Text(
                  b['category'],
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  "Limit: \$${b['limit_amount']}",
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () async {
                    await service.deleteBudget(b['id']);
                    load();
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
