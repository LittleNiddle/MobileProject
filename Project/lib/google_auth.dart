import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;

class AuthFunc extends StatelessWidget {
  const AuthFunc({
    Key? key,
    required this.signOut,
    required this.loggedIn,
  }) : super(key: key);

  final bool loggedIn;
  final void Function() signOut;

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signOutGoogle() async {
    await FirebaseAuth.instance.signOut();

    await GoogleSignIn().signOut();
  }

  Future<void> signOutAnonymously() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 8),
              child: ElevatedButton(
                  onPressed: () async {
                    UserCredential? userCredential = await signInWithGoogle();
                    if (userCredential != null) {
                      Navigator.pushNamed(context, '/item');
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                  ),
                  child: Text("Google")),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 8),
              child: ElevatedButton(
                  onPressed: () async {
                    UserCredential? userCredential =
                        await FirebaseAuth.instance.signInAnonymously();
                    if (userCredential != null) {
                      Navigator.pushNamed(context, '/item');
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.grey),
                  ),
                  child: const Text("Guest")),
            ),
          ],
        ),
      ],
    );
  }
}
