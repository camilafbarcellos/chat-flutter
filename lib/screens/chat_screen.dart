import 'dart:io';
import '/screens/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ChatScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ChatScreenState();
  }
}
class ChatScreenState extends State<ChatScreen>{
  final CollectionReference _mensagens =
      FirebaseFirestore.instance.collection("mensagens");

  @override
  Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: Text("Chat App"),
         backgroundColor: Colors.cyan,
       ),
       body: Column(
         children: <Widget> [
           Expanded(child: StreamBuilder<QuerySnapshot>(
             stream: _mensagens.orderBy('time').snapshots(),
             builder: (context, snapshot) {
                 switch (snapshot.connectionState){
                   case ConnectionState.waiting :
                     return Center(child: CircularProgressIndicator());
                   default :
                     List<DocumentSnapshot> documents =
                         snapshot.data!.docs.reversed.toList();
                     return ListView.builder(
                       itemCount: documents.length,
                       reverse: true,
                       itemBuilder: (context, index){
                         return Container(
                           margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                           child: Row(
                             children: <Widget> [
                               Expanded(child: Column(
                                 children: <Widget> [
                                   documents[index].get('url') != "" ?
                                       Image.network(documents[index].get('url'),
                                         width: 150) :
                                       Text(documents[index].get('text'),
                                       style: TextStyle(fontSize: 16),)
                                 ],
                               ))
                             ],
                           ),
                         );
                       },
                     );
                 }
             },
           )),
           TextComposer(_sendMessage),
         ],
       )
     );
  }

  void _sendMessage({String? text, XFile? imgFile}) async {
    final CollectionReference _mensagens =
          FirebaseFirestore.instance.collection("mensagens");
    Map<String, dynamic> data = {
      'time' : Timestamp.now(),
      'url'  : '',
    };

    if (imgFile != null){ // chegou um arquivo de imagem
      firebase_storage.UploadTask uploadTask;
      firebase_storage.Reference ref =
           firebase_storage.FirebaseStorage.instance
           .ref()
           .child("imgs")
           .child(DateTime.now().millisecondsSinceEpoch.toString());
      final metadados = firebase_storage.SettableMetadata(
        contentType: "image/jpeg",
        customMetadata: {"picked-file-path" : imgFile.path}
      );
      if (kIsWeb){ // se estiver na plataforma WEB
          uploadTask = ref.putData(await imgFile.readAsBytes(), metadados);
      }else{  // se for outra plataforma
          uploadTask = ref.putFile(File(imgFile.path), metadados);
      }
      var taskSnapshot = await uploadTask;
      String imageUrl = "";
      imageUrl = await taskSnapshot.ref.getDownloadURL(); //URL da imagem no storage
      data['url'] = imageUrl;
    }else{ // se chegou apenas texto
        data['text'] = text;
    }
    _mensagens.add(data);
  }
}