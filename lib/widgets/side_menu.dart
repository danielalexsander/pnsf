import 'package:flutter/material.dart';
import 'package:pnsf/main.dart';
import 'package:pnsf/pages/categoria_list.dart';
import 'package:pnsf/pages/listas_list.dart';
import 'package:pnsf/pages/praticar_redirect.dart';

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 160,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/pnsf_banner.jpg'),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.music_note),
            title: const Text('Todas as Cifras'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyHomePage(
                    title: 'Todas as Cifras',
                  ),
                ),
              )
            },
          ),
          ListTile(
            leading: Icon(Icons.category),
            title: const Text('Cifras por Categoria'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoriaList(),
                ),
              )
            },
          ),
          ListTile(
            leading: Icon(Icons.school),
            title: const Text('Praticar'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Practice(),
                ),
              )
            },
          ),
          ListTile(
            leading: Icon(Icons.playlist_add),
            title: const Text('Listas'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyListPage(
                    title: 'Listas',
                  ),
                ),
              )
            },
          ),
        ],
      ),
    );
  }
}
