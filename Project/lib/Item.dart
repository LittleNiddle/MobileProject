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
        //title: Text(name! + "의 방목록"),
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
                  return GridView.builder(
                    itemCount: docs.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
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
                                      const EdgeInsets.fromLTRB(20, 20, 1, 1),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          Text("브랜드: " + docs[index]['brand']),
                                          const SizedBox(height: 5),
                                          Text(
                                              "배달 장소: " + docs[index]['place']),
                                          const SizedBox(height: 5),
                                          Text("현재 인원: 3/" +
                                              docs[index]['count'].toString()),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () {},
                                        child: const Text('Enter'),
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
