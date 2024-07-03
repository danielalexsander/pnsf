import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pnsf/pages/cifra.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PNSF',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 61, 88, 236)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'PNSF Cifras Missa'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List _cifras = [];

  // This list holds the data for the list view
  List _foundUsers = [];

  @override
  void initState() {
    readJson();
    _foundUsers = _cifras;
    super.initState();
  }

  // Fetch content from the json file
  Future<void> readJson() async {
    var url = Uri.parse(
        "https://raw.githubusercontent.com/danielalexsander/pnsf/master/assets/json/cifras.json");
    Response response = await get(url);

    // int statusCode = response.statusCode;
    String json = response.body;

    final cifra = jsonDecode(json) as Map<String, dynamic>;

    setState(() {
      _cifras = cifra["cifras"];
      _foundUsers = cifra["cifras"];
    });
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _cifras;
      setState(() {
        _foundUsers = results;
      });
    } else {
      print(enteredKeyword);
      results = _cifras
          .where((user) => user["titulo"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
      print(results);
      setState(() {
        _foundUsers = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
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
                child: _foundUsers.isNotEmpty
                    ? ListView.builder(
                        itemCount: _foundUsers.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CifraPage(
                                      idCifra: _foundUsers[index]["id"],
                                      tituloCifra: _foundUsers[index]["titulo"],
                                      base64Cifra: _foundUsers[index]
                                          ["html_base64"],
                                    ),
                                  ),
                                );
                              },
                              leading: Text(_foundUsers[index]["id"]),
                              title: Text(_foundUsers[index]["titulo"]),
                              subtitle: Text(_foundUsers[index]["autor"]),
                            ),
                          );
                        },
                      )
                    : const Text(
                        'Nenhuma cifra encontrada',
                        style: TextStyle(fontSize: 24),
                      )),
            // Display the data loaded from sample.json
            // _cifras.isNotEmpty
            //     ? Expanded(
            //         child: ListView.builder(
            //           itemCount: _cifras.length,
            //           itemBuilder: (context, index) {
            //             return Card(
            //               margin: const EdgeInsets.all(10),
            //               child: ListTile(
            //                 onTap: () {
            //                   Navigator.push(
            //                     context,
            //                     MaterialPageRoute(
            //                       builder: (context) => CifraPage(
            //                         idCifra: _cifras[index]["id"],
            //                         tituloCifra: _cifras[index]["titulo"],
            //                         base64Cifra: _cifras[index]["html_base64"],
            //                       ),
            //                     ),
            //                   );
            //                 },
            //                 leading: Text(_cifras[index]["id"]),
            //                 title: Text(_cifras[index]["titulo"]),
            //                 subtitle: Text(_cifras[index]["autor"]),
            //               ),
            //             );
            //           },
            //         ),
            //       )
            //     : ElevatedButton(
            //         child: const Text('Carregar Cifras'),
            //         onPressed: readJson,
            //       )
          ],
        ),
      ),
    );
  }
}
