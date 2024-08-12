import 'package:flutter/material.dart';
import 'package:pnsf/pages/categoria_page.dart';
import 'package:pnsf/widgets/side_menu.dart';

class CategoriaList extends StatefulWidget {
  const CategoriaList({super.key});

  @override
  State<CategoriaList> createState() => _CategoriaListState();
}

final List<String> categorias = <String>[
  'Entrada',
  'Ato Penitencial',
  'Glória',
  'Aclamação',
  'Ofertório',
  'Santo',
  'Cordeiro',
  'Comunhão',
  'Dízimo',
  'Final',
  'Envio/Benção',
  'Padroeira',
  'Missas Completas',
  'Diversos',
  'Anunciamos',
  'Amém',
  'Adoração',
  'Natal'
];
final List<int> idCategorias = <int>[
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
  11,
  12,
  13,
  14,
  15,
  16,
  17,
  18
];

class _CategoriaListState extends State<CategoriaList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 21, 56, 115),
        title: Text(
          "Categorias",
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
                child: ListView.builder(
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoriaPage(
                              codCategoria: idCategorias[index],
                              nomeCategoria: categorias[index]),
                        ),
                      );
                    },
                    leading: Text('${idCategorias[index]}'),
                    title: Text(categorias[index]),
                  ),
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}
