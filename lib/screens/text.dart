import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TextRecognitionScreen extends StatefulWidget {
  const TextRecognitionScreen({Key? key}) : super(key: key);

  @override
  State<TextRecognitionScreen> createState() => _TextRecognitionScreenState();
}

class _TextRecognitionScreenState extends State<TextRecognitionScreen> {
  InputImage? inputImage;
  bool isScanning = false;
  XFile? imageFile;
  String result = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text('Text Recognition in Flutter App'),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              imageFile == null
                  ? Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0)),
                width: 200,
                height: 200,
                child: Image.asset('assets/placeholder.png'),
              )
                  : Image.file(File(imageFile!.path)),
              const SizedBox(
                height: 40.0,
              ),
              Text(
                result,
                style: const TextStyle(fontSize: 20.0),
              ),
              const SizedBox(
                height: 40.0,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.5,
                height: 50.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                      onPressed: () {
                        showImageSourceDialog(context);
                      },
                      child: const Text("Start")),
                ),
              )
            ],
          ),
        ));
  }

  void pickImage(ImageSource source) async {
    var pickedImage = await ImagePicker()
        .pickImage(source: source, maxHeight: 300, maxWidth: 300);
    Navigator.of(context).pop();
    try {
      if (pickedImage != null) {
        imageFile = pickedImage;
        setState(() {});
        getTextFromImage(pickedImage);
      }
    } catch (e) {
      isScanning = false;
      imageFile = null;
      result = "Error!!";
      setState(() {});
    }
  }

  void getTextFromImage(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector =
    GoogleMlKit.vision.textRecognizer(script: TextRecognitionScript.latin);
    RecognizedText recognisedText = await textDetector.processImage(inputImage);
    result = recognisedText.text;
    isScanning = false;
    await textDetector.close();
    setState(() {});
  }

  showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Select Image From",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: () {
                  pickImage(ImageSource.gallery);
                },
                child: const ListTile(
                  leading: Icon(Icons.photo),
                  title: Text('Gallery'),
                ),
              ),
              GestureDetector(
                onTap: () {
                  pickImage(ImageSource.camera);
                },
                child: const ListTile(
                  leading: Icon(Icons.camera),
                  title: Text('Camera'),
                ),
              ),
            ],
          );
        });
  }
}