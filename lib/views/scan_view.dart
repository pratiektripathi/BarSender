import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanView extends StatelessWidget {
  const ScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BarSender',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ScanScreen(),
    );
  }
}

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<BluetoothDevice> pairedDevicesList = [];
  bool? isBluetoothAvailable;

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    if (await Permission.bluetooth.isGranted &&
        await Permission.bluetoothConnect.isGranted &&
        await Permission.bluetoothScan.isGranted &&
        await Permission.location.isGranted) {
      initBluetooth();
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.location,
      ].request();

      if (statuses[Permission.bluetooth]!.isGranted &&
          statuses[Permission.bluetoothConnect]!.isGranted &&
          statuses[Permission.bluetoothScan]!.isGranted &&
          statuses[Permission.location]!.isGranted) {
        initBluetooth();
      } else {
        // Show an error message if permissions are not granted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissions not granted'),
          ),
        );
      }
    }
  }

  void initBluetooth() async {
    // Check if Bluetooth is available
    isBluetoothAvailable = await FlutterBluetoothSerial.instance.isAvailable;

    if (isBluetoothAvailable == true) {
      getBondedDevices();
    } else {
      // Show an error message if Bluetooth is not available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bluetooth is not available on this device'),
        ),
      );
    }
  }

  void getBondedDevices() async {
    try {
      // Request for paired devices
      List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      setState(() {
        pairedDevicesList = devices;
      });
    } catch (e) {
      // Handle the error
      print("Error getting bonded devices: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting bonded devices: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Devices',
          style: TextStyle(color: Colors.white),
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))],
        backgroundColor: const Color.fromARGB(255, 40, 40, 40),
        elevation: 8,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Device(pairedDevicesList: pairedDevicesList),
      ),
    );
  }
}

class Device extends StatelessWidget {
  final List<BluetoothDevice> pairedDevicesList;

  const Device({Key? key, required this.pairedDevicesList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.builder(
        itemBuilder: (context, index) {
          var device = pairedDevicesList[index];
          return Card(
            child: ListTile(
              title: Text(device.name?.isEmpty ?? true ? 'Unknown Device' : device.name!),
              subtitle: Text(device.address),
            ),
          );
        },
        itemCount: pairedDevicesList.length,
      ),
    );
  }
}
