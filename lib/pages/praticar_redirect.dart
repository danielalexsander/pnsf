import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:pnsf/pages/cifra.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:math';

import 'package:pnsf/widgets/side_menu.dart';

class Practice extends StatefulWidget {
  const Practice({super.key});

  @override
  State<Practice> createState() => _PracticeState();
}

class _PracticeState extends State<Practice> {
  int _qtdCifras = 0;

  List _cifras = [];

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

        setState(() {
          _qtdCifras = cifra['cifras'].length;
          _cifras = cifra['cifras'];
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
          _qtdCifras = cifra['cifras'].length;
          _cifras = cifra['cifras'];
        });
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
          'Praticar',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _cifras.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(24.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 21, 56, 115),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    int randomNumber = Random().nextInt(_qtdCifras);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CifraPage(
                          idCifra: _cifras[randomNumber]['id'],
                          tituloCifra: _cifras[randomNumber]['titulo'],
                          base64Cifra: _cifras[randomNumber]['html_base64'],
                          linkCifra: _cifras[randomNumber]["link"],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.music_note),
                  label: const Text(
                    'Praticar Nova Música',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            : Column(
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
    );
  }
}
