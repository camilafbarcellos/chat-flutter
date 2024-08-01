import 'screens/img.dart';
import 'screens/lista.dart';
import 'screens/text.dart';
import 'screens/traducao.dart';
import 'screens/traducao2.dart';
import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';

class NavigationOptions extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NavigationOptionsState();
  }
}

class _NavigationOptionsState extends State<NavigationOptions> {
  int paginaAtual = 0;
  PageController? pc;

  @override
  void initState() {
    super.initState();
    pc = PageController(initialPage: paginaAtual);
  }

  setPaginaAtual(pagina) {
    setState(() {
      paginaAtual = pagina;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pc,
        children: [
          ChatScreen(),
          Lista(),
          ImageLabelingScreen(),
          TextRecognitionScreen(),
          TranslationTutorial(),
          CompleteTranslationTutorial()
        ],
        onPageChanged: setPaginaAtual,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: paginaAtual,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: "Mapa"),
          BottomNavigationBarItem(icon: Icon(Icons.image), label: "IMG"),
          BottomNavigationBarItem(icon: Icon(Icons.text_fields), label: "Text"),
          BottomNavigationBarItem(icon: Icon(Icons.translate), label: "Trad"),
          BottomNavigationBarItem(icon: Icon(Icons.g_translate), label: "Trad2")
        ],
        onTap: (pagina) {
          pc?.animateToPage(pagina,
              duration: const Duration(milliseconds: 400), curve: Curves.ease);
        },
        backgroundColor: Colors.grey[200],
        selectedItemColor: Colors.cyan,
      ),
    );
  }
}
