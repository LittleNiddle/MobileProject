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
        title: Text(name! + "의 방목록"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.shopping_cart,
              semanticLabel: 'cart',
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/wishlist');
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
                              borderRadius:
                                  BorderRadius.circular(15), // 카드 모서리 둥글게
                              side: BorderSide(
                                color:
                                    Colors.blue.withOpacity(0.5), // 카드 테두리 색상
                                width: 2, // 카드 테두리 두께
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
                                          child: FloatingActionButton(
                                            onPressed: () {},
                                            child: Icon(Icons.login),
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
