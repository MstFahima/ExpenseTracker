import '../supabase_client.dart';

class ExpenseService {
  //  TOTAL
  Future<double> totalExpense() async {
    final user = SupabaseConfig.client.auth.currentUser!;
    final data = await SupabaseConfig.client
        .from('expenses')
        .select('amount')
        .eq('user_id', user.id);

    double total = 0;
    for (final item in data) {
      total += (item['amount'] as num).toDouble();
    }
    return total;
  }

  //  ADD
  Future<void> addExpense(String title, String category, double amount) async {
    final user = SupabaseConfig.client.auth.currentUser!;
    await SupabaseConfig.client.from('expenses').insert({
      'user_id': user.id,
      'title': title,
      'category': category,
      'amount': amount,
    });
  }

  // READ
  Future<List> getExpenses() async {
    final user = SupabaseConfig.client.auth.currentUser!;
    return await SupabaseConfig.client
        .from('expenses')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
  }

  //  UPDATE
  Future<void> updateExpense(
    String id,
    String title,
    String category,
    double amount,
  ) async {
    await SupabaseConfig.client
        .from('expenses')
        .update({'title': title, 'category': category, 'amount': amount})
        .eq('id', id);
  }

  //  DELETE
  Future<void> deleteExpense(String id) async {
    await SupabaseConfig.client.from('expenses').delete().eq('id', id);
  }
}
