import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pnsf/database/database.dart';
import 'package:pnsf/pages/listas_new.dart';
import 'package:pnsf/pages/listas_page.dart';
import 'package:pnsf/widgets/side_menu.dart';

class MyListPage extends StatefulWidget {
  const MyListPage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyListPage> createState() => _MyListPageState();
}

class _MyListPageState extends State<MyListPage> {
  final _model = TextEditingController();
  List _list = [];

  @override
  void initState() {
    super.initState();

    getListas();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  setLista() async {
    await DatabaseAPP.setLista(
      _model.text,
    );

    return true;
  }

  deleteLista(id) async {
    await DatabaseAPP.deleteLista(
      id,
    );

    return true;
  }

  getListas() async {
    List lista_db = await DatabaseAPP.getListas();

    setState(() {
      _list = lista_db;
    });
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
        onPressed: () => _dialogBuilder(context),
        child: const Icon(Icons.format_list_bulleted_add),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: _list.isNotEmpty
                    ? ListView.builder(
                        itemCount: _list.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                              onTap: () {
                                var nList = json
                                    .decode(_list[index]["ids_lista"])
                                    .cast<dynamic>()
                                    .toList();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyList(
                                      idsLista: nList,
                                      tituloLista: _list[index]["titulo"],
                                    ),
                                  ),
                                );
                              },
                              onLongPress: () {
                                _dialogDeleteList(context, _list[index]["id"]);
                              },
                              leading: Text(_list[index]["id"].toString()),
                              title: Text(_list[index]["titulo"]),
                            ),
                          );
                        },
                      )
                    : const Text(
                        'Nenhuma Lista Encontrada',
                        style: TextStyle(fontSize: 24),
                      )),
          ],
        ),
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Título da Nova Lista'),
          content: TextField(
            controller: _model,
            decoration: const InputDecoration(
              labelText: 'Título',
              contentPadding: EdgeInsets.all(5),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Salvar'),
              onPressed: () {
                // ************ CRIA NOVA LISTA **************
                setLista();
                // ************ CRIA NOVA LISTA **************
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyListNew(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _dialogDeleteList(BuildContext context, int idLista) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Lista'),
          content: Text('Deseja realmente excluir esta Lista?'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Não'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Sim'),
              onPressed: () {
                // ************ DELETA LISTA **************
                deleteLista(idLista);
                // ************ DELETA LISTA **************
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyListPage(
                      title: 'Listas',
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
