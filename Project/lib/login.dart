import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;

//image 출처 : <a href="https://kr.freepik.com/free-vector/contactless-delivery-during-covid-19-outbreak_16351215.htm#query=delivery&position=12&from_view=keyword&track=sph">작가 rawpixel.com</a> 출처 Freepik

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<void> signInAdd() async {
    FirebaseFirestore.instance.collection('user').add({});
  }

  Future<UserCredential> signInWithGoogle() async {
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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xff0084ff),
            ),
            child: Image.asset("assets/logo.jpg"),
          ),
          const SizedBox(
            height: 30,
          ),
          InkWell(
            onTap: () async {
              UserCredential? userCredential = await signInWithGoogle();
              final User? user = userCredential.user;
              var snapShot = await FirebaseFirestore.instance
                  .collection('user')
                  .where('uid', isEqualTo: user!.uid)
                  .get();

              if (userCredential != null) {
                if (snapShot.docs.isEmpty) {
                  FirebaseFirestore.instance
                      .collection('user')
                      .doc(user!.uid)
                      .set({
                    'name': user.displayName,
                    'email': user.email,
                    'uid': user.uid,
                    'status_message':
                        'I promise to take the test honestly before GOD.',
                  });
                }

                Navigator.pushNamed(context, '/item');
              }
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
        ],
      ),
    );
  }
}
