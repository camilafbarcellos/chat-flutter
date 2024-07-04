import 'dart:io';
import '/screens/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ChatScreenState();
  }
}

class ChatScreenState extends State<ChatScreen> {
  final CollectionReference _mensagens =
      FirebaseFirestore.instance.collection("mensagens");

  // objetos referentes ao login
  final GoogleSignIn googleSignIn = GoogleSignIn();
  User? _currentUser;
  FirebaseAuth auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Chat App"),
          backgroundColor: Colors.cyan,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
              stream: _mensagens.orderBy('time').snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    List<DocumentSnapshot> documents =
                        snapshot.data!.docs.reversed.toList();
                    return ListView.builder(
                      itemCount: documents.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  child: Column(
                                children: <Widget>[
                                  documents[index].get('url') != ""
                                      ? Image.network(
                                          documents[index].get('url'),
                                          width: 150)
                                      : Text(
                                          documents[index].get('text'),
                                          style: TextStyle(fontSize: 16),
                                        )
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
        ));
  }

  void _sendMessage({String? text, XFile? imgFile}) async {
    final CollectionReference _mensagens =
        FirebaseFirestore.instance.collection("mensagens");
    Map<String, dynamic> data = {
      'time': Timestamp.now(),
      'url': '',
    };

    if (imgFile != null) {
      // chegou um arquivo de imagem
      firebase_storage.UploadTask uploadTask;
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child("imgs")
          .child(DateTime.now().millisecondsSinceEpoch.toString());
      final metadados = firebase_storage.SettableMetadata(
          contentType: "image/jpeg",
          customMetadata: {"picked-file-path": imgFile.path});
      if (kIsWeb) {
        // se estiver na plataforma WEB
        uploadTask = ref.putData(await imgFile.readAsBytes(), metadados);
      } else {
        // se for outra plataforma
        uploadTask = ref.putFile(File(imgFile.path), metadados);
      }
      var taskSnapshot = await uploadTask;
      String imageUrl = "";
      imageUrl =
          await taskSnapshot.ref.getDownloadURL(); //URL da imagem no storage
      data['url'] = imageUrl;
    } else {
      // se chegou apenas texto
      data['text'] = text;
    }
    _mensagens.add(data);
  }

  // métodos referentes ao login
  Future<User?> _getUser({required BuildContext context}) async {
    User? user; // pode ser nulo pq login falho retorna null

    // caso já tenha feito um login válido
    if (_currentUser != null) return _currentUser;

    if (kIsWeb) {
      //WEB
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      try {
        // pop-up de login Google para receber a credencial (dados) do usuário
        final UserCredential userCredential =
            await auth.signInWithPopup(authProvider);
        user = userCredential.user;
      } catch (e) {
        print(e);
      }
    } else {
      //ANDROID
      // página de login da conta Google
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      // verifica se a conta Google foi logada (!= de null) e recupera a autenticação
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        // cria uma credencial com a autenticação obtida
        final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken);

        try {
          // a partir da credencial criada, recupera os dados do usuário
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);
          user = userCredential.user;
        } catch (e) {
          print(e);
        }
      }
      print("User logado: " + user!.displayName.toString());
    }
    return user;
  }

  // método que, ao abrir a página de ChatScreen, habiblita um ouvinte (listener)
  // que, a qualquer alteração de autenticação, atualiza o estado do usuário _currentUser
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }
}
