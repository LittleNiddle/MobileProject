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

    final _formKey = GlobalKey<FormState>();

    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('방 생성', style: TextStyle(fontSize: 20)),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  DocumentReference docRef =
                      await FirebaseFirestore.instance.collection('rooms').add({
                    'brand': brand.text,
                    'timestamp': FieldValue.serverTimestamp(),
                    'place': place.text,
                    'count': 1,
                    'uid': [uid],
                    'account': account.text,
                  });
                  docRef.update({'roomId': docRef.id});
    
                  // docRef.collection('texts').add({
                  //   'text': name! + "님이 입장하셨습니다.",
                  //   'timestamp': FieldValue.serverTimestamp(),
                  //   'userId': cuser.uid,
                  //   'name': cuser.displayName,
                  //   'photoURL': cuser.photoURL,
                  // });
                  // FirebaseFirestore.instance.collection('users').doc(uid).set({
                  //   'rooms': FieldValue.arrayUnion([docRef.id])
                  // }, SetOptions(merge: true));
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: ListView(
          children: <Widget>[
            TextFormField(
              controller: brand,
              decoration: const InputDecoration(hintText: '브랜드 명'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '브랜드 명을 입력해주세요.';
                } else {
                  return null;
                }
              },
            ),
            TextFormField(
              controller: place,
              decoration: const InputDecoration(hintText: '장소'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '장소를 입력해 주세요.';
                } else {
                  return null;
                }
              },
            ),
            TextFormField(
              controller: account,
              decoration: const InputDecoration(hintText: '계좌번호'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '계좌를 입력해 주세요.';
                } else {
                  return null;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
