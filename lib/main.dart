
import 'package:flutter/material.dart';
import 'VU/gestion-compte/vulogin.dart';
import 'providers/selectedexploitationprovider.dart';
import 'package:provider/provider.dart';



void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SelectedExploitationProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agro-Pastoral App',
      theme: ThemeData(),
      home: LoginScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {

    return Scaffold(

    );
  }
}

