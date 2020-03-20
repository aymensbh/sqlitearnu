import 'dart:ui';

import 'package:arnusqlite/dbHelper.dart';
import 'package:flutter/material.dart';

main(List<String> args) async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  final int sect;
  final String fullname;

  const HomePage({Key key, this.sect, this.fullname}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<JoinData> joinData;
  TextEditingController indexController;

  @override
  void initState() {
    DBHelper.initDb();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.fullname + " Tounée: " + widget.sect.toString())),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (ctx) {
            return AuthPage();
          }));
          // await DBHelper.saveRue(
          //     Rue(tournee_id: 2, rue_address: "8mai", rue_id: null));
          // await DBHelper.saveCounter(Counter(
          //     rue_id: 3,
          //     abonnee_id: 2,
          //     counter_id: null,
          //     counter_etat: "wtf",
          //     counter_index: "420"));

          // setState(() {
          //   abonnees.insert(0, onValue);
          // });
        },
        child: Icon(Icons.exit_to_app),
      ),
      body: FutureBuilder(
        future: DBHelper.getjoinData(widget.sect),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            joinData = snapshot.data;
            return ListView.builder(
                itemCount: joinData.length,
                itemBuilder: (context, index) {
                  print(joinData[index].abonnee_fullname);
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          joinData[index].abonnee_fullname,
                          style: TextStyle(fontSize: 22),
                        ),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: "Counter index: ",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontStyle: FontStyle.italic)),
                            TextSpan(
                                text: joinData[index].counter_index,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ]),
                        )
                      ],
                    ),
                    // title: Text(joinData[index].abonnee_fullname +
                    //     " Counter index: " +
                    //     joinData[index].counter_index),
                    subtitle: Text(joinData[index].rue_address.toString()),
                    trailing: IconButton(
                        icon: Icon(Icons.edit,color: Colors.teal,),
                        onPressed: () {
                          indexController = new TextEditingController(
                              text: joinData[index].counter_index);
                          _modifyIndex(index, joinData[index].counter_id)
                              .then((onValue) {
                            setState(() {
                              print("new Index: " + onValue);
                              joinData[index].counter_index = onValue;
                            });
                          });
                        }),
                  );
                });
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<String> _modifyIndex(int index, int id) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: TextField(
              keyboardType: TextInputType.phone,
              controller: indexController,
              decoration: InputDecoration(hintText: "index"),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel",style: TextStyle(color: Colors.grey),)),
              FlatButton(
                  onPressed: () {
                    if (indexController.text.isEmpty) {
                      Navigator.pop(context);
                    } else {
                      DBHelper.updateCounter(id, indexController.text.trim())
                          .then((onValue) {
                        setState(() {
                          print("new Index: " + indexController.text.trim());
                          joinData[index].counter_index =
                              indexController.text.trim();
                        });
                        Navigator.of(context).pop();
                      });
                    }
                  },
                  child: Text("Save",style: TextStyle(color: Colors.green))),
            ],
          );
        });
  }
}

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String username, password;
  GlobalKey<FormState> key = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("login"),
      ),
      body: Form(
        key: key,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                validator: (input) {
                  if (input.isEmpty) return "provide username";
                },
                onSaved: (input) {
                  username = input.trim();
                },
                decoration: InputDecoration(
                  labelText: "username",
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                  errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red)),
                  focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                obscureText: true,
                validator: (input) {
                  if (input.isEmpty) return "provide password";
                },
                onSaved: (input) {
                  password = input.trim();
                },
                decoration: InputDecoration(
                  labelText: "password",
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                  errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red)),
                  focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red)),
                ),
              ),
            ),
            RaisedButton(
                onPressed: () async {
                  if (key.currentState.validate()) {
                    key.currentState.save();
                    List<Relveur> relveurs =
                        await DBHelper.getAuth(username, password);
                    if (relveurs.isEmpty) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return SimpleDialog(
                              elevation: 2,
                              contentPadding: EdgeInsets.all(20),
                              title: Text("Ops! Something went wrong!"),
                              children: <Widget>[
                                Text("Can't log you in with these cridentials")
                              ],
                            );
                          });
                    } else {
                      Navigator.of(context)
                          .pushReplacement(MaterialPageRoute(builder: (ctx) {
                        return HomePage(
                          sect: relveurs[0].tournee_id,
                          fullname: relveurs[0].relveur_fullname,
                        );
                      }));
                    }
                  }
                },
                child: Text("connecter"))
          ],
        ),
      ),
    );
  }
}
