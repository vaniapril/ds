import 'dart:async';
import 'dart:io';

import 'package:app/db/dictionary/dictionary.dart';
import 'package:app/db/dictionary/field.dart';
import 'package:app/utils/Utils.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dao/dao.dart';


class DatabaseProvider {
  static final DatabaseProvider _singleton = DatabaseProvider._internal();

  factory DatabaseProvider() {
    return _singleton;
  }

  DatabaseProvider._internal();

  late Database _database;

  late Dao _dao;

  Future<void> init() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, "app.db");
    _database = await openDatabase(path, version: 1,
        onCreate: (Database database, int version) async {
          await _createTables(database);
          await _initialData(database);
        });
    _dao = Dao(_database);
    await _dao.init();
  }

  Future<void> _createTables(Database database) async {
    Batch batch = database.batch();
    batch.execute(Field.tableQuery());
    batch.execute(Dictionary.tableQuery1());
    batch.execute(Dictionary.tableQuery2());

    List<dynamic> result = await batch.commit();
  }


  Future<void> _initialData(Database database) async {
    database.rawQuery('INSERT INTO dictionaries(id, title, state) VALUES(?,?,?)', [1, "Сеть", 1]);

    database.rawQuery('INSERT INTO fields(id, title, type, dictionary_id) VALUES(?,?,?,?)', [1,"Название", TEXT, 1]);
    database.rawQuery('INSERT INTO fields(id, title, type, dictionary_id) VALUES(?,?,?,?)', [2,"Дата основания", DATE, 1]);
    database.rawQuery('INSERT INTO fields(id, title, type, dictionary_id) VALUES(?,?,?,?)', [3,"Основатели", TEXT, 1]);
    database.rawQuery('INSERT INTO fields(id, title, type, dictionary_id) VALUES(?,?,?,?)', [4,"Доход (млрд.)", REAL, 1]);
    database.rawQuery('INSERT INTO fields(id, title, type, dictionary_id) VALUES(?,?,?,?)', [5,"Количество ресторанов в Беларуси", INTEGER, 1]);

    database.rawQuery('CREATE TABLE dictionaries_1 ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'main_id INTEGER,'
        'version INTEGER,'
        'field_1 TEXT,'
        'field_2 INTEGER,'
        'field_3 TEXT,'
        'field_4 REAL,'
        'field_5 INTEGER)');

    database.rawQuery('INSERT INTO dictionaries(id, title, state) VALUES(?,?,?)', [2, "Рестораны", 1]);

    database.rawQuery('INSERT INTO fields(id, title, type, dictionary_id) VALUES(?,?,?,?)', [6,"Адрес", TEXT, 2]);
    database.rawQuery('INSERT INTO fields(id, title, type, dictionary_id) VALUES(?,?,?,?)', [7,"Сеть", 1, 2]);
    database.rawQuery('INSERT INTO fields(id, title, type, dictionary_id) VALUES(?,?,?,?)', [8,"Дата открытия", DATE, 2]);
    database.rawQuery('INSERT INTO fields(id, title, type, dictionary_id) VALUES(?,?,?,?)', [9,"Оценка", REAL, 2]);
    database.rawQuery('INSERT INTO fields(id, title, type, dictionary_id) VALUES(?,?,?,?)', [10,"Количество оценок", INTEGER, 2]);

    database.rawQuery('CREATE TABLE dictionaries_2 ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'main_id INTEGER,'
        'version INTEGER,'
        'field_6 TEXT,'
        'field_7 INTEGER,'
        'field_8 INTEGER,'
        'field_9 REAL,'
        'field_10 INTEGER)');

    database.rawQuery('INSERT INTO dictionaries_ids(id, dictionary_id, state) VALUES(?,?,?)', [1,1,1]);
    database.rawQuery('INSERT INTO dictionaries_1(id, main_id, version, field_1, field_2, field_3, field_4, field_5) VALUES(?,?,?,?,?,?,?,?)',
        [1,1,1,'KFC',Utils.toDate('24.09.1952'),'Полковник Сандерс', 17.9, 52]);

    database.rawQuery('INSERT INTO dictionaries_ids(id, dictionary_id, state) VALUES(?,?,?)', [2,1,1]);
    database.rawQuery('INSERT INTO dictionaries_1(id, main_id, version, field_1, field_2, field_3, field_4, field_5) VALUES(?,?,?,?,?,?,?,?)',
        [2,2,1,'McDonald’s',Utils.toDate('15.05.1940'),'Дик и Мак Макдоналды', 4.73, 25]);

    database.rawQuery('INSERT INTO dictionaries_ids(id, dictionary_id, state) VALUES(?,?,?)', [3,1,1]);
    database.rawQuery('INSERT INTO dictionaries_1(id, main_id, version, field_1, field_2, field_3, field_4, field_5) VALUES(?,?,?,?,?,?,?,?)',
        [3,3,1,'Burger King',Utils.toDate('28.07.1954'),'Джеймс Маклэмор и Дэвид Эджертон', 0.117, 41]);


    database.rawQuery('INSERT INTO dictionaries_ids(id, dictionary_id, state) VALUES(?,?,?)', [4,1,1]);
    database.rawQuery('INSERT INTO dictionaries_2(id, main_id, version, field_6, field_7, field_8, field_9, field_10) VALUES(?,?,?,?,?,?,?,?)',
        [1,4,1,'Минск, ТЦ Столица, проспект Независимости 3', 1,Utils.toDate('17.09.2015'), 4.7, 373]);
    database.rawQuery('INSERT INTO dictionaries_ids(id, dictionary_id, state) VALUES(?,?,?)', [5,1,1]);
    database.rawQuery('INSERT INTO dictionaries_2(id, main_id, version, field_6, field_7, field_8, field_9, field_10) VALUES(?,?,?,?,?,?,?,?)',
        [2,5,1,'Минск, ул. Кирова 1', 1,Utils.toDate('24.07.2013'), 4.2, 5974]);

    database.rawQuery('INSERT INTO dictionaries_ids(id, dictionary_id, state) VALUES(?,?,?)', [6,1,1]);
    database.rawQuery('INSERT INTO dictionaries_2(id, main_id, version, field_6, field_7, field_8, field_9, field_10) VALUES(?,?,?,?,?,?,?,?)',
        [3,6,1,'Минск, ул. Кирова 1', 2,Utils.toDate('03.11.2012'), 4.3, 8753]);
    database.rawQuery('INSERT INTO dictionaries_ids(id, dictionary_id, state) VALUES(?,?,?)', [7,1,1]);
    database.rawQuery('INSERT INTO dictionaries_2(id, main_id, version, field_6, field_7, field_8, field_9, field_10) VALUES(?,?,?,?,?,?,?,?)',
        [4,7,1,'Минск, ул. Бобруйская 6', 2,Utils.toDate('08.09.2013'), 3.9, 7079]);

    database.rawQuery('INSERT INTO dictionaries_ids(id, dictionary_id, state) VALUES(?,?,?)', [8,1,1]);
    database.rawQuery('INSERT INTO dictionaries_2(id, main_id, version, field_6, field_7, field_8, field_9, field_10) VALUES(?,?,?,?,?,?,?,?)',
        [5,8,1,'Минск, Привокзальная пл. 7', 3,Utils.toDate('02.10.2017'), 3.7, 766]);
    database.rawQuery('INSERT INTO dictionaries_ids(id, dictionary_id, state) VALUES(?,?,?)', [9,1,1]);
    database.rawQuery('INSERT INTO dictionaries_2(id, main_id, version, field_6, field_7, field_8, field_9, field_10) VALUES(?,?,?,?,?,?,?,?)',
        [6,9,1,'Минск, пл. Свободы 17', 3,Utils.toDate('27.02.2014'), 3.8, 4339]);
  }

  Dao get dao => _dao;
}
