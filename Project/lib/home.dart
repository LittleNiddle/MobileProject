import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? cuser = auth.currentUser;
    String? name = cuser!.displayName;

    final _search = TextEditingController();

    return Scaffold(
      appBar: AppBar(
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
              if (_search.text.isNotEmpty) {
                Navigator.pushNamed(context, '/search',
                    arguments: _search.text.toLowerCase());
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(name! + "의 방목록"),
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
                          .child('Brands/' + docs[index]['brand'] + '.png');

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
                                const Divider(
                                  color: Colors.blue,
                                  thickness: 1,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 1, 15, 12),
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
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                  context, '/chat',
                                                  arguments: docs[index]
                                                      ['roomId']);
                                            },
                                            icon: const Icon(Icons.login),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              padding: EdgeInsets.fromLTRB(30, 100, 0, 0),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.only(left: 30.0),
              leading: const Icon(
                Icons.logout,
                color: Colors.blue,
              ),
              title: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              onTap: () {
                auth.signOut();
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.only(left: 30.0),
              leading: const Icon(
                Icons.add,
                color: Colors.blue,
              ),
              title: const Text(
                'Create Room',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/add');
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.only(left: 30.0),
              leading: const Icon(
                Icons.person,
                color: Colors.blue,
              ),
              title: const Text(
                'My page',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              onTap: () {Navigator.pushNamed(context, '/mypage');},
            ),
          ],
        ),
      ),
    );
  }
}
