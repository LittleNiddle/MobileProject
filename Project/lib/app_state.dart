import 'dart:async' show Future, Stream;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:flutter/material.dart';

class ApplicationState extends ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference rooms =
      FirebaseFirestore.instance.collection('rooms');

  Future<void> addMessage(String message, String roomID) async {
    User? cuser = auth.currentUser;
    CollectionReference texts = rooms.doc(roomID).collection('texts');

    await texts.add({
      'text': message,
      'userId': cuser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'photoURL': cuser.photoURL,
      'name': cuser.displayName
    });
  }

  Stream<QuerySnapshot> getMessages(String roomID) {
    CollectionReference texts = rooms.doc(roomID).collection('texts');
    return texts.orderBy('timestamp', descending: false).snapshots();
  }
}
