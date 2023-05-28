import 'package:flutter/material.dart';
import 'Item.dart';
import 'login.dart';
import 'Datail.dart';
import 'Profile.dart';
import 'Wishlist.dart';
import 'add.dart';
import 'modify.dart';
import 'app_state.dart';

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
        '/detail': (BuildContext context) => const DetailPage(),
        '/profile': (BuildContext context) => const ProfilePage(),
        '/wishlist': (BuildContext context) => const WishPage(),
        '/': (BuildContext context) => const LoginPage(),
      },
      theme: ThemeData.light(useMaterial3: true),
    );
  }
}
