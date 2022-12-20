import 'package:app/db/DatabaseProvider.dart';
import 'package:app/view/ListScreen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final DatabaseProvider databaseProvider = DatabaseProvider();
  await databaseProvider.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "App",
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFEFEFEF)
        ),
        home: const ListScreen()
    );
  }
}
