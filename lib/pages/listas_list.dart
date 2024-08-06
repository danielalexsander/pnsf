import 'package:flutter/material.dart';
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
  List _foundCifra = [];
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
        onPressed: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyListNew(
                title: 'Nova Lista',
              ),
            ),
          )
        },
        child: const Icon(Icons.format_list_bulleted_add),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: _foundCifra.isNotEmpty
                    ? ListView.builder(
                        itemCount: _foundCifra.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyList(
                                      idCifra: _foundCifra[index]["id"],
                                      tituloCifra: _foundCifra[index]["titulo"],
                                      base64Cifra: _foundCifra[index]
                                          ["html_base64"],
                                    ),
                                  ),
                                );
                              },
                              leading: Text(_foundCifra[index]["id"]),
                              title: Text(_foundCifra[index]["titulo"]),
                              subtitle: Text(_foundCifra[index]["autor"]),
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
}
