import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth auth = FirebaseAuth.instance;
User? user = auth.currentUser;
String uid = user!.uid;

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController brand = TextEditingController();
  final TextEditingController place = TextEditingController();
  final TextEditingController account = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? cuser = auth.currentUser;
    String? name = cuser!.displayName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('방 생성', style: TextStyle(fontSize: 20)),
        centerTitle: true,
        leading: Flexible(
          child: TextButton(
            child: const Text('Cancel', style: TextStyle(fontSize: 10)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Create'),
            onPressed: () async {
              DocumentReference docRef =
                  await FirebaseFirestore.instance.collection('rooms').add({
                'brand': brand.text,
                'timestamp': FieldValue.serverTimestamp(),
                'place': place.text,
                'count': 0,
                'uid': [uid],
                'account': account.text,
              });

              docRef.update({'roomId': docRef.id});

              docRef.collection('texts').doc(uid).set({
                'text': name! + "님이 입장하셨습니다.",
                'timestamp': FieldValue.serverTimestamp(),
              });

              FirebaseFirestore.instance.collection('users').doc(uid).set({
                'rooms': FieldValue.arrayUnion([docRef.id])
              }, SetOptions(merge: true));
            },
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: () async {},
            ),
          ),
          TextField(
            controller: brand,
            decoration: const InputDecoration(hintText: 'Brand Name'),
          ),
          TextField(
            controller: place,
            decoration: const InputDecoration(hintText: '장소'),
          ),
          TextField(
            controller: account,
            decoration: const InputDecoration(hintText: '계좌번호'),
          ),
        ],
      ),
    );
  }
}
