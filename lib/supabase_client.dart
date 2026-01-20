import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const url = 'https://armzamntbpwoqrkugvxt.supabase.co';
  static const anonKey = 'sb_publishable_0Um_0yjJ9GHvssqxOuWh9g_UCWUuAp7';

  static SupabaseClient get client => Supabase.instance.client;
}
//handles backend config.