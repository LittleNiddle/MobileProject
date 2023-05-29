import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({Key? key}) : super(key: key);
  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? cuser = auth.currentUser;
    String? name = cuser!.displayName;

    final _search = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.logout,
            semanticLabel: 'logout',
          ),
          onPressed: () {
            auth.signOut();
            Navigator.pop(context);
          },
        ),
        title: Expanded(
          child: Container(
            height: 35,
            child: TextFormField(
              textAlign: TextAlign.start,
              style: TextStyle(color: Colors.black, fontSize: 20),
              controller: _search,
              decoration: const InputDecoration(
                hintStyle: TextStyle(fontSize: 14),
                hintText: '브랜드 명을 입력하세요',
                fillColor: Colors.white,
                filled: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '브랜드 명을 입력해 주세요';
                } else {
                  return null;
                }
              },
            ),
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.search,
              semanticLabel: 'search',
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/search', arguments: _search.text);
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.add,
              semanticLabel: 'add',
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/add');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Text(name! + "의 방목록"),
              IconButton(
                icon: const Icon(
                  Icons.search,
                  semanticLabel: 'search',
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/search');
                },
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('rooms').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  final docs = snapshot.data!.docs
                      .where((doc) => doc['uid'].contains(cuser!.uid))
                      .toList();
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      firebase_storage.Reference storageRef = firebase_storage
                          .FirebaseStorage.instance
                          .ref()
                          .child(docs[index]['brand'] + '.png');

                      return FutureBuilder<String>(
                        future: storageRef.getDownloadURL(),
                        builder: (BuildContext context,
                            AsyncSnapshot<String> imageUrlSnapshot) {
                          if (imageUrlSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (imageUrlSnapshot.hasError) {
                            return Text('Error: ${imageUrlSnapshot.error}');
                          }

                          String? imageUrl = imageUrlSnapshot.data;

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(
                                color: Colors.blue.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: <Widget>[
                                AspectRatio(
                                  aspectRatio: 18 / 11,
                                  child: Image.network(
                                    imageUrl!,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 5, 15, 1),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "브랜드: " + docs[index]['brand']),
                                            Text("배달 장소: " +
                                                docs[index]['place']),
                                            Text("현재 인원: 3/" +
                                                docs[index]['count']
                                                    .toString()),
                                          ],
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          child: IconButton(
                                            onPressed: () {},
                                            icon: Icon(Icons.login),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
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
