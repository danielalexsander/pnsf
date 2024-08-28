/**
* [PNSF - Cifras]
* @package   [pnsf]
* @category  [Cifras]
* @author    Daniel Alexsander Inocêncio [daniel.alexsander00@hotmail.com]
* @copyright [Daniel Alexsander 2024]
* @version   v7
* @since     02/07/2024
*/

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:pnsf/pages/cifra.dart';
import 'package:pnsf/widgets/side_menu.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PNSF',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 21, 56, 115)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Todas as Cifras'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List _cifras = [];

  List _foundCifra = [];

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  static const snackBarConnection = SnackBar(
    content: Text('Tem conexão, buscou da internet'),
  );

  static const snackBarnoConnection = SnackBar(
    content: Text('Sem conexão, buscou do local'),
  );

  @override
  void initState() {
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    readJson();
    _foundCifra = _cifras;
    super.initState();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> resultConnection;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      resultConnection = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status error: $e');
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(resultConnection);
  }

  Future<void> _updateConnectionStatus(
      List<ConnectivityResult> resultConnection) async {
    setState(() {
      _connectionStatus = resultConnection;
    });
    // ignore: avoid_print
    print('Connectivity changed: $_connectionStatus');
  }

  // Função que lê o JSON
  Future<void> readJson() async {
    Future.delayed(const Duration(seconds: 1), () async {
      if (_connectionStatus.contains(ConnectivityResult.wifi) ||
          _connectionStatus.contains(ConnectivityResult.mobile)) {
        /**
        * VERSÃO ONLINE - BUSCA O JSON DO GITHUB RAW
        */

        ScaffoldMessenger.of(context).showSnackBar(snackBarConnection);
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
        ScaffoldMessenger.of(context).showSnackBar(snackBarnoConnection);
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              onChanged: (value) => _runFilter(value),
              decoration: const InputDecoration(
                  labelText: 'Procurar',
                  suffixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.all(5)),
            ),
            Expanded(
                child: _foundCifra.isNotEmpty
                    ? ListView.builder(
                        itemCount: _foundCifra.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CifraPage(
                                      idCifra: _foundCifra[index]["id"],
                                      tituloCifra: _foundCifra[index]["titulo"],
                                      base64Cifra: _foundCifra[index]
                                          ["html_base64"],
                                    ),
                                  ),
                                );
                              },
                              leading: Text(_foundCifra[index]["id"]),
                              title: Text(_foundCifra[index]["titulo"]),
                              subtitle: Text(_foundCifra[index]["autor"]),
                            ),
                          );
                        },
                      )
                    : const Text(
                        'Carregando...',
                        style: TextStyle(fontSize: 24),
                      )),
          ],
        ),
      ),
    );
  }
}
