import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../screens/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usermailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? errorMessage = '';
  bool isLogin = true;
  bool _isLoading = false;

  Future<void> signInWithEmailAndPassword() async {
    setState(() {
      _isLoading = true;
      errorMessage = '';
    });
    
    try {
      await Auth().signInWithEmailAndPassword(_usermailController.text, _passwordController.text);

      // If auth succeeds but widget_tree doesn't redirect quickly enough, 
      // Add a small delay and manual navigation as fallback
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && Auth().currentUser != null) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;  // Hide loading indicator when done
        });
      }
    }
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
    {bool isPassword = false, 
    IconData? icon,
    String? Function(String?)? validator}
  ){
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontFamily: 'Sniglet'),
      decoration: InputDecoration(
        labelText: title,
        labelStyle: const TextStyle(fontFamily: 'Sniglet'),
        errorStyle: const TextStyle(fontFamily: 'Sniglet'),
        border: OutlineInputBorder(),
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
      obscureText: isPassword,
      validator: validator,
    );
  }

  Widget _errorMessage(){
    return Text(
      errorMessage == '' ? '' : 'Hmmmm? $errorMessage',
      style: TextStyle(
        fontFamily: 'Sniglet',
        color: Colors.red
      ),
    );
  }

  Widget _submitButton(String text, VoidCallback onPressed, {bool isPrimary = true}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : (isPrimary 
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Sniglet',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.green[800]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Sniglet',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            )
        ),
    );
  }

  @override
  void dispose() {
    _usermailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      signInWithEmailAndPassword();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Seamlessbackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Wandelwijs',
                          style: TextStyle(
                            fontFamily: 'RetroChild',
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Wandelen wordt een avontuur',
                          style: TextStyle(
                            fontFamily: 'Sniglet',
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        _errorMessage(),
                        const SizedBox(height: 5),
                        _entryField(
                          'e-mail',
                          _usermailController,
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Voer je mail adres in';
                            }
                            if (!value.contains('@')) {
                              return 'Voer een geldig e-mailadres in';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _entryField(
                          'Wachtwoord',
                          _passwordController,
                          isPassword: true,
                          icon: Icons.lock,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Voer een wachtwoord in';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        _submitButton('InLoggen', _login),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            // Handle forgot password
                          },
                          child: const Text(
                            'Wachtwoord vergeten?',
                            style: TextStyle(
                              fontFamily: 'Sniglet',
                            ),
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        _submitButton(
                          'REGISTREREN', 
                          () {
                            Navigator.pushNamed(context, AppRoutes.register);
                          },
                          isPrimary: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
