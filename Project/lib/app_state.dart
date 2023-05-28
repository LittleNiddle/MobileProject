import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';

import 'firebase_options.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    //init();
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<dynamic> _items = [];
  String _cuser = "";

  bool isIn(String item) {
    return _items.contains(item);
  }

  void addItem(String item) async {
    User? user = auth.currentUser;
    _cuser = user!.uid;
    DocumentSnapshot doc =
        await firestore.collection('wishlists').doc(_cuser).get();
    _items = List.from(doc['items']);
    _items.add(item);
    firestore.collection('wishlists').doc(_cuser).set({'items': _items});
    notifyListeners();
  }

  void deleteItem(String item) async {
    User? user = auth.currentUser;
    _cuser = user!.uid;
    DocumentSnapshot doc =
        await firestore.collection('wishlists').doc(_cuser).get();
    _items = List.from(doc['items']);
    _items.remove(item);
    firestore.collection('wishlists').doc(_cuser).set({'items': _items});
    notifyListeners();
  }
}
