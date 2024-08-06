import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pnsf/widgets/side_menu.dart';

class MyListNew extends StatefulWidget {
  const MyListNew({super.key, required this.title});

  final String title;

  @override
  State<MyListNew> createState() => _MyListNewState();
}

class _MyListNewState extends State<MyListNew> {
  List _cifras = [];

  List _foundCifra = [];

  List _isCheckedList = [];
  List _idsList = [];

  @override
  void initState() {
    readJson();
    _foundCifra = _cifras;
    super.initState();
  }

  // Função que lê o JSON
  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/json/cifras.json');
    final cifra = await json.decode(response) as Map<String, dynamic>;

    setState(() {
      _cifras = cifra["cifras"];
      _foundCifra = cifra["cifras"];
      _isCheckedList = List.generate(_foundCifra.length, (index) => false);
    });
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
      results = _cifras
          .where((user) => user["titulo"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('SALVA LISTA');
          print(_idsList);
        },
        child: Icon(Icons.check),
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
                            child: CheckboxListTile(
                              value: _isCheckedList[index],
                              onChanged: (bool? value) {
                                setState(() {
                                  _isCheckedList[index] = value!;
                                  _idsList.add(_foundCifra[index]["id"]);
                                });
                              },
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
