import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_state.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;

class WishPage extends StatefulWidget {
  const WishPage({Key? key}) : super(key: key);

  @override
  _WishPageState createState() => _WishPageState();
}

class _WishPageState extends State<WishPage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<List<dynamic>> _getImageNames(String cuser) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('wishlists')
        .doc(cuser)
        .get();
    final items = snapshot.get('items') as List<dynamic>;
    return items;
  }

  Future<String> _getImageUrl(String itemName) async {
    firebase_storage.Reference storageRef = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('Final/' + itemName + '.png');

    final imageUrl = await storageRef.getDownloadURL();
    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    User? user = auth.currentUser;
    String cuid = user!.uid;

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
        title: const Text('Wish List'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Consumer<ApplicationState>(
            builder: (context, appState, child) {
              return FutureBuilder<List<dynamic>>(
                future: _getImageNames(cuid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final imageNames = snapshot.data;

                  return Expanded(
                    child: ListView.builder(
                      itemCount: imageNames?.length,
                      itemBuilder: (context, index) {
                        final imageName = (imageNames![index]);
                        return FutureBuilder<String>(
                          future: _getImageUrl(imageName),
                          builder: (context, imageUrlSnapshot) {
                            if (imageUrlSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (imageUrlSnapshot.hasError) {
                              return const CircularProgressIndicator();
                            }

                            return ListTile(
                              leading: Image.network(imageUrlSnapshot.data!),
                              title: Text(imageName),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  appState.deleteItem(imageName);
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
