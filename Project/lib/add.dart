import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  void NumberCreate(String brandName) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    await firestore.collection('ChartInfo').doc(brandName).set({
      'count': FieldValue.increment(1),
      'brand': brandName,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    String uid = user!.uid;
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
                    'brand': brand.text.toLowerCase(),
                    'timestamp': FieldValue.serverTimestamp(),
                    'place': place.text,
                    'count': 1,
                    'uid': [uid],
                    'account': account.text,
                  });
                  docRef.update({'roomId': docRef.id});

                  NumberCreate(brand.text.toLowerCase());
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            Column(
              children: [
                const SizedBox(height: 30.0),
                TextFormField(
                  controller: brand,
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: '브랜드 명',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '브랜드 명을 입력해주세요.';
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: place,
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: '장소',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '장소를 입력해 주세요.';
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: account,
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: '계좌 번호',
                  ),
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
          ],
        ),
      ),
    );
  }
}
