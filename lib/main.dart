import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_taxiapp/AllScreens/loginScreen.dart';
import 'package:flutter_taxiapp/AllScreens/mainScreen.dart';
//import 'file:///C:/Users/user/AndroidStudioProjects/flutter_taxiapp/lib/AllScreens/loginScreen.dart';
import 'package:flutter_taxiapp/AllScreens/registrationScreen.dart';
import 'package:flutter_taxiapp/DataHandler/appData.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

DatabaseReference usersRef = FirebaseDatabase.instance.reference().child("users");


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Taxi App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: MainScreen.idScn,
        routes: {
          RegistrationScreen.idScn:(context) => RegistrationScreen(),
          LoginScreen.idScn:(context) => LoginScreen(),
          MainScreen.idScn:(context) => MainScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

