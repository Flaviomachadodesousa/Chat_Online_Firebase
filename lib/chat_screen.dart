import 'dart:io';
import 'package:chat_online/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  Future<void> _sendMenssage({String text, File imgFile}) async {

    Map<String, dynamic> data = {};

    if(imgFile != null){
      StorageUploadTask task = FirebaseStorage.instance.ref().child(
        DateTime.now().millisecondsSinceEpoch.toString()).putFile(imgFile);

        StorageTaskSnapshot taskSnapshot = await task.onComplete;
        String url = await taskSnapshot.ref.getDownloadURL();
        data["imgurl"] = url;

    }if(text != null){
      data["text"] = text;
    }


    Firestore.instance.collection("menssages").add(data);
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text("Ola"),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection("mensagems").snapshots(),
              builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                    default::
                      List<DocumentsSnapshot> documents = snapshot.data.documents;
                      return ListView.builder(itemBuilder: null);
                }
                },
              ),
            ),
          TextComposer(_sendMenssage),
      ],
      )
    );
  }
}