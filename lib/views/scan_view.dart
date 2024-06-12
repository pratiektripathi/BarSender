import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<BluetoothDevice> pairedDevicesList = [];
  bool? isBluetoothAvailable;
  bool isRefreshing = false;
  BluetoothDevice? selectedDevice;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    loadSelectedDevice();
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

  Future<void> initBluetooth() async {
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

  Future<void> getBondedDevices() async {
    try {
      // Request for paired devices
      List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      setState(() {
        pairedDevicesList = devices.reversed.toList();
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

  Future<void> _refreshDevices() async {
    setState(() {
      isRefreshing = true;
    });
    await getBondedDevices();
    setState(() {
      isRefreshing = false;
    });
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

  Future<void> saveSelectedDevice(BluetoothDevice device) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> deviceMap = {
      'name': device.name,
      'address': device.address,
    };
    String jsonDevice = jsonEncode(deviceMap);
    prefs.setString('selected_device', jsonDevice);
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
        child: RefreshIndicator(
          onRefresh: _refreshDevices,
          child: DeviceList(
            pairedDevicesList: pairedDevicesList,
            isRefreshing: isRefreshing,
            selectedDevice: selectedDevice,
            onSelect: (device) {
              setState(() {
                selectedDevice = device;
              });
              saveSelectedDevice(device);
            },
          ),
        ),
      ),
    );
  }
}

class DeviceList extends StatelessWidget {
  final List<BluetoothDevice> pairedDevicesList;
  final bool isRefreshing;
  final BluetoothDevice? selectedDevice;
  final Function(BluetoothDevice) onSelect;

  const DeviceList({
    Key? key,
    required this.pairedDevicesList,
    required this.isRefreshing,
    required this.selectedDevice,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        var device = pairedDevicesList[index];
        bool isSelected = selectedDevice != null && selectedDevice!.address == device.address;
        return Card(
          color: isSelected ? Color.fromARGB(255, 42, 42, 42) : null,
          child: ListTile(
            leading: Icon(isSelected ? Icons.bluetooth_connected : Icons.bluetooth, color: isSelected ? Colors.white : Colors.black,),
            title: Text(device.name?.isEmpty ?? true ? 'Unknown Device' : device.name!, style: 
            TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
            subtitle: Text(device.address,style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
            onTap: () {
              onSelect(device);
            },
          ),
        );
      },
      itemCount: pairedDevicesList.length,
    );
  }
}
