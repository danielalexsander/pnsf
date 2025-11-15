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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: categorias.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      '${idCategorias[index]}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 21, 56, 115),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  categorias[index],
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
        ),
      ),
    );
  }
}
