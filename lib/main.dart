/**
* [PNSF - Cifras]
* @package      [pnsf]
* @category     [Cifras]
* @author       Daniel Alexsander Inocêncio [daniel.alexsander00@hotmail.com]
* @copyright    [Daniel Alexsander 2024]
* @devversion   v7
* @prodversion  v1
* @since        02/07/2024
*/

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:pnsf/pages/cifra.dart';
import 'package:pnsf/widgets/side_menu.dart';
import 'package:pnsf/mixins/connectivity_status.dart';
import 'package:pnsf/theme/app_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.instance.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'PNSF',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 21, 56, 115)),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 21, 56, 115),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode:
              AppSettings.instance.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: const MyHomePage(title: 'Todas as Cifras'),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with ConnectivityStatusState<MyHomePage> {
  List _cifras = [];

  List _foundCifra = [];

  @override
  void initState() {
    initConnectivityTracking();
    readJson();
    _foundCifra = _cifras;
    super.initState();
  }

  @override
  void dispose() {
    disposeConnectivityTracking();
    super.dispose();
  }

  // Função que lê o JSON
  Future<void> readJson() async {
    Future.delayed(const Duration(seconds: 1), () async {
      if (isOnline) {
        /**
        * VERSÃO ONLINE - BUSCA O JSON DO GITHUB RAW
        */

        var url = Uri.parse(
            "https://raw.githubusercontent.com/danielalexsander/pnsf/master/assets/json/cifras.json");
        Response response = await get(url);

        // // Caso precise do statuscode
        // int statusCode = response.statusCode;
        String json = response.body;

        final cifra = jsonDecode(json) as Map<String, dynamic>;

        setState(() {
          _cifras = cifra["cifras"];
          _foundCifra = cifra["cifras"];
        });
      } else {
        /**
        * VERSÃO OFFLINE - BUSCA O JSON DO ASSETS
        */
        final String response =
            await rootBundle.loadString('assets/json/cifras.json');
        final cifra = await json.decode(response) as Map<String, dynamic>;

        setState(() {
          _cifras = cifra["cifras"];
          _foundCifra = cifra["cifras"];
        });
      }
    });
  }

  _retiraAcento(palavra) {
    palavra = palavra.replaceAll("ã", "a");
    palavra = palavra.replaceAll("õ", "o");
    palavra = palavra.replaceAll("á", "a");
    palavra = palavra.replaceAll("é", "é");
    palavra = palavra.replaceAll("í", "i");
    palavra = palavra.replaceAll("ó", "o");
    palavra = palavra.replaceAll("ú", "u");
    palavra = palavra.replaceAll("ç", "c");
    palavra = palavra.replaceAll(new RegExp(r"[^\w\s]+"), "");
    palavra = palavra.replaceAll(" ", "");

    return palavra;
  }

  // Essa Função é chamada toda vez que é digitado algo na busca
  void _runFilter(String enteredKeyword) {
    List results = [];
    if (enteredKeyword.isEmpty) {
      // Se a busca estiver vazia, mostra todos os resultados
      results = _cifras;
      setState(() {
        _foundCifra = results;
      });
    } else {
      // Retira Acentuação
      enteredKeyword = _retiraAcento(enteredKeyword);

      results = _cifras
          .where((user) => user["titulo"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();

      // Se não achar baseado no título, procura no conteúdo
      if (results.isEmpty) {
        results = _cifras
            .where((user) => user["conteudo"]
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()))
            .toList();
      }

      setState(() {
        _foundCifra = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 21, 56, 115),
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [buildConnectivityIndicator()],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  onChanged: (value) => _runFilter(value),
                  leading: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.search),
                  ),
                  hintText: 'Procurar cifras...',
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  elevation: WidgetStateProperty.all(2),
                  side: WidgetStateProperty.all(
                    BorderSide(
                      color: const Color.fromARGB(255, 21, 56, 115)
                          .withOpacity(0.1),
                    ),
                  ),
                );
              },
              suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
                return [];
              },
            ),
          ),
          Expanded(
            child: _foundCifra.isNotEmpty
                ? ListView.builder(
                    itemCount: _foundCifra.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        elevation: 2,
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CifraPage(
                                  idCifra: _foundCifra[index]["id"],
                                  tituloCifra: _foundCifra[index]["titulo"],
                                  base64Cifra: _foundCifra[index]["html_base64"],
                                  linkCifra: _foundCifra[index]["link"],
                                  tom: _foundCifra[index]["tom"],
                                ),
                              ),
                            );
                          },
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 21, 56, 115)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                _foundCifra[index]["id"].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 21, 56, 115),
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            _foundCifra[index]["titulo"],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(_foundCifra[index]["autor"]),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Color.fromARGB(255, 21, 56, 115),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_note,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Carregando...',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
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
