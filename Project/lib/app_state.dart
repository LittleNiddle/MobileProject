import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';

import 'firebase_options.dart';

class ApplicationState extends ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference rooms =
      FirebaseFirestore.instance.collection('rooms');

  Future<void> addMessage(String message, String roomID) async {
    User? Cuser = auth.currentUser;
    CollectionReference texts = rooms.doc(roomID).collection('texts');

    texts.add({
      'text': message,
      'userId': Cuser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMessages(String roomID) {
    CollectionReference texts = rooms.doc(roomID).collection('texts');
    return texts.orderBy('timestamp', descending: true).snapshots();
  }
}
