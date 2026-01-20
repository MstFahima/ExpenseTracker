import '../supabase_client.dart';

class BudgetService {
  Future<void> addBudget(String category, double limit) async {
    final user = SupabaseConfig.client.auth.currentUser!;
    await SupabaseConfig.client.from('budgets').insert({
      'user_id': user.id,
      'category': category,
      'limit_amount': limit,
    });
  }

  Future<List> getBudgets() async {
    final user = SupabaseConfig.client.auth.currentUser!;
    return await SupabaseConfig.client
        .from('budgets')
        .select()
        .eq('user_id', user.id);
  }

  Future<void> deleteBudget(String id) async {
    await SupabaseConfig.client.from('budgets').delete().eq('id', id);
  }
}
