import 'dart:async';
import 'dart:developer';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper {
  static Database _db;
  static const String DB_NAME = 'database.db';

  static Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  static initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 2, onCreate: _onCreate);
    print(db.path);
    return db;
  }

  static _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE Abonnee(
            abonnee_id INTEGER PRIMARY KEY AUTOINCREMENT,
            abonnee_fullname TEXT,abonnee_type INTEGER,
            abonnee_datebr TEXT);''');

    await db.execute('''
              CREATE TABLE Tournee(
              tournee_id INTEGER PRIMARY KEY AUTOINCREMENT)''');

    await db.execute('''CREATE TABLE Rue(
              rue_id INTEGER PRIMARY KEY AUTOINCREMENT,
              tournee_id INTEGER,
              rue_address TEXT,
              FOREIGN KEY (tournee_id) REFERENCES Tournee(tournee_id))''');

    await db.execute('''CREATE TABLE Relveur(
              relveur_id INTEGER PRIMARY KEY AUTOINCREMENT,
              tournee_id INTEGER,
              relveur_fullname TEXT,
              relveur_username TEXT,
              relveur_password TEXT,
              FOREIGN KEY (tournee_id) REFERENCES Tournee(tournee_id))''');

    await db.execute('''CREATE TABLE Counter(
              counter_id INTEGER PRIMARY KEY AUTOINCREMENT,
              abonnee_id INTEGER,
              rue_id INTEGER,
              counter_index TEXT,
              counter_etat TEXT,
              FOREIGN KEY (abonnee_id) REFERENCES Abonnee(abonnee_id),
              FOREIGN KEY (rue_id ) REFERENCES Rue(rue_id ))''');
  }

  static executeQueries(Database db, int version) async {
    // await db.execute("DROP TABLE Counter; DROP TABLE Relveur; DROP TABLE Rue; DROP TABLE Tournee; DROP TABLE Abonnee; ");

    // await db.execute(
    //     "INSERT INTO Abonnee(abonnee_id,abonnee_fullname, abonnee_type, abonnee_datebr) VALUES (NULL,'ABDO','1','2001'); INSERT INTO Tournee(tournee_id ) VALUES (NULL); INSERT INTO Rue(rue_id,tournee_id,rue_address) VALUES (NULL,1,'1014'); INSERT INTO Relveur(relveur_id,tournee_id,relveur_fullname,relveur_username,relveur_password) VALUES (NULL,1,'haron','har1','password'); INSERT INTO Counter(counter_id,abonnee_id,rue_id,counter_index) VALUES (NULL,1,1,'123332');");
  }

  static Future<Abonnee> saveAbonnee(Abonnee abonnee) async {
    var dbClient = await db;
    abonnee.abonnee_id = await dbClient.insert("Abonnee", abonnee.toMap());
    return abonnee;
    /*
    await dbClient.transaction((txn) async {
      var query = "INSERT INTO $TABLE ($NAME) VALUES ('" + employee.name + "')";
      return await txn.rawInsert(query);
    });
    */
  }

  static Future<Tournee> saveTournee(Tournee tournee) async {
    var dbClient = await db;
    tournee.tournee_id = await dbClient.insert("Tournee", tournee.toMap());
    return tournee;
    /*
    await dbClient.transaction((txn) async {
      var query = "INSERT INTO $TABLE ($NAME) VALUES ('" + employee.name + "')";
      return await txn.rawInsert(query);
    });
    */
  }

  static Future<Rue> saveRue(Rue rue) async {
    var dbClient = await db;
    rue.rue_id = await dbClient.insert("Rue", rue.toMap());
    return rue;
    /*
    await dbClient.transaction((txn) async {
      var query = "INSERT INTO $TABLE ($NAME) VALUES ('" + employee.name + "')";
      return await txn.rawInsert(query);
    });
    */
  }

  static Future<Counter> saveCounter(Counter counter) async {
    var dbClient = await db;
    counter.counter_id = await dbClient.insert("Counter", counter.toMap());
    return counter;
    /*
    await dbClient.transaction((txn) async {
      var query = "INSERT INTO $TABLE ($NAME) VALUES ('" + employee.name + "')";
      return await txn.rawInsert(query);
    });
    */
  }

  static Future<Relveur> saveRelveur(Relveur relveur) async {
    var dbClient = await db;
    relveur.relveur_id = await dbClient.insert("Relveur", relveur.toMap());
    return relveur;
    /*
    await dbClient.transaction((txn) async {
      var query = "INSERT INTO $TABLE ($NAME) VALUES ('" + employee.name + "')";
      return await txn.rawInsert(query);
    });
    */
  }

//SELECT * FROM Relveur WHERE relveur_username='arnu19' AND relveur_password='password'

  static Future<List<Relveur>> getAuth(String username, String password) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.rawQuery(
        "SELECT * FROM Relveur WHERE relveur_username='$username' AND relveur_password='$password'");

    List<Relveur> relveurs = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        relveurs.add(Relveur.fromMap(maps[i]));
      }
    }
    return relveurs;
  }

  static Future<List<JoinData>> getjoinData(int secteurId) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.rawQuery(
        '''SELECT DISTINCT counter_id, abonnee_fullname, rue_address, counter_index
         FROM Abonnee a, Tournee t, Rue r ,Relveur v, Counter c 
         WHERE a.abonnee_id= c.abonnee_id AND r.rue_id=c.rue_id AND r.tournee_id= v.tournee_id AND r.tournee_id=$secteurId''');

    List<JoinData> counters = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        counters.add(JoinData.fromMap(maps[i]));
      }
    }
    return counters;
  }

  static Future<bool> updateCounter(int id, String index) async {
    var dbClient = await db;
    await dbClient
        .execute(
            "UPDATE Counter SET (counter_index) = ('$index') WHERE counter_id=$id")
        .then((onValue) {
      return true;
    }).catchError((onError) {
      return false;
    });
    return false;
  }

  static Future<List<Rue>> getRue() async {
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query("Rue", columns: ["rue_id", "tournee_id", "rue_address"]);
    //List<Map> maps = await dbClient.rawQuery("SELECT * FROM $TABLE");
    List<Rue> rues = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        rues.add(Rue.fromMap(maps[i]));
      }
    }
    return rues;
  }

  static Future<List<Abonnee>> getAbonnees() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query("Abonnee", columns: [
      "abonnee_id",
      "abonnee_fullname",
      "abonnee_type",
      "abonnee_datebr"
    ]);
    //List<Map> maps = await dbClient.rawQuery("SELECT * FROM $TABLE");
    List<Abonnee> employees = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        employees.add(Abonnee.fromMap(maps[i]));
      }
    }
    return employees;
  }

  static Future<int> delete(int id, String table, String testField) async {
    var dbClient = await db;
    return await dbClient
        .delete(table, where: '$testField = ?', whereArgs: [id]);
  }

  static Future<int> update(Abonnee employee) async {
    var dbClient = await db;
    return await dbClient.update("Abonnee", employee.toMap(),
        where: 'abonnee_id = ?', whereArgs: [employee.abonnee_id]);
  }

  static Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}

class Abonnee {
  int abonnee_id;
  String abonnee_fullname, abonnee_datebr;
  int abonnee_type;

  Abonnee(
      {this.abonnee_id,
      this.abonnee_fullname,
      this.abonnee_datebr,
      this.abonnee_type});

  Map<String, dynamic> toMap() {
    return {
      'abonnee_id': abonnee_id,
      'abonnee_fullname': abonnee_fullname,
      'abonnee_datebr': abonnee_datebr,
      'abonnee_type': abonnee_type
    };
  }

  Abonnee.fromMap(Map<String, dynamic> map) {
    abonnee_id = map['abonnee_id'];
    abonnee_fullname = map['abonnee_fullname'];
    abonnee_datebr = map['abonnee_datebr'];
    abonnee_type = map['abonnee_type'];
  }
}

class JoinData {
  int counter_id;
  String abonnee_fullname, rue_address, counter_index;

  JoinData(
      {this.counter_id,
      this.abonnee_fullname,
      this.counter_index,
      this.rue_address});

  Map<String, dynamic> toMap() {
    return {
      'counter_id': counter_id,
      'abonnee_fullname': abonnee_fullname,
      'rue_address': rue_address,
      'counter_index': counter_index
    };
  }

  JoinData.fromMap(Map<String, dynamic> map) {
    counter_id = map['counter_id'];
    abonnee_fullname = map['abonnee_fullname'];
    rue_address = map['rue_address'];
    counter_index = map['counter_index'];
  }
}

class Counter {
  int counter_id, abonnee_id, rue_id;
  String counter_index, counter_etat;

  Counter(
      {this.counter_id,
      this.abonnee_id,
      this.rue_id,
      this.counter_index,
      this.counter_etat});

  Map<String, dynamic> toMap() {
    return {
      'counter_id': counter_id,
      'abonnee_id': abonnee_id,
      'rue_id': rue_id,
      'counter_index': counter_index,
      'counter_etat': counter_etat
    };
  }

  Counter.fromMap(Map<String, dynamic> map) {
    counter_id = map['counter_id'];
    abonnee_id = map['abonnee_id'];
    rue_id = map['rue_id'];
    counter_index = map['counter_index'];
    counter_etat = map['counter_etat'];
  }
}

class Relveur {
  int relveur_id, tournee_id;
  String relveur_fullname, relveur_username, relveur_password;

  Relveur(
      {this.relveur_id,
      this.tournee_id,
      this.relveur_fullname,
      this.relveur_username,
      this.relveur_password});

  Map<String, dynamic> toMap() {
    return {
      'relveur_id': relveur_id,
      'tournee_id': tournee_id,
      'relveur_fullname': relveur_fullname,
      'relveur_username': relveur_username,
      'relveur_password': relveur_password
    };
  }

  Relveur.fromMap(Map<String, dynamic> map) {
    relveur_id = map['relveur_id'];
    tournee_id = map['tournee_id'];
    relveur_fullname = map['relveur_fullname'];
    relveur_username = map['relveur_username'];
    relveur_password = map['relveur_password'];
  }
}

class Rue {
  int rue_id, tournee_id;
  String rue_address;

  Rue({this.rue_id, this.tournee_id, this.rue_address});

  Map<String, dynamic> toMap() {
    return {
      'rue_id': rue_id,
      'tournee_id': tournee_id,
      'rue_address': rue_address,
    };
  }

  Rue.fromMap(Map<String, dynamic> map) {
    rue_id = map['rue_id'];
    tournee_id = map['tournee_id'];
    rue_address = map['rue_address'];
  }
}

class Tournee {
  int tournee_id;

  Tournee({this.tournee_id});

  Map<String, dynamic> toMap() {
    return {
      'tournee_id': tournee_id,
    };
  }

  Tournee.fromMap(Map<String, dynamic> map) {
    tournee_id = map['tournee_id'];
  }
}
