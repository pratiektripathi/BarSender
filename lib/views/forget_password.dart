import 'package:bar_sender/fire/auth.dart';
import 'package:bar_sender/views/home_view.dart';
import 'package:flutter/material.dart';



class Forget extends StatefulWidget {
  const Forget({super.key});




  @override
  State<Forget> createState() => _ForgetState();
}

class _ForgetState extends State<Forget> {



  TextEditingController _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }


 Future<void> _forget() async {
    AuthService authService = AuthService();
    try {
      await authService.forgetPassword(_email.text.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent to ${_email.text.toString()}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send password reset email.')),
      );
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
          gradient: LinearGradient(colors: [ Color.fromARGB(255, 154, 0, 197), const Color.fromARGB(255,40,40,40)],
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
              height: 180,
              child: Column(
                children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Request New Password',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),   
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TextField(
                    controller: _email,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email/Username',
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
                        _forget();
                      },
                      child: const Text('Request'),
                      
                    ),
                  ),
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}