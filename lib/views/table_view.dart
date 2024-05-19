import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class TableView extends StatelessWidget {
  const TableView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BarSender',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TableScreen(),
    );
  }
}

class TableScreen extends StatefulWidget {
  const TableScreen({Key? key}) : super(key: key);

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  List<List<String>> tableData = [];
  List<List<String>> headerData = [
    ['Sno', 'Brand', 'Size', 'Color', 'Weight'],
  ];

  List ids =[];
  BluetoothConnection? connection;
  bool isConnected = false;
  int serialNumber = 1; // Initialize serial number

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();
  }

  void connectToDevice() async {
    if (isConnected) {
      connection?.dispose();
      setState(() {
        isConnected = false;
      });
      return;
    }

    try {
      var devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      var hc05 = devices.firstWhere((device) => device.address == "AA:A8:A0:17:04:49");

      connection = await BluetoothConnection.toAddress(hc05.address);
      setState(() {
        isConnected = true;
      });

      connection!.input!.listen((data) {
        String incomingData = String.fromCharCodes(data).trim();

        if (incomingData.isNotEmpty && incomingData.contains('*')) {
          updateTable(incomingData);
        }
      }).onDone(() {
        setState(() {
          isConnected = false;
        });
      });
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to device')),
      );
    }
  }

  void updateTable(String data) {
    // Parse the incoming data
    var parts = data.split('*');

    if (parts.length == 7) {
      // Check if the value at index 1 (brand) already exists in the table
      bool exists = ids.any((row) => row == parts[1]);

      if (!exists) {
        setState(() {
          ids.add(parts[1]);
          tableData.insert(0, [
            serialNumber.toString(), // Add the serial number
            parts[2],
            parts[3],
            parts[4],
            parts[5],
          ]);
          serialNumber++; // Increment the serial number
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BarSender',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_sharp))
        ],
        backgroundColor: const Color.fromARGB(255, 40, 40, 40),
        elevation: 8,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(isConnected ? Icons.bluetooth_connected : Icons.bluetooth),
          onPressed: connectToDevice,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: _buildDataTable(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: const Color.fromARGB(255, 220, 230, 40).withOpacity(0.5),
      child: Row(
        children: headerData.first.map((header) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                header,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDataTable() {
    return Table(
      border: TableBorder.all(),
      columnWidths: const {
        0: FlexColumnWidth(1.25),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
        4: FlexColumnWidth(2),
      },
      children: tableData.map((rowData) {
        return TableRow(
          decoration: BoxDecoration(
            color: tableData.indexOf(rowData) % 2 == 0
                ? const Color.fromARGB(255, 240, 240, 240)
                : null,
          ),
          children: rowData.map((cellData) {
            return TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  cellData,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
