import 'package:bar_sender/services/db_services.dart';
import 'package:bar_sender/views/table_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';




var cards =[];


class StartScreen extends StatefulWidget {

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final listFinish=[["1586","Prateek Tripathi kanpur","Up23bg23"],["2","Ashish","UP77AT5202"],["3","Raman","UP77AT5202"]];
  
  TextEditingController partyNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController vehicleNoController = TextEditingController();
  final FocusNode focusNode2 = FocusNode();
  final FocusNode focusNode3 = FocusNode();
  int slipNo=0; 

  @override
  void initState() {
    super.initState();
    initializeSlipNo();
  }

  Future<void> initializeSlipNo() async {
    int currentSlipNo = await DbServices.instance.getCurrentSequenceValue();
    setState(() {
      slipNo = currentSlipNo+1;
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree
    partyNameController.dispose();
    addressController.dispose();
    vehicleNoController.dispose();
    focusNode2.dispose();
    focusNode3.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Start',
          style: TextStyle(color: Colors.white), // Change text color to white
        ),
        backgroundColor: const Color.fromARGB(255, 40, 40, 40), // Set app bar color to amber
        elevation: 8, // Add elevation for shadow effect
        iconTheme: const IconThemeData(color: Colors.white), // Change icon color to white
        actionsIconTheme: const IconThemeData(color: Colors.white), // Change actions icon color to white
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_sharp), // User icon on the left side
          onPressed: () {
            Navigator.pop(context);
          },
        ),

      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            
                  Text("Slip No. : $slipNo",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const  SizedBox(height: 20),
                  TextField(
                      controller: partyNameController,
                      decoration: const InputDecoration(
                      labelText: "Party Name",
                      border: OutlineInputBorder(),
                    ),
                autofocus: true,
                onSubmitted: (String value) {
                  FocusScope.of(context).requestFocus(focusNode2);
                },
                    ),
                  const SizedBox(height: 10),
                  TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                      labelText: "Address",
                      border: OutlineInputBorder(),
                    ),
                    focusNode: focusNode2,
                onSubmitted: (String value) {
                  FocusScope.of(context).requestFocus(focusNode3);
                },
                    
                    ),
                  const SizedBox(height: 10),
                  TextField(
                      controller: vehicleNoController,
                      decoration: const InputDecoration(
                      labelText: "Vehicle No",
                      border: OutlineInputBorder(),
                    ),
                    focusNode: focusNode3,
                    ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Spacer(),
                      ElevatedButton(onPressed: toTableView ,
                      style: ElevatedButton.styleFrom(elevation: 8,backgroundColor: const Color.fromARGB(255, 40, 40, 40)),
                      child: const Row(
                        children: [
                           Text("Start",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                           SizedBox(width: 5),
                           Icon(Icons.barcode_reader,color: Colors.white),
                        ],
                      ),
                      ),
            
                    ],
                  ),
              ],
            ),
          ),
        )
      ),
      
      );
  }

  void toTableView() {
    String partyName = partyNameController.text;
    String address = addressController.text;
    String vehicleNo = vehicleNoController.text;   
    DateTime now = DateTime.now();
    String currentDate = DateFormat('dd-MM-yyyy').format(now);
    String currentTime = DateFormat('HH:mm:ss').format(now);
    DbServices.instance.insertSlipData(partyName, address, vehicleNo,currentDate,currentTime); // Insert data into the database
    Navigator.pop(context);
    Navigator.of(context)

        .push(MaterialPageRoute(builder: (context) => TableScreen(slipNo: slipNo, partyName: partyName, address: address, vehicleNo: vehicleNo,date: currentDate,time: currentTime)));
        
  }

}
