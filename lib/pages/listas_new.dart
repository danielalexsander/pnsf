import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pnsf/database/database.dart';
import 'package:pnsf/pages/listas_page.dart';
import 'package:http/http.dart';
import 'package:pnsf/widgets/side_menu.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MyListNew extends StatefulWidget {
  const MyListNew({super.key});

  @override
  State<MyListNew> createState() => _MyListNewState();
}

class _MyListNewState extends State<MyListNew> {
  List _cifras = [];

  List _foundCifra = [];

  List _idsList = [];

  List _lastLista = [];

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

    getLastLista();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  getLastLista() async {
    List ultimo_id_bd = await DatabaseAPP.getLastIdLista();

    setState(() {
      _lastLista = ultimo_id_bd;
    });
  }

  updateLista(ids_lista, id_lista) async {
    await DatabaseAPP.updateLista(ids_lista, id_lista);

    return true;
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
          _lastLista[0]['titulo'],
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 21, 56, 115),
        onPressed: () {
          updateLista(_idsList.toString(), _lastLista[0]['id']);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyList(
                idsLista: _idsList,
                tituloLista: _lastLista[0]['titulo'],
              ),
            ),
          );
        },
        child: const Icon(
          Icons.check,
          color: Colors.white,
        ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _foundCifra.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 2,
                        child: CheckboxListTile(
                          value: _foundCifra[index]['isChecked'],
                          onChanged: (bool? value) {
                            setState(() {
                              _foundCifra[index]['isChecked'] = value!;
                              if (value) {
                                _idsList.add(_foundCifra[index]["id"]);
                              } else {
                                _idsList.remove(_foundCifra[index]["id"]);
                              }
                            });
                          },
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          title: Text(
                            _foundCifra[index]["titulo"],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(_foundCifra[index]["autor"]),
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
