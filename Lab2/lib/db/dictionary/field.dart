import 'package:app/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Field {
  int id;
  String title;
  int type;
  int dictionary_id;

  String get field => "field_$id";

  Field(this.id, this.title, this.type, this.dictionary_id);

  FieldType getType(){
    return FieldType.from(type);
  }

  String get queryName{
    return "$field ${getType().type()}";
  }

  String get queryForeign{
    return getType() == FieldType.foreign? "FOREIGN KEY($field) REFERENCES ${dictionaryTableName}_$type(id)" : "";
  }

  factory Field.fromJson(Map<String, dynamic> json) => Field(
      json['id'],
      json['title'],
      json['type'],
      json['dictionary_id']);

  static String tableQuery() {
    return "CREATE TABLE $dictionaryFieldTableName ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "title TEXT,"
        "type INTEGER,"
        "dictionary_id INTEGER,"
        "FOREIGN KEY(dictionary_id) REFERENCES $dictionaryTableName(id) ON DELETE CASCADE ON UPDATE CASCADE"
        ");";
  }
}

const INTEGER = -1;
const DATE = -2;
const TEXT = -3;
const REAL = -4;

enum FieldType {
  integer,
  text,
  real,
  date,
  foreign;

  static FieldType from(int id){
    switch(id){
      case INTEGER:
        return FieldType.integer;
      case DATE:
        return FieldType.date;
      case TEXT:
        return FieldType.text;
      case REAL:
        return FieldType.real;
      default:
        return FieldType.foreign;
    }
  }

  int to(){
    switch(this){
      case FieldType.integer:
        return INTEGER;
      case FieldType.date:
        return DATE;
      case FieldType.text:
        return TEXT;
      case FieldType.real:
        return REAL;
      case FieldType.foreign:
        return 0;
    }
  }

  String type(){
    switch(this){
      case FieldType.integer:
      case FieldType.date:
      case FieldType.foreign:
        return "INTEGER";
      case FieldType.text:
        return "TEXT";
      case FieldType.real:
        return "REAL";
    }
  }

  IconData icon(){
    switch(this){
      case FieldType.integer:
        return Icons.dialpad;
      case FieldType.date:
        return Icons.calendar_month;
      case FieldType.text:
        return Icons.text_fields;
      case FieldType.real:
        return Icons.numbers;
      case FieldType.foreign:
        return Icons.insert_link;
    }
  }

  static List<FieldType> get simpleValues{
    return FieldType.values.where((element) => element != FieldType.foreign).toList();
  }
}

class RawField{
  String title;
  int type;

  RawField(this.title, this.type);
}
