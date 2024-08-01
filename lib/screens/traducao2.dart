import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class CompleteTranslationTutorial extends StatefulWidget {
  const CompleteTranslationTutorial({super.key});

  @override
  State<CompleteTranslationTutorial> createState() =>
      _CompleteTranslationTutorialState();
}

class _CompleteTranslationTutorialState
    extends State<CompleteTranslationTutorial> {
  TranslateLanguage sourceLanguage = TranslateLanguage.english;
  TranslateLanguage targetLanguage = TranslateLanguage.hindi;

  final TextEditingController _textEditingController1 = TextEditingController();
  final TextEditingController _textEditingController2 = TextEditingController();
  final List<String> languages =
  TranslateLanguage.values.map((language) => language.name).toList();
  String _translatedText = '';
  late OnDeviceTranslator onDeviceTranslator;

  Future<String> translateText(String sourceText) async {
    final String translation =
    await onDeviceTranslator.translateText(sourceText);
    return translation;
  }

  void setTranslator(TranslateLanguage source, TranslateLanguage target) {
    onDeviceTranslator = OnDeviceTranslator(
      sourceLanguage: source,
      targetLanguage: target,
    );
  }

  @override
  void initState() {
    super.initState();
    setTranslator(sourceLanguage, targetLanguage);
  }

  @override
  void dispose() {
    onDeviceTranslator.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation Tutorial'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DropdownButton<String>(
              value: sourceLanguage.name,
              onChanged: (String? newValue) {
                if (newValue == null) return;
                setState(
                      () {
                    _textEditingController1.clear();
                    _textEditingController2.clear();
                    sourceLanguage = TranslateLanguage.values
                        .firstWhere((language) => language.name == newValue);
                  },
                );
                setTranslator(sourceLanguage, targetLanguage);
              },
              items: languages.map(
                    (String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                },
              ).toList(),
            ),
            Expanded(
              child: TextField(
                controller: _textEditingController1,
                maxLines: null,
                minLines: 100,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'Enter text to translate',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) async {
                  _translatedText = await translateText(value);
                  setState(() {
                    _textEditingController2.text = _translatedText;
                  });
                },
              ),
            ),
            const Divider(),
            DropdownButton<String>(
              value: targetLanguage.name,
              onChanged: (String? newValue) {
                if (newValue == null) return;
                setState(() {
                  _textEditingController1.clear();
                  _textEditingController2.clear();
                  targetLanguage = TranslateLanguage.values
                      .firstWhere((language) => language.name == newValue);
                });
                setTranslator(sourceLanguage, targetLanguage);
              },
              items: languages.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
            ),
            Expanded(
              child: TextField(
                controller: _textEditingController2,
                maxLines: null,
                minLines: 100,
                keyboardType: TextInputType.none,
                decoration: const InputDecoration(
                  hintText: 'Translated Text will appear here',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}