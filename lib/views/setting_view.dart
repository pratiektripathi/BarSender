import 'package:flutter/material.dart';




class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BarSender',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SettingScreen(),
    );
  }
}


class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 40, 40, 40),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ),
      body: SafeArea(child: Column(children: [Text("data")],)),
      );
    
  }
}