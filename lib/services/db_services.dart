import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

// simple class
class DbServices {

  static Database? _database; //this line define a database variable which is null of type Database

  static final DbServices instance = DbServices._constructor();

  DbServices._constructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final databaseDirPath = await getApplicationDocumentsDirectory();
    final databasePath = join(databaseDirPath.path, "batch_db.db");
   
    // await deleteDatabase(databasePath);
    _database= await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE slips(id INTEGER PRIMARY KEY AUTOINCREMENT, PartyName TEXT,address TEXT, VehicleNo TEXT, Date TEXT, Time TEXT)"
          
        );
        await db.execute(
          "CREATE TABLE slip_details(id INTEGER PRIMARY KEY AUTOINCREMENT, slip_id INTEGER,UID TEXT, Brand TEXT, Size TEXT, Color TEXT, Weight TEXT)"
          
        );  
      },
    );
    return _database!;
  }


 Future<int> getCurrentSequenceValue() async{
    final db = await database;
    final result = await db.rawQuery('SELECT seq FROM sqlite_sequence where name = "slips"');
  if (result.isNotEmpty) {
    int currentSlipNo = result.first['seq'] as int;
    return currentSlipNo;
  } else {
    
    return 0;
  }
}

  Future<void> insertSlipData(String name, String address, String vehicleNo, String date, String time) async {
    final db = await database;
    await db.insert(
      'slips',
      {'PartyName': name, 'address': address, 'vehicleNo': vehicleNo,'Date': date, 'Time': time},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }



  Future<void> insertBatchData(int slipId,String uID, String brand, String size, String color, String weight) async {
    final db = await database;
    await db.insert(
     'slip_details',
      {'slip_id': slipId, 'UID': uID, 'brand': brand,'size': size, 'color': color, 'weight': weight},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

Future<void> removeBatchData(String uID) async {
  final db = await database;
  await db.delete(
   'slip_details',
    where: 'UID =?',
    whereArgs: [uID],
  );



}


 Future<List<Map<String, Object?>>> readBatchData(final int slipNo) async {
  final db = await instance.database;
    final result = await db.query('slip_details',where: 'slip_id =?',whereArgs: [slipNo]);
    return result;
 }



  Future<List<Map<String, Object?>>> readSlipData() async {
    final db = await instance.database;
    final result = await db.query('slips');
   return result;
  }
  


  Future<void> clearAllData() async {
    final db = await instance.database;
    // Delete all rows
    
    await db.delete('slips');
    await db.delete('slip_details');
    // Reset the AUTOINCREMENT value
    await db.execute("DELETE FROM sqlite_sequence WHERE name='slips'");
  }

}




class SharedPrefsHelper {
  // Keys for the shared preferences
  static const String keyCompanyName = 'companyName';
  static const String keyCompanyAddress = 'companyAddress';


  // Function to save data to SharedPreferences
  static Future<void> saveData(int slipNumber, String companyName, String companyAddress) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
  
    await prefs.setString(keyCompanyName, companyName);
    await prefs.setString(keyCompanyAddress, companyAddress);

  }


  // Function to update company name
  static Future<void> updateCompanyName(String companyName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyCompanyName, companyName);
  }

  // Function to update company address
  static Future<void> updateCompanyAddress(String companyAddress) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyCompanyAddress, companyAddress);
  }



  // Function to get all data
  static Future<Map<String, dynamic>> getAllData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      
      keyCompanyName: prefs.getString(keyCompanyName) ?? '',
      keyCompanyAddress: prefs.getString(keyCompanyAddress) ?? '',

    };
  }
}

