import '../supabase_client.dart';

class IncomeService {
  Future<void> updateIncome(String id, String source, double amount) async {
    await SupabaseConfig.client
        .from('incomes')
        .update({'source': source, 'amount': amount})
        .eq('id', id);
  }

  Future<double> totalIncome() async {
    final user = SupabaseConfig.client.auth.currentUser!;
    final data = await SupabaseConfig.client
        .from('incomes')
        .select('amount')
        .eq('user_id', user.id);

    double total = 0;

    for (final item in data) {
      total += (item['amount'] as num).toDouble();
    }

    return total;
  }

  Future<void> addIncome(String source, double amount) async {
    final user = SupabaseConfig.client.auth.currentUser!;
    await SupabaseConfig.client.from('incomes').insert({
      'user_id': user.id,
      'source': source,
      'amount': amount,
    });
  }

  Future<List> getIncomes() async {
    final user = SupabaseConfig.client.auth.currentUser!;
    return await SupabaseConfig.client
        .from('incomes')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
  }

  Future<void> deleteIncome(String id) async {
    await SupabaseConfig.client.from('incomes').delete().eq('id', id);
  }
}
