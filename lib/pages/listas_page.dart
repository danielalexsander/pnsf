import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:http/http.dart';
import 'package:pnsf/pages/cifra.dart';
import 'package:pnsf/widgets/side_menu.dart';

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

  @override
  void initState() {
    readJson();
    super.initState();
  }

  // Função que lê o JSON
  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/json/cifras.json');
    final cifra = await json.decode(response) as Map<String, dynamic>;

    // Ao ler o JSON, verifica se o id na lista é a mesma da desejada
    // Se for, adiciona na lista e exibe.
    var indice = 0;
    for (var cif in cifra['cifras']) {
      for (var i = 0; i < widget.idsLista.length; i++) {
        print(cif['id']);
        if (cif['id'] == widget.idsLista[i].toString()) {
          print('entrou aqui');
          _newListList.add(cifra['cifras'][indice]);
        }
        indice++;
      }
    }

    setState(() {});
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: _newListList.isNotEmpty
                    ? ListView.builder(
                        itemCount: _newListList.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CifraPage(
                                      idCifra: _newListList[index]["id"],
                                      tituloCifra: _newListList[index]
                                          ["titulo"],
                                      base64Cifra: _newListList[index]
                                          ["html_base64"],
                                    ),
                                  ),
                                );
                              },
                              leading: Text(_newListList[index]["id"]),
                              title: Text(_newListList[index]["titulo"]),
                              subtitle: Text(_newListList[index]["autor"]),
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
