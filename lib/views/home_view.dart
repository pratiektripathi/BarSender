
import 'package:bar_sender/views/scan_view.dart';
import 'package:bar_sender/views/setting_view.dart';
import 'package:bar_sender/views/start_view.dart';
import 'package:flutter/material.dart';




class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BarSender',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final listFinish=[["1586","Prateek Tripathi kanpur","Up23bg23"],["2","Ashish","UP77AT5202"],["3","Raman","UP77AT5202"]];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(color: Colors.white), // Change text color to white
        ),
        backgroundColor: Color.fromARGB(255, 40, 40, 40), // Set app bar color to amber
        elevation: 8, // Add elevation for shadow effect
        iconTheme: IconThemeData(color: Colors.white), // Change icon color to white
        actionsIconTheme: IconThemeData(color: Colors.white), // Change actions icon color to white
        leading: IconButton(
          icon: Icon(Icons.menu_sharp), // User icon on the left side
          onPressed: () {
           _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert), // Three dots icon
            onPressed: () {
              // Implement menu functionality
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: [
            SizedBox(height: 50,),
            Container(
            width: 200,
            height: 120,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage("assets/logo.png"))
              ),
              
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                _scaffoldKey.currentState?.closeDrawer();
              },
            ),
            ListTile(
              leading: Icon(Icons.bluetooth),
              title: Text('Scanner'),
              onTap: () {
                onTapScanner();
                                
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {

                onTapSetting();
              }

                
            ),
            Spacer(),
            ListTile(
              leading: Icon(Icons.support),
              title: Text('help/support'),
              onTap: () {
                // Handle Settings tap
              },
            ),
          ],
        ),
      ),


      body: SafeArea(
        child: homepageListView()
        ),
        floatingActionButton: FloatingActionButton.extended(
        onPressed: updatelist,
        icon: Icon(Icons.start_sharp, color: Colors.white),
        label: Text('Start', style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 40, 40, 40),
        ),
      );
  }

  ListView homepageListView() {
    return ListView.builder(itemBuilder: (context, index){
        int revindex=listFinish.length-1-index;
        return Card(
          child: ListTile(
            leading: Column(
              children: [
                Text(
                  "Slip No.",style: TextStyle(color: Color.fromARGB(255, 100, 100, 100),fontWeight: FontWeight.bold),
                ),
                Text(
                  listFinish[revindex][0],
                  style: TextStyle(color:Color.fromARGB(255, 40, 40, 40),fontSize: 20,fontWeight: FontWeight.bold),
                )
          
              ],
          
            ),
            title: Text(listFinish[revindex][1],style: TextStyle(color:Color.fromARGB(255, 40, 40, 40),fontSize: 18,fontWeight: FontWeight.bold )),
            subtitle: Text(listFinish[revindex][2]+" | "+listFinish[revindex][1],style: TextStyle(color:Color.fromARGB(255, 120, 120, 120 ),fontSize: 12,fontWeight: FontWeight.bold)),
            ),
       
        );
      },

      itemCount: listFinish.length,

      
      );
  }

 

  void updatelist(){
    setState(() {});
    {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) =>  StartScreen()),
    
  );
}

  }



 void onTapScanner() {
    _scaffoldKey.currentState?.closeDrawer();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>  ScanScreen()),

    );
  }


 void onTapSetting() {
    _scaffoldKey.currentState?.closeDrawer();
    _showPasswordDialog(context);

  }

  Future<void> _showPasswordDialog(BuildContext context) async {
    final TextEditingController passwordController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Password'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Please enter your password to continue.'),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Submit'),
              onPressed: () {
                String password = passwordController.text;
                // Perform password validation here
                
                _handlePasswordSubmission(context, password);
              },
            ),
          ],
        );
      },
    );
  }

  void _handlePasswordSubmission(BuildContext context, String password) {
    // Handle the password submission (e.g., authenticate user)
    // For demonstration, just showing a snackbar
    if (password=="4011") {
      Navigator.of(context).pop();
      Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>  SettingScreen()),
      );
      
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Incorrect Password, Try Again !')));
      Navigator.of(context).pop();

    }
    

  }





}


