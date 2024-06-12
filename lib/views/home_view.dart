import 'package:android_intent_plus/android_intent.dart';
import 'package:bar_sender/services/pdf_generator.dart';
import 'package:bar_sender/views/bluetoothHelpler.dart';
import 'package:flutter/material.dart';
import 'package:bar_sender/services/db_services.dart';
import 'package:bar_sender/views/scan_view.dart';
import 'package:bar_sender/views/setting_view.dart';
import 'package:bar_sender/views/start_view.dart';





class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<List<String>>> _listFinishFuture;

  @override
  void initState() {
    super.initState();
    _checkBluetoothPermissionAndEnable();
    _listFinishFuture = _fetchSlipData();
  }
  


  Future<void> _checkBluetoothPermissionAndEnable() async {
    bool bluetoothEnabled = await BluetoothHelper.ensureBluetoothIsEnabled();
    if (!bluetoothEnabled) {
      _showBluetoothDialog();
    }
  }

  void _showBluetoothDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bluetooth Required'),
          content: const Text('Please enable Bluetooth to use the app features.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () async {
                Navigator.of(context).pop();
                _openBluetoothSettings();
              },
            ),
          ],
        );
      },
    );
  }

void _openBluetoothSettings() {
  final intent = AndroidIntent(
    action: 'android.settings.BLUETOOTH_SETTINGS',
  );
  intent.launch();
}


  Future<List<List<String>>> _fetchSlipData() async {
    final data = await DbServices.instance.readSlipData();
    return data
        .map((map) =>
            map.values.map((value) => value?.toString() ?? '').toList())
        .toList();
  }

  Future<void> _refreshSlips() async {
    setState(() {
      _listFinishFuture = _fetchSlipData();
    });
  }

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
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.search),
        //     onPressed: () {
            
        //       // Implement search functionality
        //     },
        //   ),
        //   IconButton(
        //     icon: Icon(Icons.more_vert), // Three dots icon
        //     onPressed: () {
        //       // Implement menu functionality
        //     },
        //   ),
        // ],
      ),
      drawer: Drawer(
  backgroundColor: Color.fromARGB(255, 255, 255, 255),
  child: SingleChildScrollView(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      child: IntrinsicHeight(
        child: Column(
          children: [
            SizedBox(height: 50),
            Container(
              width: 200,
              height: 120,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage("assets/logo.png")),
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
              },
            ),
            Spacer(),
            ListTile(
              title: Text('-Made with 😊 by pratiek 🚀',style: TextStyle(fontStyle: FontStyle.italic)),
              onTap: () {
                // Handle Settings tap
              },
            ),
          ],
        ),
      ),
    ),
  ),
),
      body: SafeArea(
        child: FutureBuilder<List<List<String>>>(
          future: _listFinishFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No data available'));
            } else {
              return RefreshIndicator(
                onRefresh: _refreshSlips,
                child: homepageListView(snapshot.data!),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navStartview,
        icon: Icon(Icons.start_sharp, color: Colors.white),
        label: Text('Start', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 40, 40, 40),
      ),
    );
  }

  ListView homepageListView(List<List<String>> listFinish) {
    return ListView.builder(
      itemCount: listFinish.length,
      itemBuilder: (context, index) {
        int revindex = listFinish.length - 1 - index;
        return Card(
          child: ListTile(
            onTap: (){openReport(int.parse(listFinish[revindex][0]),listFinish[revindex][1],listFinish[revindex][2],listFinish[revindex][3],listFinish[revindex][4],listFinish[revindex][5]);},
            leading: Column(
              children: [
                const Text(
                  "Slip No.",
                  style: TextStyle(
                    color: Color.fromARGB(255, 100, 100, 100),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  listFinish[revindex][0],
                  style: const TextStyle(
                    color: Color.fromARGB(255, 40, 40, 40),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            title: Text(
              listFinish[revindex][1],
              style: const TextStyle(
                color: Color.fromARGB(255, 40, 40, 40),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              listFinish[revindex][3] + " | " + listFinish[revindex][4],
              style: TextStyle(
                color: Color.fromARGB(255, 120, 120, 120),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

Future<void> openReport(final int slipNo,final String partyName,final String partyAddress, final String vehicleNo,final String date, final String time) async {

  final tableData = await DbServices.instance.readBatchData(slipNo);


  final data = tableData.asMap().entries.map((entry) {
    final index = entry.key;
    final map = entry.value;
    final sublist = map.values.toList();
    final extractedData = sublist.sublist(3, 7).map((value) => value?.toString() ?? '').toList();

    // Calculate the serial number in increasing order
    final serialNumber = (index + 1).toString();

    // Insert the serial number as the first element
    extractedData.insert(0, serialNumber);

    return extractedData;
  }).toList();

  // Reverse the entire list
  final reversedData = data.reversed.toList();

  await PdfGenerator.toPdfGen(
    context,
    slipNo.toString(),
    partyName,
    partyAddress,
    vehicleNo,
    date,
    time,
    reversedData,
  );


}






  void _navStartview() {
    setState(() {});
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => StartScreen()),
    );
  }

  void onTapScanner() {
    _checkBluetoothPermissionAndEnable();
    _scaffoldKey.currentState?.closeDrawer();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ScanScreen()),
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
                _handlePasswordSubmission(context, password);
              },
            ),
          ],
        );
      },
    );
  }

  void _handlePasswordSubmission(BuildContext context, String password) {
    if (password == "4011") {
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => SettingScreen()),
      );
    } else if (password == "delall"){
    DbServices.instance.clearAllData();
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );


    }

    
    
    
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect Password, Try Again!')),
      );
      Navigator.of(context).pop();
    }
  }
}

