import '../../global.dart';
import 'field.dart';


class Dictionary{
  int id;
  String title;
  List<Field> fields;

  Dictionary(this.id, this.title): fields = [];

  factory Dictionary.fromJson(Map<String, dynamic> json) => Dictionary(
      json['id'],
      json['title']
  );

  String fieldsString(){
    String s = "";
    if (fields.isNotEmpty){
      s = fields[0].title;
      for (int i = 1; i < fields.length; i++){
        s += "/${fields[i].title}";
      }
    }
    return s.isNotEmpty? s : '-';
  }

  String tableName(){
    return "${dictionaryTableName}_$id";
  }

  String dictionaryTableQuery() {
    String query = "CREATE TABLE ${tableName()} ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "main_id INTEGER,"
        "version INTEGER";

    for (Field f in fields){
      query += ',${f.queryName}';
    }

    for (Field f in fields){
      if (f.getType() == FieldType.foreign){
        query += ',${f.queryForeign}';
      }
    }
    query += ",FOREIGN KEY(main_id) REFERENCES $dictionaryIdTableName(id) ON DELETE CASCADE ON UPDATE CASCADE)";
    return query;
  }

  static String tableQuery1() {
    return "CREATE TABLE $dictionaryTableName ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "title TEXT,"
        "state INTEGER"
        ")";
  }

  static String tableQuery2() {
    return "CREATE TABLE $dictionaryIdTableName ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "dictionary_id INTEGER,"
        "state INTEGER,"
        "FOREIGN KEY(dictionary_id) REFERENCES $dictionaryTableName(id) ON DELETE CASCADE ON UPDATE CASCADE"
        ")";
  }
}