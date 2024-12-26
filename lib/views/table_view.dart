import 'dart:convert';
import 'package:bar_sender/services/db_services.dart';
import 'package:bar_sender/services/pdf_generator.dart';
import 'package:bar_sender/views/home_view.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';


class TableScreen extends StatefulWidget {
  final int slipNo;
  final String partyName;
  final String address;
  final String vehicleNo;
  final String date;
  final String time;
  const TableScreen({Key? key, required this.slipNo, required this.partyName,required this.address,required this.vehicleNo,required this.date,required this.time}) : super(key: key);

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  List<List<String>> tableData = [];
  List<List<String>> headerData = [
    ['Sno', 'Brand', 'Size', 'Color', 'Weight'],
  ];

  List ids = [];
  BluetoothConnection? connection;
  bool isConnected = false;
  bool isAddState = true;
  int serialNumber = 1; // Initialize serial number
  double totalWeight = 0;
  BluetoothDevice? selectedDevice;

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> loadSelectedDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonDevice = prefs.getString('selected_device');
    if (jsonDevice != null) {
      setState(() {
        selectedDevice = BluetoothDevice.fromMap(jsonDecode(jsonDevice));
      });
    }
  }

  Future<void> requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();
  }

  void toggleAddState() {
    setState(() {
      isAddState = !isAddState;
    });
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
      await loadSelectedDevice();
      var devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      var hc05 = devices
          .firstWhere((device) => device.address == selectedDevice!.address);

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Failed to connect to device: ${selectedDevice?.name}')),
      );
    }
  }

  void updateTable(String data) {
    // Parse the incoming data
    var parts = data.split('*');
    


    if (parts.length == 7) {
      // Check if the value at index 1 (brand) already exists in the table
      bool exists = ids.any((row) => row == parts[1]);

      if (isAddState) {
        if (!exists) {
          setState(() {
            ids.add(parts[1]);
            tableData.insert(0, [
              serialNumber.toString(), // Add the serial number
              parts[2],
              parts[3],
              parts[4],
              double.parse(parts[5]).toStringAsFixed(3), // Parse parts[5] as double
            ]);
            DbServices.instance.insertBatchData(widget.slipNo, parts[1],parts[2],parts[3],parts[4],parts[5]);

            serialNumber++;
            totalWeight = totalWeight + double.parse(parts[5]);
          });
        }
      } else {
        if (exists) {
          setState(() {
            // Remove the value from ids
            ids.removeWhere((row) => row == parts[1]);
            totalWeight = totalWeight - double.parse(parts[5]);
            // Find and remove the corresponding row in tableData
            tableData.removeWhere((row) =>
                row[1] == parts[2] &&
                row[2] == parts[3] &&
                row[3] == parts[4] &&
                row[4] == double.parse(parts[5]).toStringAsFixed(3));
            DbServices.instance.removeBatchData(parts[1]); // Parse parts[5] as double
          });
        }
      }
    }
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you really want to go Back?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => _backtoHome(context),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

void  _backtoHome(BuildContext context) {

    Navigator.of(context).pop(true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
    
    
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
              title: const Text(
                'BarSender',
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                      isAddState ? Icons.add_circle : Icons.remove_circle),
                  color: isAddState ? Colors.green : Colors.red,
                  iconSize: 40,
                  onPressed: toggleAddState,
                ),
              ],
              backgroundColor: const Color.fromARGB(255, 40, 40, 40),
              elevation: 8,
              iconTheme: const IconThemeData(color: Colors.white),
              actionsIconTheme: const IconThemeData(color: Colors.white),
              leading: IconButton(
                icon: Icon(isConnected
                    ? Icons.bluetooth_connected
                    : Icons.bluetooth),
                onPressed: connectToDevice,
              ),
              bottom: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(
                    text: "Table",
                  ),
                  Tab(text: "Summary"),
                ],
              )),
          body: TabBarView(children: [
            TableTab(),
            SummaryTab(),
          ]),
          bottomSheet: Container(
            height: 60,
            color: Color.fromARGB(255, 40, 40, 40),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text("Total Bunddles: " + ids.length.toString(),
                                    style: TextStyle(color: Colors.white)),
                                Text(
                                    "Total Weight: " +
                                        totalWeight.toStringAsFixed(3),
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          )),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: Icon(Icons.send_and_archive,
                              size: 30, color: Color.fromARGB(255, 255, 255, 255)),
                          onPressed: () async {
              await PdfGenerator.toPdfGen(
                context,
                widget.slipNo.toString(),
                widget.partyName,
                widget.address,
                widget.vehicleNo,
                widget.date,
                widget.time,
                tableData,

              );
            },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SafeArea TableTab() {
    return SafeArea(
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
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4.0),
      color: Color.fromARGB(255, 165, 61, 171).withOpacity(0.4),
      child: Row(
        children: [
          Expanded(
            child: Text('Sno',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            flex: 1,
          ),
          Expanded(
            child: Text('Brand',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            flex: 3,
          ),
          Expanded(
            child: Text('Size',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            flex: 2,
          ),
          Expanded(
            child: Text('Color',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            flex: 2,
          ),
          Expanded(
            child: Text('Weight',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            flex: 2,
          ),
        ],
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

  SafeArea SummaryTab() {
    Map<String, Map<String, dynamic>> summary = {};

    for (var row in tableData) {
      String key = "${row[1]}_${row[2]}_${row[3]}";
      double weight = double.tryParse(row[4]) ?? 0.0;

      if (summary.containsKey(key)) {
        summary[key]!['count'] += 1;
        summary[key]!['totalWeight'] += weight;
      } else {
        summary[key] = {
          'brand': row[1],
          'size': row[2],
          'color': row[3],
          'count': 1,
          'totalWeight': weight,
        };
      }
    }

    return SafeArea(
      child: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.all(4.0),
            color: Color.fromARGB(255, 4, 0, 255).withOpacity(0.4),
            child: Row(
              children: [
                Expanded(
                    child: Text('Brand',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center)),
                Expanded(
                    child: Text('Size',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center)),
                Expanded(
                    child: Text('Color',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center)),
                Expanded(
                    child: Text('Count',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center)),
                Expanded(
                    child: Text('Total Weight',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: summary.length,
              itemBuilder: (context, index) {
                var key = summary.keys.elementAt(index);
                var item = summary[key]!;

                return Container(
                  padding: EdgeInsets.all(4),
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    color: index % 2 == 0
                        ? Color.fromARGB(255, 240, 240, 240)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(item['brand'],
                              textAlign: TextAlign.center)),
                      Expanded(
                          child: Text(item['size'],
                              textAlign: TextAlign.center)),
                      Expanded(
                          child: Text(item['color'],
                              textAlign: TextAlign.center)),
                      Expanded(
                          child: Text(item['count'].toString(),
                              textAlign: TextAlign.center)),
                      Expanded(
                          child: Text(item['totalWeight'].toStringAsFixed(3),
                              textAlign: TextAlign.center)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }



}
