import 'package:flutter/material.dart';

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
    return DefaultTabController(
      length: 1, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 40, 40, 40),
          title: const Text(
            'Settings',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: 'General'),

            ],
          ),
        ),
        body: TabBarView(
          children: [
            GeneralSettings(),
          ],
        ),
      ),
    );
  }
}

class GeneralSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [const SizedBox(height: 20),
                        TextField(
                        decoration: const InputDecoration(
                        labelText: "Company Name",
                        border: OutlineInputBorder(),
                      ),
                  autofocus: true,
                      ),
                    const SizedBox(height: 10),
                    TextField(
                        decoration: const InputDecoration(
                        labelText: "Address",
                        border: OutlineInputBorder(),
                      ),
                      
                      ),
                    const SizedBox(height: 10),
                    TextField(
                        decoration: const InputDecoration(
                        labelText: "Contact Information",
                        border: OutlineInputBorder(),
                      ),
                    )
        ],
      ),
    );
  }
}








