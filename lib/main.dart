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

  @override
  void initState() {
    readJson();
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Display the data loaded from sample.json
            _cifras.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: _cifras.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CifraPage(
                                    idCifra: _cifras[index]["id"],
                                    tituloCifra: _cifras[index]["titulo"],
                                    base64Cifra: _cifras[index]["html_base64"],
                                  ),
                                ),
                              );
                            },
                            leading: Text(_cifras[index]["id"]),
                            title: Text(_cifras[index]["titulo"]),
                            subtitle: Text(_cifras[index]["autor"]),
                          ),
                        );
                      },
                    ),
                  )
                : ElevatedButton(
                    child: const Text('Carregar Cifras'),
                    onPressed: readJson,
                  )
          ],
        ),
      ),
    );
  }
}
