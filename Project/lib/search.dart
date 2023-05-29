import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_state.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({Key? key}) : super(key: key);
  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  String formattedDateTime = "";
  final TextEditingController brand = TextEditingController();
  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? cuser = auth.currentUser;
    firebase_storage.Reference storageRef = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child(brand.text + '.png');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            semanticLabel: 'back',
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("검색"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Row(
            children: [
              TextField(
                controller: brand,
                decoration: const InputDecoration(hintText: '브랜드 명'),
              ),
              const Icon(Icons.search),
            ],
          ),
          FutureBuilder<String>(
            future: storageRef.getDownloadURL(),
            builder:
                (BuildContext context, AsyncSnapshot<String> imageUrlSnapshot) {
              if (imageUrlSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (imageUrlSnapshot.hasError) {
                return Text('Error: ${imageUrlSnapshot.error}');
              }
              String? imageUrl = imageUrlSnapshot.data;
              return AspectRatio(
                aspectRatio: 18 / 11,
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.fitWidth,
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('rooms')
                  .where('brand', isEqualTo: brand.text)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return GridView.count(
                    crossAxisCount: 2,
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;

                      String brandName = data['brand'];
                      Timestamp timestamp = data['timestamp'];
                      DateTime dateTime = timestamp.toDate();
                      formattedDateTime =
                          DateFormat('yyyy/MM/dd/kk/mm').format(dateTime);
                      String place = data['place'];
                      String count = data['count'];

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 1, 1),
                              child: Row(
                                children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text("브랜드: " + brandName),
                                        Text("배달 장소: " + place),
                                        Text("현재 인원: 3/" + count.toString()),
                                        Text("생성 시간: " + formattedDateTime),
                                      ]),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                        onPressed: () {},
                                        icon: const Icon(Icons.login),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
