import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String image = "";

  Future<String> defaultImage() async {
    firebase_storage.Reference storageRef = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('Final/Handing.png');
    String url = await storageRef.getDownloadURL();

    image = url;
    return image;
  }

  Widget buildPage(User user) {
    if (user.isAnonymous) {
      String photoURL = image;
      String uid = user.uid;

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: 18 / 11,
                child: Image.network(
                  photoURL,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("<$uid>", style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 30),
                const Text("Anonymous"),
              ],
            ),
          ],
        ),
      );
    } else {
      String photoURL = user.photoURL ?? "";
      String uid = user.uid;
      String? email = user.email;
      String? name = user.displayName;

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (user.photoURL != null)
              Center(
                child: AspectRatio(
                  aspectRatio: 18 / 11,
                  child: Image.network(
                    photoURL,
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("<$uid>", style: TextStyle(fontSize: 20)),
                const SizedBox(height: 10),
                const SizedBox(
                  width: 300,
                  child: Divider(
                    color: Colors.black,
                    height: 2,
                  ),
                ),
                const SizedBox(height: 30),
                Text("$email"),
                const SizedBox(height: 60),
                Text("$name"),
                const SizedBox(height: 10),
                const Text("I promise to take the test honestly before GOD."),
              ],
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? cuser = auth.currentUser;

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
        title: const Text(""),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.logout,
              semanticLabel: 'out',
            ),
            onPressed: () {
              auth.signOut();
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: defaultImage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }

          if (snapshot.hasData) {
            return buildPage(cuser!);
          } else {
            return const Text("Not signed in.");
          }
        },
      ),
    );
  }
}
