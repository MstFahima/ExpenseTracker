import 'package:flutter/material.dart';
import '../supabase_client.dart';

const LinearGradient darkGradient = LinearGradient(
  //const improves performance by making it immutable
  colors: [
    // cannot chaged after created
    Color(0xFF0F2027),
    Color(0xFF203A43),
    Color(0xFF2C5364),
  ],
  begin: Alignment.topLeft, //Controls gradient direction
  end: Alignment.bottomRight,
);

class RegisterPage extends StatefulWidget {         //User input is dynamically,Form validation changes state,Loading indicator updates UI
  const RegisterPage({super.key});                  //helps Flutter efficiently rebuild widgets

  @override
  State<RegisterPage> createState() => _RegisterPageState(); //makes the class private
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();             //Form widget validation,Allows calling validate() on all fields at once
  final name = TextEditingController();                //final → variable cannot be reassigned
  final email = TextEditingController();
  final password = TextEditingController();            // Read user input,Control text field values
  final confirm = TextEditingController();
  bool loading = false;                                // control-Button enable/disable,Circular progress indicator

  //  REGEX
  final RegExp nameRegex = RegExp(r'^[a-zA-Z ]{4,}$',); //.* means match any character, any number of times (including zero times).
  final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',); //+ one or more times,cannot be empty,()group
  final RegExp passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$',); //?= → Positive lookahead,.* → Any characters, any length

  //  REGISTER
  Future<void> register() async {//
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true); //“Something changed, rebuild the UI”

    try {
      final res = await SupabaseConfig.client.auth.signUp(
        //await pauses execution until response comes
        email: email.text.trim(),
        password: password.text
            .trim(), //Takes user email and removes extra spaces
      );

      await SupabaseConfig.client.from('profiles').insert({
        'id': res.user!.id, //Links Supabase Auth user ID to profile table
        'name': name.text.trim(),
        'email': email.text.trim(),
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(
        () => loading = false,
      ); //something in this widget’s state has changed, please rebuild the UI with the new values.
    }
  }

  // UI
  @override // StatefulWidget’s build method
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: darkGradient),
        child: Column(
          children: [
            const Spacer(), //Flexible empty space,Pushes card towards center vertically

            Card(
              color: Colors.black.withOpacity(0.35),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey, //Connects the form fields to _formKey
                  child: Column(
                    //Enables validation for all fields
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 250,
                        height: 200,
                      ),

                      const SizedBox(height: 16),
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      _input(
                        //_input() → Reusable TextFormField widget
                        name,
                        "Full Name",
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Full Name required";
                          }
                          if (!nameRegex.hasMatch(v)) {
                            return "Enter a valid name (min 4 letters)";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      _input(
                        email,
                        "Email",
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Email required";
                          }
                          if (!emailRegex.hasMatch(v)) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      _input(
                        password,
                        "Password",
                        obscure: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Password required";
                          }
                          if (!passwordRegex.hasMatch(v)) {
                            return "Password must be 8+ chars, upper, lower, number & symbol";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      _input(
                        confirm,
                        "Confirm Password",
                        obscure: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Confirm password required";
                          }
                          if (v != password.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: loading ? null : register,
                          child: loading
                              ? const CircularProgressIndicator()
                              : const Text("Register"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Already have an account? Login",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // INPUT FIELD
  Widget _input(
    //one reusable widget and call it multiple times.
    TextEditingController ctrl,
    String label, {
    bool obscure = false, //For password hiding
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      validator: validator,
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
