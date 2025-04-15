import 'package:flutter/material.dart';
import '../screens/auth.dart';
import 'home/home_screen.dart';
import 'login/login_screen.dart';
import 'register/register_screen.dart';

class WidgetTree extends StatefulWidget{
    const WidgetTree({Key? key}) : super(key: key);

    @override
    State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree>{
    @override
    void initState() {
      super.initState();
      // Check if the user is already logged in on startup
      final currentUser = Auth().currentUser;
      print('Initial auth check: ${currentUser != null ? 'User is logged in (${currentUser.uid})' : 'No user found'}');
    }
    
    @override
    Widget build(BuildContext context){
        return StreamBuilder(
            stream: Auth().authStateChanges,
            builder: (context, snapshot){
                if (snapshot.connectionState == ConnectionState.waiting) {
                    // While checking auth state, show a loading indicator
                    return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                    );
                }
                // Check if the user is logged in
                if (snapshot.hasData){
                    print('Navigating to HomeScreen - User ID: ${snapshot.data?.uid}');
                    return const HomeScreen();
                } else {
                    print('Navigating to LoginScreen - No user data found');
                    return const LoginScreen();
                }
            }
        );
    }
}