import '../supabase_client.dart';

class AuthService {
  Future<void> register(String email, String password, String name) async {//fecth user input from register page
    final res = await SupabaseConfig.client.auth.signUp(//create new user in supabase auth
      email: email,
      password: password,
    );

    await SupabaseConfig.client.from('profiles').insert({
      'id': res.user!.id,
      'name': name,
    });
  }

  Future<void> login(String email, String password) async {
    await SupabaseConfig.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await SupabaseConfig.client.auth.signOut();
  }
}
