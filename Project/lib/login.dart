import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<void> signInAdd() async {
    FirebaseFirestore.instance.collection('user').add({});
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<UserCredential> signInWithGoogle() async {
    await googleSignIn.signOut();
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "DeliWith",
                style: TextStyle(
                  fontSize: 90,
                  color: Color(0xff0084ff),
                ),
              ),
            ],
          ),
          Container(
            width: 300,
            height: 300,
            child: FutureBuilder<String>(
              future: firebase_storage.FirebaseStorage.instance
                  .ref()
                  .child('logo.png')
                  .getDownloadURL(),
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
                return Image.network(imageUrl!);
              },
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          InkWell(
            onTap: () async {
              UserCredential? userCredential = await signInWithGoogle();
              final User? user = userCredential.user;

              Navigator.pushNamed(context, '/home');
            },
            child: Container(
              width: 307,
              height: 63,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 307,
                    height: 63,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.only(
                      left: 35,
                      right: 42,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 46,
                          height: 39,
                          child: Image.network(
                            'http://pngimg.com/uploads/google/google_PNG19635.png',
                          ),
                        ),
                        SizedBox(width: 24),
                        Text(
                          "Google 로그인",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                UserCredential? userCredential =
                    await FirebaseAuth.instance.signInAnonymously();

                Navigator.pushNamed(context, '/home');
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
              ),
              child: const Text("Guest")),
        ],
      ),
    );
  }
}
