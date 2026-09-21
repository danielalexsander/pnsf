import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:pnsf/pages/cifra.dart';
import 'package:pnsf/mixins/connectivity_status.dart';
import 'dart:math';

import 'package:pnsf/widgets/side_menu.dart';

class Practice extends StatefulWidget {
  const Practice({super.key});

  @override
  State<Practice> createState() => _PracticeState();
}

class _PracticeState extends State<Practice> with ConnectivityStatusState<Practice> {
  int _qtdCifras = 0;

  List _cifras = [];

  @override
  void initState() {
    initConnectivityTracking();
    readJson();
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
          _qtdCifras = cifra['cifras'].length;
          _cifras = cifra['cifras'];
        });
      } else {
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
        actions: [buildConnectivityIndicator()],
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
                          tom: _cifras[randomNumber]["tom"],
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
