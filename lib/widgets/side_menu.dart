import 'package:flutter/material.dart';
import 'package:pnsf/main.dart';
import 'package:pnsf/pages/categoria_list.dart';

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              '',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
                color: Colors.green,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/pnsf.jpg'))),
          ),
          ListTile(
            leading: Icon(Icons.all_inbox_rounded),
            title: Text('Todas as Cifras'),
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
            title: Text('Por Categoria'),
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
            leading: Icon(Icons.person),
            title: Text('Por Artista (Construção)'),
            onTap: () => {Navigator.of(context).pop()},
          ),
        ],
      ),
    );
  }
}
