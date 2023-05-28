import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_state.dart';
import 'package:provider/provider.dart';

String formattedDateTimeM = "";
String formattedDateTime = "";
String gname = "";
int _counter = 0;

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  void initState() {
    super.initState();
    getCounter();
  }

  late Future<int> counterFuture;

  Future<int> getCounter() async {
    final docSnap = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: gname)
        .get();
    final docData = docSnap.docs.first;

    setState(() {
      _counter = docData['count'];
    });

    return _counter;
  }

  Future<void> firstAddCounter() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    String curuser = user!.uid;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore
        .collection('users')
        .where('name', isEqualTo: gname)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update(
            {'count': FieldValue.increment(1), 'uid$_counter': curuser});
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('I LIKE IT !'),
      ),
    );
  }

  Future<void> addCounter() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    String curuser = user!.uid;

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot shot = await firestore
        .collection('users')
        .where('name', isEqualTo: gname)
        .get();

    var doc = shot.docs[0];
    bool uidExists = false;

    for (int i = 0; i < _counter; i++) {
      if (doc['uid$i'] == curuser) {
        uidExists = true;
        break;
      }
    }

    if (uidExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('you can only do it once !!'),
        ),
      );
    } else {
      shot.docs.forEach((doc) {
        doc.reference.update(
            {'count': FieldValue.increment(1), 'uid$_counter': curuser});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('I LIKE IT !'),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String name = args['name']!;
    var price = args['price']!;
    final String description = args['description'];
    final String uid = args['uid'];
    final String imageUrl = args['url'];
    final Timestamp timestamp = args['timestamp'];
    final Timestamp? timestampM = args['timestampM'];
    gname = name;

    DateTime dateTime = timestamp.toDate();
    formattedDateTime = DateFormat('yyyy-MM-dd-kk:mm').format(dateTime);

    if (timestampM != null) {
      DateTime dateTime = timestampM.toDate();
      formattedDateTimeM = DateFormat('yyyy-MM-dd-kk:mm').format(dateTime);
    }

    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    String cuid = user!.uid;

    void removeItem(String name) async {
      FirebaseFirestore.instance.collection('wishlists').doc(cuid).update({
        'items': FieldValue.arrayRemove([name])
      }).then((_) {
        print("value removed successfully");
      }).catchError((error) {
        print("Failed to remove value: $error");
      });
    }

    void delete(String product) async {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference info = firestore.collection('info');
      CollectionReference users = firestore.collection('users');

      QuerySnapshot infoSnapshot =
          await info.where('name', isEqualTo: product).get();
      for (var doc in infoSnapshot.docs) {
        await doc.reference.delete();
      }

      QuerySnapshot userSnapshot =
          await users.where('name', isEqualTo: product).get();
      for (var doc in userSnapshot.docs) {
        await doc.reference.delete();
      }

      firebase_storage.Reference storeRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('Final/' + name + '.png');

      storeRef.delete();
    }

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
        title: const Text('Detail'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.create,
              semanticLabel: 'edit',
            ),
            onPressed: () {
              if (uid == cuid) {
                Navigator.pushNamed(
                  context,
                  '/edit',
                  arguments: name,
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.delete,
              semanticLabel: 'delete',
            ),
            onPressed: () {
              if (uid == cuid) {
                delete(name);
                removeItem(name);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 18 / 11,
              child: Image.network(
                imageUrl,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return const Center(
                      child: Icon(Icons.circle_outlined, size: 100));
                },
                fit: BoxFit.fitWidth,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 1, 1),
              child: Row(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Column(
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '\$' + price!.toString(),
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 150),
                              IconButton(
                                icon: const Icon(
                                  Icons.thumb_up,
                                  semanticLabel: 'up',
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  if (_counter == 0) {
                                    firstAddCounter();
                                  } else {
                                    addCounter();
                                  }
                                },
                              ),
                              FutureBuilder<int>(
                                future: getCounter(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<void> snapshot) {
                                  if (snapshot.hasData) {
                                    return Text('$_counter');
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const SizedBox(
                            width: 300,
                            child: Divider(
                              color: Colors.black,
                              height: 2,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(description!),
                        ]),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Text('Creator<' + uid! + '>'),
            Text(formattedDateTime + ' Created'),
            if (timestampM != null) Text(formattedDateTimeM + ' Modified'),
          ],
        ),
      ]),
      floatingActionButton: Consumer<ApplicationState>(
        builder: (context, appState, child) {
          bool isInList = appState.isIn(name);

          return FloatingActionButton(
            onPressed: () {
              if (isInList) {
                appState.deleteItem(name);
              } else {
                appState.addItem(name);
              }
            },
            child: Icon(isInList ? Icons.check : Icons.shopping_cart),
          );
        },
      ),
    );
  }
}
