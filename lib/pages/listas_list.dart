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
        backgroundColor: const Color.fromARGB(255, 21, 56, 115),
        onPressed: () => _dialogBuilder(context),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _list.isNotEmpty
            ? ListView.builder(
                itemCount: _list.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
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
                            _list[index]["id"].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 21, 56, 115),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        _list[index]["titulo"],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
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
                      Icons.playlist_add,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma Lista Encontrada',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crie uma nova lista para começar',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Nova Lista',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          content: TextField(
            controller: _model,
            decoration: InputDecoration(
              labelText: 'Título da Lista',
              hintText: 'Digite um nome para sua lista',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              prefixIcon: const Icon(Icons.list),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 21, 56, 115),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                setLista();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyListNew(),
                  ),
                );
              },
              child: const Text(
                'Salvar',
                style: TextStyle(color: Colors.white),
              ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Excluir Lista',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          content: const Text(
            'Tem certeza que deseja excluir esta lista? Esta ação não pode ser desfeita.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                deleteLista(idLista);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyListPage(
                      title: 'Listas',
                    ),
                  ),
                );
              },
              child: const Text(
                'Excluir',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
