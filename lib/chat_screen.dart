import 'dart:io';
import 'package:chat_online/chat_message.dart';
import 'package:chat_online/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googlelogin = GoogleSignIn();
  final GlobalKey<ScaffoldState> _staffoldkey = GlobalKey<ScaffoldState>();

  FirebaseUser _currentUser;
  bool _isloading = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<FirebaseUser> _getUser() async {
    if (_currentUser != null) return _currentUser;
    try {
      final GoogleSignInAccount googleSingInAccount =
          await googlelogin.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSingInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final FirebaseUser user = authResult.user;

      return user;
    } catch (error) {
      //return null;
    }
  }

  Future<void> _sendMenssage({String text, File imgFile}) async {
    final FirebaseUser user = await _getUser();

    if (user == null) {
      _staffoldkey.currentState.showSnackBar(SnackBar(
        content: Text("Não Foi possivel fazer o login. Tente novamente"),
        backgroundColor: Colors.red,
      ));
    }

    Map<String, dynamic> data = {
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoUrl,
      "time": Timestamp.now(),
    };

    if (imgFile != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(user.uid + DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(imgFile);

        setState(() {
          _isloading = true;
        });

      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      data["imgurl"] = url;

      setState(() {
          _isloading = false;
        });

    }
    if (text != null) {
      data["text"] = text;
    }

    Firestore.instance.collection("menssages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _staffoldkey,
        appBar: AppBar(
          title: Text(_currentUser != null
              ? "Ola, ${_currentUser.displayName}"
              : "Chat App"),
          elevation: 0,
          actions: <Widget>[
            _currentUser != null
                ? IconButton(
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      _staffoldkey.currentState.showSnackBar(SnackBar(
                        content: Text("Voce Saiu com sucesso"),
                        backgroundColor: Colors.blue,
                      ));
                    })
                : Container()
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection("menssages")
                    .orderBy("time")
                    .snapshots(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      List<DocumentSnapshot> documents =
                          snapshot.data.documents.reversed.toList();

                      return ListView.builder(
                        itemCount: documents.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          return ChatMessage(documents[index].data, 
                          documents[index].data['uid'] == _currentUser?.uid
                          );
                        },
                      );
                  }
                },
              ),
            ),
            _isloading ? LinearProgressIndicator() : Container(),
            TextComposer(_sendMenssage),
          ],
        ));
  }
}
