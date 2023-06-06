import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalculatePage extends StatefulWidget {
  const CalculatePage({Key? key}) : super(key: key);
  @override
  State<CalculatePage> createState() => _CalculatePageState();
}

class _CalculatePageState extends State<CalculatePage> {
  final _user1Controller = TextEditingController();
  final _user2Controller = TextEditingController();
  final _user3Controller = TextEditingController();
  final _deliveryController = TextEditingController();
  final _countController = TextEditingController();
  final _accountController = TextEditingController();

  int total = 0, delivery = 0, count = 0;
  int pay1 = 0, pay2 = 0, pay3 = 0;
  String message = "";

  final _formKey = GlobalKey<FormState>();

  void addChartInfo(String brand) async {
    final CollectionReference roomsCollection =
        FirebaseFirestore.instance.collection('rooms');
    final CollectionReference chartCollection =
        FirebaseFirestore.instance.collection('MyChart');

// Get all documents from 'rooms' collection
    final QuerySnapshot roomsSnapshot = await roomsCollection.get();

// Iterate over each document in 'rooms'
    for (final doc in roomsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        // Check if 'uid' field exists and is a List
        if (data['uid'] is List) {
          final uidList = data['uid'] as List<dynamic>;

          // Iterate over each 'uid' in the list
          for (final uid in uidList) {
            // Access the document in 'Chart' collection with 'uid' as the document ID
            final docRef = chartCollection.doc(uid);

            final brandsCollection = docRef.collection('Brands');

            final brandDocRef = brandsCollection.doc(brand);
            await brandDocRef.set({
              'count': FieldValue.increment(1),
              'brand': brand,
            });
          }
        }
      }
    }
  }

  void calculate() {
    pay1 = int.parse(_user1Controller.text);
    pay2 = int.parse(_user2Controller.text);
    pay3 = int.parse(_user3Controller.text);
    delivery = int.parse(_deliveryController.text);
    count = int.parse(_countController.text);

    total = pay1 + pay2 + pay3 + delivery;
    pay1 += delivery ~/ count;
    pay2 += delivery ~/ count;
    pay3 += delivery ~/ count;
  }

  void makeMessage() {
    String account = _accountController.text;
    message =
        ("User1: $pay1원\nUser2: $pay2원\nUser3: $pay3원\n총액: $total원\n계좌: $account");
  }

  @override
  Widget build(BuildContext context) {
    final String brand = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: const Text("정산하기"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              children: <Widget>[
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _user1Controller,
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: 'user1',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'user가 없다면 0을 입력해 주세요';
                    } else {
                      if (RegExp(r"^\d+$").hasMatch(value)) {
                        return null;
                      } else {
                        return '숫자만 입력해야 합니다!';
                      }
                    }
                  },
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _user2Controller,
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: 'user2',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'user가 없다면 0을 입력해 주세요';
                    } else {
                      if (RegExp(r"^\d+$").hasMatch(value)) {
                        return null;
                      } else {
                        return '숫자만 입력해야 합니다!';
                      }
                    }
                  },
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _user3Controller,
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: 'user3',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'user가 없다면 0을 입력해 주세요';
                    } else {
                      if (RegExp(r"^\d+$").hasMatch(value)) {
                        return null;
                      } else {
                        return '숫자만 입력해야 합니다!';
                      }
                    }
                  },
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _deliveryController,
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: '배달비',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '배달비가 없다면 0을 입력해 주세요!';
                    } else {
                      if (RegExp(r"^\d+$").hasMatch(value)) {
                        return null;
                      } else {
                        return '숫자만 입력해야 합니다!';
                      }
                    }
                  },
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _countController,
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: '인원 수',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '인원 수를 입력해 주세요!';
                    } else {
                      if (RegExp(r"^\d+$").hasMatch(value)) {
                        return null;
                      } else {
                        return '숫자만 입력해야 합니다!';
                      }
                    }
                  },
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _accountController,
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: '계좌번호',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '계좌번호를 입력해주세요!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12.0),
                OverflowBar(
                  alignment: MainAxisAlignment.end,
                  children: <Widget>[
                    ElevatedButton(
                      child: const Text('정산하기'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          calculate();
                          makeMessage();
                          addChartInfo(brand);
                          Clipboard.setData(ClipboardData(text: message));
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                            //Navigator.pushNamed(context, '/chatting');
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
