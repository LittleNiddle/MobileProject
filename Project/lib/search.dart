import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_state.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String formattedDateTime = "";
  List<String> _uids = [];

  void addUid(String roomID, User cuser) async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('rooms').doc(roomID).get();
    _uids = List.from(doc['uid']);
    _uids.add(cuser.uid);
    FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomID)
        .update({'uid': _uids, 'count': FieldValue.increment(1)});
  }

  @override
  Widget build(BuildContext context) {
    final String brand = ModalRoute.of(context)!.settings.arguments as String;

    FirebaseAuth auth = FirebaseAuth.instance;
    User? cuser = auth.currentUser;
    firebase_storage.Reference storageRef = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('Brands/' + brand + '.png');

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
        title: const Text("Search"),
        centerTitle: true,
      ),
      body: Column(
        children: [
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
                  .where('brand', isEqualTo: brand)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 18 / 11,
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;

                      String brandName = data['brand'];
                      Timestamp timestamp = data['timestamp'];
                      String roomID = data['roomId'];
                      DateTime dateTime = timestamp.toDate();
                      formattedDateTime =
                          DateFormat('MM/dd/kk:mm').format(dateTime);
                      String place = data['place'];
                      String count = data['count'].toString();
                      bool isIn = data['uid'].contains(cuser!.uid);

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                        onPressed: () {
                                          if (isIn) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text("이미 방에 입장하였습니다."),
                                                duration: Duration(seconds: 1),
                                              ),
                                            );
                                          } else if (int.parse(count) < 3) {
                                            addUid(roomID, cuser!);
                                            Navigator.pushNamed(
                                                context, '/chat',
                                                arguments: roomID);
                                          }
                                          if (int.parse(count) == 3) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text("방이 가득 찼습니다."),
                                              ),
                                            );
                                          }
                                        },
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