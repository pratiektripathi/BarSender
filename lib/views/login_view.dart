import 'package:bar_sender/fire/auth.dart';
import 'package:bar_sender/views/forget_password.dart';
import 'package:bar_sender/views/home_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



class LoginScren extends StatefulWidget {
  const LoginScren({super.key});

  @override
  State<LoginScren> createState() => _LoginScrenState();
}

class _LoginScrenState extends State<LoginScren> {
  bool _isLoading=false;
  bool _obscureText = true;
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();


  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }


  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }


  void _checkUserLoggedIn() async {
     AuthService authService = AuthService();
     User? user = authService.getCurrentUser();
      if (user!=null) {
        try {
          await user.reload();
          user = authService.getCurrentUser();
          if(user!=null){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
        }
        catch (e) {
          await authService.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed. Please try again.')),
          );
      }
  }}

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    AuthService authService = AuthService();


    
    try {
      var value = await authService.signInWithEmailAndPassword(_email.text, _password.text);
      if (value != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Color.fromARGB(255, 40, 40, 40),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [ Color.fromARGB(156, 197, 0, 0), const Color.fromARGB(255,40,40,40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          )
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: SizedBox(
              width: 250,
              height: 290,
              child: Column(
                children: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      
                    ),
                  ),
                ),

              Container(
                child: _isLoading? Column(
                  children: [Padding(
                    padding: const EdgeInsets.only(top: 70,bottom: 20),
                    child: CircularProgressIndicator(color: const Color.fromARGB(156, 197, 0, 0),),
                  ),
                  Text("Loading...")],
                ):Column(

                children: [
                  Padding(
                padding: const EdgeInsets.all(4.0),
                  child: TextField(
                    controller: _email,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email/Username',
                    ))),
          
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TextField(
                    controller: _password,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      suffixIcon: Tooltip(
                        message: _obscureText ? 'show': "hide",
                        child: IconButton(onPressed:()=> setState(() => _obscureText=!_obscureText), 
                        icon: Icon( _obscureText ? Icons.visibility : Icons.visibility_off,
                        ),
                        ),
                      )
                    ),
                  ),
                ),
                
                Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to reset password screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Forget()),
                      );
                    },
                    child: Text(
                      'Forget Password?',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      
                    ),
                  ),
                ),
              ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 40, 40, 40),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        minimumSize: Size(double.infinity, 50),
                        textStyle: TextStyle(fontSize: 20),
                        
                      ),
                      onPressed: () {
                        _login();
                      },
                      child: const Text('LOGIN'),
                      
                    ),
                )
                ]),
                ),
            ]),
          )
  ),
              
                  
            )
      )
    );

  }
}

