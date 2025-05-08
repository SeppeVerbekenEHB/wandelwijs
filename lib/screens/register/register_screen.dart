import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../screens/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add Firestore import

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? errorMessage = '';
  bool isLogin = true;

  // Define reusable widgets
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
      errorMessage == '' ? '' : 'Fout: $errorMessage',
      style: const TextStyle(
        fontFamily: 'Sniglet',
        color: Colors.red
      ),
    );
  }

  Widget _submitButton(String text, VoidCallback onPressed, {bool isPrimary = true}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: isPrimary 
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
          ),
    );
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      // Create authentication user (don't capture return value)
      await Auth().createUserWithEmailAndPassword(
          _emailController.text, _passwordController.text);
      
      // Get the user ID from current user
      String uid = FirebaseAuth.instance.currentUser!.uid;
      
      try {
        // Create user document in Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uuid': uid,
          'username': _usernameController.text,
          'email': _emailController.text,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } catch (firestoreError) {
        print("Firestore error: $firestoreError");
        setState(() {
          errorMessage = "Account created but profile setup failed: $firestoreError";
        });
        // Still navigate to home since authentication succeeded
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to create user: $e";
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      createUserWithEmailAndPassword();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
                          'Registreren',
                          style: TextStyle(
                            fontFamily: 'RetroChild',
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Maak een nieuw account aan',
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
                          'Gebruikersnaam',
                          _usernameController,
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Voer een gebruikersnaam in';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _entryField(
                          'E-mailadres',
                          _emailController,
                          icon: Icons.email,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Voer een e-mailadres in';
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
                            if (value.length < 6) {
                              return 'Wachtwoord moet minimaal 6 tekens bevatten';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _entryField(
                          'Bevestig wachtwoord',
                          _confirmPasswordController,
                          isPassword: true,
                          icon: Icons.lock,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bevestig je wachtwoord';
                            }
                            if (value != _passwordController.text) {
                              return 'Wachtwoorden komen niet overeen';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        _submitButton('REGISTREREN', _register),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, AppRoutes.login);
                          },
                          child: const Text(
                            'Al een account? Inloggen',
                            style: TextStyle(
                              fontFamily: 'Sniglet',
                            ),
                          ),
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
