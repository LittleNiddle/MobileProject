import 'package:flutter/material.dart';
import 'Item.dart';
import 'login.dart';
import 'Profile.dart';
import 'add.dart';
import 'modify.dart';
import 'app_state.dart';
import 'calculator.dart';
import 'search.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "",
      initialRoute: '/',
      routes: {
        '/edit': (BuildContext context) => const EditPage(),
        '/add': (BuildContext context) => const AddPage(),
        '/item': (BuildContext context) => const ItemPage(),
        '/profile': (BuildContext context) => const ProfilePage(),
        '/calculate': (BuildContext context) => const CalculatePage(),
        '/search': (BuildContext context) => const SearchPage(),
        '/': (BuildContext context) => const LoginPage(),
      },
    );
  }
}
