import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pnsf/pages/cifra.dart';
import 'package:pnsf/widgets/side_menu.dart';

class CategoriaPage extends StatefulWidget {
  const CategoriaPage({
    super.key,
    required this.codCategoria,
    required this.nomeCategoria,
  });

  final int codCategoria;
  final String nomeCategoria;

  @override
  State<CategoriaPage> createState() => _CategoriaPageState();
}

class _CategoriaPageState extends State<CategoriaPage> {
  List _newListCategoria = [];

  @override
  void initState() {
    readJson();
    super.initState();
  }

  // Função que lê o JSON do github raw
  Future<void> readJson() async {
    var url = Uri.parse(
        "https://raw.githubusercontent.com/danielalexsander/pnsf/master/assets/json/cifras.json");
    Response response = await get(url);

    // Caso precise do statuscode
    // int statusCode = response.statusCode;
    String json = response.body;

    final cifra = jsonDecode(json) as Map<String, dynamic>;

    // Ao ler o JSON, verifica se a categoria é a mesma da desejada
    // Se for, adiciona na lista e exibe.
    var indice = 0;
    for (var cif in cifra['cifras']) {
      if (cif['categoria'] == widget.codCategoria) {
        _newListCategoria.add(cifra['cifras'][indice]);
      }
      indice++;
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
          widget.nomeCategoria,
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
                child: _newListCategoria.isNotEmpty
                    ? ListView.builder(
                        itemCount: _newListCategoria.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CifraPage(
                                      idCifra: _newListCategoria[index]["id"],
                                      tituloCifra: _newListCategoria[index]
                                          ["titulo"],
                                      base64Cifra: _newListCategoria[index]
                                          ["html_base64"],
                                    ),
                                  ),
                                );
                              },
                              leading: Text(_newListCategoria[index]["id"]),
                              title: Text(_newListCategoria[index]["titulo"]),
                              subtitle: Text(_newListCategoria[index]["autor"]),
                            ),
                          );
                        },
                      )
                    : const Text(
                        'Carregando... / Nenhuma Cifra Encontrada',
                        style: TextStyle(fontSize: 24),
                      )),
          ],
        ),
      ),
    );
  }
}
