import 'package:sqflite/sqflite.dart' as sql;

class DatabaseAPP {
  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'databaseapp.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<void> createTables(sql.Database database) async {
    // Cria tabela Listas
    await database.execute(
      'CREATE TABLE listas(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, titulo TEXT, ids_lista TEXT );',
    );
  }

  // Pega todas as Listas
  static Future<List<Map<String, dynamic>>> getListas() async {
    final db = await DatabaseAPP.db();
    return db.query('listas', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getLastIdLista() async {
    final db = await DatabaseAPP.db();

    return db.query('listas', orderBy: "id DESC", limit: 1);
  }

  // Insert de Nova Lista
  static Future<int> setLista(String titulo) async {
    final db = await DatabaseAPP.db();

    final data = {'titulo': titulo};
    print('Criando Nova Lista');
    print(data);

    final result = await db.insert('listas', data);
    return result;
  }

  // Update Lista
  static Future updateLista(String ids_lista, int id_lista) async {
    final db = await DatabaseAPP.db();

    final data = {
      'ids_lista': ids_lista,
    };

    final result = await db.update('listas', data, where: "id = ${id_lista}");
    return result;
  }

  // Delete Lista
  static Future deleteLista(int idDelete) async {
    final db = await DatabaseAPP.db();
    await db.delete('listas', where: 'id = ${idDelete}');
  }
}
