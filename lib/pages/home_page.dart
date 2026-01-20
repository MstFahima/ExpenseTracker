import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../services/expense_service.dart';
import '../services/income_service.dart';
import 'add_expense_page.dart';
import 'edit_expense_page.dart';


enum PeriodFilter { monthly, yearly }//fixed set of values

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ExpenseService expenseService = ExpenseService();
  final IncomeService incomeService = IncomeService();

  double incomeTotal = 0;
  double expenseTotal = 0;
  List expenses = [];

  PeriodFilter _filter = PeriodFilter.monthly;//default filter

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {//Async because data comes from database
    incomeTotal = await incomeService.totalIncome();
    expenseTotal = await expenseService.totalExpense();
    expenses = await expenseService.getExpenses();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final balance = incomeTotal - expenseTotal;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [_filterToggle()],
      ),

      // ADD EXPENSE
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.tealAccent,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpensePage()),
          );
          loadDashboard();
        },
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: loadDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 110, 16, 16),
            child: Column(
              children: [
                _summaryCards(balance),
                const SizedBox(height: 20),
                _incomeVsExpenseChart(),
                const SizedBox(height: 20),
                _weeklyExpenseChart(),
                const SizedBox(height: 20),
                _expensePieChart(),
                const SizedBox(height: 20),
                _recentExpenses(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //  FILTER 

  Widget _filterToggle() {
    return PopupMenuButton<PeriodFilter>(
      icon: const Icon(Icons.filter_alt_outlined),
      onSelected: (val) => setState(() => _filter = val),
      itemBuilder: (_) => const [
        PopupMenuItem(value: PeriodFilter.monthly, child: Text("Monthly")),
        PopupMenuItem(value: PeriodFilter.yearly, child: Text("Yearly")),
      ],
    );
  }

  //  SUMMARY 

  Widget _summaryCards(double balance) {
    return Row(
      children: [
        _card("Income", incomeTotal, Colors.greenAccent),
        const SizedBox(width: 8),
        _card("Expense", expenseTotal, Colors.redAccent),
        const SizedBox(width: 8),
        _card("Balance", balance, Colors.cyanAccent),
      ],
    );
  }

  Widget _card(String title, double value, Color color) {
    return Expanded(
      child: Card(
        color: Colors.black.withOpacity(0.35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Text(title, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 6),
              Text(
                "\$${value.toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  BAR CHART 

  Widget _incomeVsExpenseChart() {
    return Card(
      color: Colors.black.withOpacity(0.35),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Income vs Expense",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: incomeTotal,
                          color: Colors.greenAccent,
                          width: 18,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: expenseTotal,
                          color: Colors.redAccent,
                          width: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  LINE CHART 

  Widget _weeklyExpenseChart() {
    final spots = List.generate(
      expenses.length.clamp(0, 7),
      (i) => FlSpot(i.toDouble(), (expenses[i]['amount'] as num).toDouble()),
    );

    return Card(
      color: Colors.black.withOpacity(0.35),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _filter == PeriodFilter.monthly
                  ? "Monthly Expenses"
                  : "Yearly Expenses",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.orangeAccent,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  PIE CHART 

  Widget _expensePieChart() {
    final Map<String, double> categoryTotals = {};

    for (var e in expenses) {
      final cat = e['category'];
      final amt = (e['amount'] as num).toDouble();
      categoryTotals[cat] = (categoryTotals[cat] ?? 0) + amt;
    }

    return Card(
      color: Colors.black.withOpacity(0.35),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Expense Distribution",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  sections: categoryTotals.entries.map((e) {
                    return PieChartSectionData(
                      value: e.value,
                      title: e.key,
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  RECENT EXPENSES 

  Widget _recentExpenses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Expenses",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (expenses.isEmpty)
          const Text(
            "No expenses yet",
            style: TextStyle(color: Colors.white70),
          ),
        ...expenses
            .take(5)
            .map(
              (e) => Card(
                color: Colors.black.withOpacity(0.35),
                child: ListTile(
                  leading: const Icon(
                    Icons.remove_circle,
                    color: Colors.redAccent,
                  ),
                  title: Text(
                    e['title'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    e['category'],
                    style: const TextStyle(color: Colors.white70),
                  ),

                  //  EDIT
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditExpensePage(expense: e),
                      ),
                    );
                    loadDashboard(); 
                  },

                  // 🗑 DELETE
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "\$${e['amount']}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          await expenseService.deleteExpense(e['id']);
                          loadDashboard();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
