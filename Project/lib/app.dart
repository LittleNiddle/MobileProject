import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart';
import 'add.dart';
import 'calculator.dart';
import 'chat.dart';
import 'mypage.dart';
import 'search.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "",
      initialRoute: '/',
      routes: {
        '/add': (BuildContext context) => const AddPage(),
        '/home': (BuildContext context) => const HomePage(),
        '/calculate': (BuildContext context) => const CalculatePage(),
        '/search': (BuildContext context) => const SearchPage(),
        '/chat': (BuildContext context) => const ChatPage(),
        '/mypage': (BuildContext context) => const MyPage(),
        '/': (BuildContext context) => const LoginPage(),
      },
    );
  }
}
