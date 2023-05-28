import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_state.dart';

const List<String> list = <String>['ASC', "DESC"];

class ItemPage extends StatefulWidget {
  const ItemPage({Key? key}) : super(key: key);
  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  String dropdownValue = list.first;

  Stream<QuerySnapshot> getSortedStream() {
    if (dropdownValue == 'ASC') {
      return FirebaseFirestore.instance
          .collection('info')
          .orderBy('price', descending: false)
          .snapshots();
    } else if (dropdownValue == 'DESC') {
      return FirebaseFirestore.instance
          .collection('info')
          .orderBy('price', descending: true)
          .snapshots();
    }

    return FirebaseFirestore.instance.collection('info').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.account_circle,
            semanticLabel: 'profile',
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
        title: const Text('Main'),
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
          DropdownButton<String>(
            value: dropdownValue,
            icon: const Icon(Icons.arrow_downward),
            elevation: 50,
            style: const TextStyle(color: Colors.black),
            onChanged: (String? value) {
              setState(() {
                dropdownValue = value!;
              });
            },
            items: list.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getSortedStream(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                return GridView.count(
                  crossAxisCount: 2,
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;

                    String imageName = data['name'];

                    firebase_storage.Reference storageRef = firebase_storage
                        .FirebaseStorage.instance
                        .ref()
                        .child('Final/' + imageName + '.png');

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
                        String name = data['name'];
                        var price = data['price'];
                        Timestamp timestamp = data['timestamp'];
                        Timestamp? timestampM = data.containsKey('timestampM')
                            ? data['timestampM']
                            : null;
                        String description = data['description'];
                        String url = data['url'];
                        String uid = data['uid'];

                        return Consumer<ApplicationState>(
                          builder: (context, appState, _) {
                            bool isinlist = appState.isIn(name);

                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  if (isinlist == true)
                                    Stack(children: [
                                      AspectRatio(
                                        aspectRatio: 18 / 11,
                                        child: Image.network(
                                          imageUrl!,
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                      Icon(
                                        Icons.check_box,
                                        color: Colors.blue,
                                      )
                                    ]),
                                  if (isinlist == false)
                                    AspectRatio(
                                      aspectRatio: 18 / 11,
                                      child: Image.network(
                                        imageUrl!,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  Expanded(
                                      child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 20, 1, 1),
                                    child: Row(
                                      children: [
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(name),
                                              const SizedBox(height: 5),
                                              Text('\$' + price.toString()),
                                            ]),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(
                                              onPressed: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  '/detail',
                                                  arguments: {
                                                    'name': name,
                                                    'price': price,
                                                    'description': description,
                                                    'timestamp': timestamp,
                                                    'timestampM': timestampM,
                                                    'uid': uid,
                                                    'url': url,
                                                  },
                                                );
                                              },
                                              child: const Text('More'),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
