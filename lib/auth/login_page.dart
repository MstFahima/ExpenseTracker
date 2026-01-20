import 'package:flutter/material.dart';
import '../supabase_client.dart';
import '../pages/dashboard_page.dart';
import 'register_page.dart';

const LinearGradient darkGradient = LinearGradient(//cannot changed 
  colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class LoginPage extends StatefulWidget {               //Can change its state UI can change dynamically.
  const LoginPage({super.key});                         //Widget can be constant if no state changes

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();//allow calling validate()on all filled at once,form validtaion
  final email = TextEditingController();
  final password = TextEditingController();
  bool isLoading = false;

  Future<void> signIn() async {
    if (!_formKey.currentState!.validate()) return;//if form invalid,stop execution

    setState(() => isLoading = true);
    try {
      await SupabaseConfig.client.auth.signInWithPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      Navigator.pushReplacement(                                 //replace login page with deashboard
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),//_ is a placeholder variable,don’t care about this parameter, I won’t use it inside the function.”
      );                                                         //“There is a parameter here, but I won’t use it.
    } catch (_) {                                                // There is a value here, but I’m ignoring it.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid credentials")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: darkGradient),
        child: Column(
          children: [
            const Spacer(),

            // CARD
            Card(
              color: Colors.black.withOpacity(0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 250,
                        height: 200,
                      ),

                      const SizedBox(height: 16),
                      const Text(
                        "Expense Tracker",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      _input(email, "Email"),
                      const SizedBox(height: 15),
                      _input(password, "Password", obscure: true),
                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : signIn,
                          child: isLoading
                              ? const CircularProgressIndicator()
                              : const Text("Login"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            // FOOTER
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: const Text(
                  "Don’t have an account? Create one",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController ctrl,
    String label, {
    bool obscure = false,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      validator: (v) => v!.isEmpty ? "$label required" : null,
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
