import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:pnsf/pages/cifra.dart';
import 'package:pnsf/widgets/side_menu.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MyList extends StatefulWidget {
  const MyList({
    super.key,
    required this.idsLista,
    required this.tituloLista,
  });

  final List idsLista;
  final String tituloLista;

  @override
  State<MyList> createState() => _MyListState();
}

class _MyListState extends State<MyList> {
  List _newListList = [];

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

        // Ao ler o JSON, verifica se o id na lista é a mesma da desejada
        // Se for, adiciona na lista e exibe.
        for (var i = 0; i < widget.idsLista.length; i++) {
          var indice = 0;
          for (var cif in cifra['cifras']) {
            // print(cif['id']);
            if (cif['id'] == widget.idsLista[i].toString()) {
              // print('entrou aqui');
              _newListList.add(cifra['cifras'][indice]);
            }
            indice++;
          }
        }
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(snackBarnoConnection);
        /**
        * VERSÃO OFFLINE - BUSCA O JSON DO ASSETS
        */
        final String response =
            await rootBundle.loadString('assets/json/cifras.json');
        final cifra = await json.decode(response) as Map<String, dynamic>;

        // Ao ler o JSON, verifica se o id na lista é a mesma da desejada
        // Se for, adiciona na lista e exibe.
        for (var i = 0; i < widget.idsLista.length; i++) {
          var indice = 0;
          for (var cif in cifra['cifras']) {
            // print(cif['id']);
            if (cif['id'] == widget.idsLista[i].toString()) {
              // print('entrou aqui');
              _newListList.add(cifra['cifras'][indice]);
            }
            indice++;
          }
        }
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 21, 56, 115),
        title: Text(
          widget.tituloLista,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _newListList.isNotEmpty
            ? ListView.builder(
                itemCount: _newListList.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CifraPage(
                              idCifra: _newListList[index]["id"],
                              tituloCifra: _newListList[index]["titulo"],
                              base64Cifra: _newListList[index]["html_base64"],
                            ),
                          ),
                        );
                      },
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 21, 56, 115)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            _newListList[index]["id"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 21, 56, 115),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        _newListList[index]["titulo"],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(_newListList[index]["autor"]),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
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
    );
  }
}
