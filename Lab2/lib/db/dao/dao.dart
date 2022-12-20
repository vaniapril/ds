import 'package:app/db/dictionary/dictionary.dart';
import 'package:app/db/dictionary/field.dart';
import 'package:app/global.dart';
import 'package:sqflite/sqflite.dart';
import 'package:rxdart/rxdart.dart';

class Dao {
  final Database _database;
  final BehaviorSubject<List<Dictionary>> _subject = BehaviorSubject();
  final BehaviorSubject<List<Dictionary>> _subjectAll = BehaviorSubject();

  final Map<int, BehaviorSubject<List<Map<String, dynamic>>>> _subjects = {};
  final Map<int, BehaviorSubject<List<Map<String, dynamic>>>> _subjectsAll = {};

  ValueStream<List<Dictionary>> get stream => _subject.stream;
  ValueStream<List<Dictionary>> get streamAll => _subjectAll.stream;

  ValueStream<List<Map<String, dynamic>>> modelStream(Dictionary dictionary) => _subjects[dictionary.id]!.stream;
  ValueStream<List<Map<String, dynamic>>> modelStreamAll(Dictionary dictionary) => _subjectsAll[dictionary.id]!.stream;

  Dao(this._database);

  Future<void> init() async{
      await _updateStream();
      await _initList();
  }

  Future<void> _updateStream() async{
    _subject.add(await getList());
    _subjectAll.add(await getListAll());
  }

  Future<void> _initList() async {
    for (Dictionary dictionary in _subject.valueOrNull ?? []){
      _subjects[dictionary.id] = BehaviorSubject();
    }

    for (Dictionary dictionary in _subjectAll.valueOrNull ?? []){
      _subjectsAll[dictionary.id] = BehaviorSubject();
      await _modelUpdateStream(dictionary);
    }
  }

  //Dictionary
  Future<int> delete(Dictionary dictionary) async {
    _subjects[dictionary.id]!.close();
    _subjects.remove(dictionary.id);
    var result = await _database.update(dictionaryTableName,
        {'state': 0},
        where: 'id = ?',
        whereArgs: [dictionary.id]);
    await _updateStream();
    return result;
  }

  Future<Dictionary> get(int id) async {
    final data = await _database.query(dictionaryTableName,
        where: "id = ?",
        whereArgs: [id]
    );
    Dictionary dictionary = Dictionary.fromJson(data.first);

    final fieldData = await _database.query(dictionaryFieldTableName,
          where: 'dictionary_id = ?',
          whereArgs: [id],
          orderBy: 'id');
    dictionary.fields = fieldData.isNotEmpty
        ? fieldData.map((json) => Field.fromJson(json)).toList()
        : [];

    return dictionary;
  }

  Future<List<Dictionary>> getList() async {
    final data = await _database.query(dictionaryTableName,
        where: "state > 0",
        orderBy: 'id'
    );
    List<Dictionary> result = data.isNotEmpty
        ? data.map((json) => Dictionary.fromJson(json)).toList()
        : [];
    for (Dictionary d in result){
      final data = await _database.query(dictionaryFieldTableName,
          where: 'dictionary_id = ?',
          whereArgs: [d.id],
          orderBy: 'id');
      d.fields = data.isNotEmpty
          ? data.map((json) => Field.fromJson(json)).toList()
          : [];
    }

    return result;
  }

  Future<List<Dictionary>> getListAll() async {
    final data = await _database.query(dictionaryTableName,
        orderBy: 'id'
    );
    List<Dictionary> result = data.isNotEmpty
        ? data.map((json) => Dictionary.fromJson(json)).toList()
        : [];
    for (Dictionary d in result){
      final data = await _database.query(dictionaryFieldTableName,
          where: 'dictionary_id = ?',
          whereArgs: [d.id],
          orderBy: 'id');
      d.fields = data.isNotEmpty
          ? data.map((json) => Field.fromJson(json)).toList()
          : [];
    }

    return result;
  }

  Future<int> create(String title, List<RawField> fields) async {
    var result = await _database.insert(dictionaryTableName, {
      'title': title,
      'state': 1
    });

    for(RawField f in fields){
      await _database.insert(dictionaryFieldTableName, {
      'title': f.title,
      'type': f.type,
      'dictionary_id': result
      });
    }

    Dictionary dictionary = await get(result);
    await _createTable(dictionary);
    _subjects[dictionary.id] = BehaviorSubject();
    _subjectsAll[dictionary.id] = BehaviorSubject();
    await _updateStream();
    return result;
  }

  Future<void> _createTable(Dictionary model) async {
    Batch batch = _database.batch();
    batch.execute(model.dictionaryTableQuery());
    List<dynamic> result = await batch.commit();
  }

  void dispose(){
    _subject.close();
  }

  //Model

  Future<void> _modelUpdateStream(Dictionary dictionary) async{
    if(_subjects.containsKey(dictionary.id)){
      _subjects[dictionary.id]!.add(await modelGetList(dictionary));
    }
    _subjectsAll[dictionary.id]!.add(await modelGetListAll(dictionary));
  }

  Future<int> modelDelete(Dictionary dictionary, Map<String, dynamic> model) async {
    var result = await _database.update(dictionaryIdTableName,
        {'state': 0},
        where: 'id = ?',
        whereArgs: [model['main_id']]);
    await _modelUpdateStream(dictionary);
    return result;
  }

  Future<int> modelCreate(Dictionary dictionary, Map<String, dynamic> model) async {
    var result = await _database.insert(dictionaryIdTableName,{
      'state': 1
    });
    model['main_id'] = result;
    model['version'] = 0;
    var result2 = await _database.insert(dictionary.tableName(), model);

    await _modelUpdateStream(dictionary);
    return result2;
  }

  Future<int> modelUpdate(Dictionary dictionary, Map<String, dynamic> model) async {
    //var result = await _database.update(dictionary.tableName(), {'version': -1}, where: "version > ?", whereArgs: [model['version']]);

    model['version'] = model['version'] + 1;
    model['id'] = null;
    var result2 = await _database.insert(dictionary.tableName(), model);
    await _modelUpdateStream(dictionary);
    return result2;
  }

  Future<Map<String, dynamic>> modelGet(Dictionary dictionary, int id) async {
    final data = await _database.query(dictionary.tableName(),
        where: "id = ?",
        whereArgs: [id]
    );

    return data.first;
  }

  Future<List<Map<String, dynamic>>> modelGetList(Dictionary dictionary) async {
    final data = await _database.query(dictionaryIdTableName, where: "state > 0");

    List<Map<String, dynamic>> result = data.isNotEmpty
        ? data
        : [];
    List<Map<String, dynamic>> list = [];

    for (Map<String, dynamic> id in result){
      final el = await _database.query(dictionary.tableName(), where: "main_id = ? AND version > -1", whereArgs: [id["id"]], orderBy: 'version');
      if (el.isNotEmpty){
        list.add(el.last);
      }
    }

    return list;
  }

  Future<List<Map<String, dynamic>>> modelGetListAll(Dictionary dictionary) async {
    final data = await _database.query(dictionary.tableName(), orderBy: 'id');

    List<Map<String, dynamic>> result = data.isNotEmpty
        ? data
        : [];

    return result;
  }

  Future<List<Map<String, dynamic>>> modelGetAllVersions(Dictionary dictionary, Map<String, dynamic> model) async {
    final data = await _database.query(dictionary.tableName(), where: "main_id = ? AND version > -1", whereArgs: [model["main_id"]], orderBy: 'version');

    List<Map<String, dynamic>> result = data.isNotEmpty
        ? data
        : [];

    return result;
  }
}