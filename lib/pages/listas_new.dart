import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pnsf/database/database.dart';
import 'package:pnsf/pages/listas_page.dart';
import 'package:pnsf/widgets/side_menu.dart';

class MyListNew extends StatefulWidget {
  const MyListNew({super.key});

  @override
  State<MyListNew> createState() => _MyListNewState();
}

class _MyListNewState extends State<MyListNew> {
  List _cifras = [];

  List _foundCifra = [];

  List _isCheckedList = [];
  List _idsList = [];

  List _lastLista = [];

  @override
  void initState() {
    readJson();
    _foundCifra = _cifras;
    super.initState();

    getLastLista();
  }

  getLastLista() async {
    List ultimo_id_bd = await DatabaseAPP.getLastIdLista();

    setState(() {
      _lastLista = ultimo_id_bd;
    });

    print('_lastLista');
    print(_lastLista[0]['titulo']);
  }

  updateLista(ids_lista, id_lista) async {
    await DatabaseAPP.updateLista(ids_lista, id_lista);

    return true;
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
          _lastLista[0]['titulo'],
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
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
                                  if (value) {
                                    _idsList.add(_foundCifra[index]["id"]);
                                  } else {
                                    _idsList.remove(_foundCifra[index]["id"]);
                                  }
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
