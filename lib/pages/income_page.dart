import 'package:flutter/material.dart';
import '../services/income_service.dart';
import 'add_income_page.dart';
import 'edit_income_page.dart';

//  Dark Gradient
const LinearGradient darkGradient = LinearGradient(
  colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  final service = IncomeService();
  List incomes = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    incomes = await service.getIncomes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Income"),
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
            MaterialPageRoute(builder: (_) => const AddIncomePage()),
          );
          load();
        },
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: darkGradient),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 110, 16, 16),
          itemCount: incomes.length,
          itemBuilder: (_, i) {
            final income = incomes[i];
            return Card(
              color: Colors.black.withOpacity(0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.attach_money,
                  color: Colors.greenAccent,
                ),
                title: Text(
                  income['source'],
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  "\$${income['amount']}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                //  TAP → EDIT
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditIncomePage(income: income),
                    ),
                  );
                  load();
                },

                //  DELETE ICON (VISIBLE)
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () async {
                    await service.deleteIncome(income['id']);
                    load();
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
