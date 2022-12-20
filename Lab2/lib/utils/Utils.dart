import 'package:app/db/DatabaseProvider.dart';
import 'package:app/db/dictionary/dictionary.dart';
import 'package:app/db/dictionary/field.dart';

final sysWords = ['ADD', 'EXTERNAL', 'PROCEDURE', 'ALL', 'FETCH','PUBLIC',
  'ALTER', 'FILE', 'RAISERROR', 'AND','FILLFACTOR', 'READ', 'ANY', 'FOR',
  'READTEXT', 'AS','FOREIGN', 'RECONFIGURE', 'ASC', 'FREETEXT', 'REFERENCES',
  'AUTHORIZATION', 'FREETEXTTABLE', 'REPLICATION', 'BACKUP','FROM', 'RESTORE',
  'BEGIN', 'FULL', 'RESTRICT', 'BETWEEN','FUNCTION', 'RETURN', 'BREAK', 'GOTO',
  'REVERT', 'BROWSE','GRANT', 'REVOKE', 'BULK', 'GROUP', 'RIGHT', 'BY','HAVING',
  'ROLLBACK', 'CASCADE', 'HOLDLOCK', 'ROWCOUNT','CASE', 'IDENTITY', 'ROWGUIDCOL',
  'CHECK', 'IDENTITY_INSERT','RULE', 'CHECKPOINT', 'IDENTITYCOL', 'SAVE',
  'CLOSE', 'IF','SCHEMA', 'CLUSTERED', 'IN', 'SECURITYAUDIT', 'COALESCE',
  'INDEX', 'SELECT', 'COLLATE', 'INNER','SEMANTICKEYPHRASETABLE', 'COLUMN',
  'INSERT','SEMANTICSIMILARITYDETAILSTABLE', 'COMMIT', 'INTERSECT',
  'SEMANTICSIMILARITYTABLE', 'COMPUTE', 'INTO', 'SESSION_USER','CONSTRAINT',
  'IS', 'SET', 'CONTAINS', 'JOIN', 'SETUSER','CONTAINSTABLE', 'KEY', 'SHUTDOWN',
  'CONTINUE', 'KILL','SOME', 'CONVERT', 'LEFT', 'STATISTICS', 'CREATE', 'LIKE',
  'SYSTEM_USER', 'CROSS', 'LINENO', 'TABLE', 'CURRENT','LOAD', 'TABLESAMPLE',
  'CURRENT_DATE', 'MERGE', 'TEXTSIZE','CURRENT_TIME', 'NATIONAL', 'THEN',
  'CURRENT_TIMESTAMP','NOCHECK', 'TO', 'CURRENT_USER', 'NONCLUSTERED', 'TOP',
  'CURSOR', 'NOT', 'TRAN', 'DATABASE', 'NULL', 'TRANSACTION','DBCC', 'NULLIF',
  'TRIGGER', 'DEALLOCATE', 'OF','TRUNCATE', 'DECLARE', 'OFF', 'TRY_CONVERT',
  'DEFAULT','OFFSETS', 'TSEQUAL', 'DELETE', 'ON', 'UNION', 'DENY','OPEN',
  'UNIQUE', 'DESC', 'OPENDATASOURCE', 'UNPIVOT','DISK', 'OPENQUERY', 'UPDATE',
  'DISTINCT', 'OPENROWSET','UPDATETEXT', 'DISTRIBUTED', 'OPENXML', 'USE',
  'DOUBLE','OPTION', 'USER', 'DROP', 'OR', 'VALUES', 'DUMP','ORDER', 'VARYING',
  'ELSE', 'OUTER', 'VIEW', 'END','OVER', 'WAITFOR', 'ERRLVL', 'PERCENT', 'WHEN',
  'ESCAPE','PIVOT', 'WHERE', 'EXCEPT', 'PLAN', 'WHILE', 'EXEC','PRECISION',
  'WITH', 'EXECUTE', 'PRIMARY', 'WITHIN GROUP','EXISTS', 'PRINT', 'WRITETEXT',
  'EXIT', 'PROC',

  'FIELDS', 'DICTIONARIES', 'TEXT', 'INTEGER', 'REAL', 'DATE', 'DICTIONARIES_IDS'
];

final RegExp _nameExp = RegExp(r'^[A-Za-z_][A-Za-z0-9@$#_]{0,127}$');

class Utils{
  static bool showFields = false;

  static bool validateTitle(String val){
    //return _nameExp.hasMatch(val) && !sysWords.contains(val.toUpperCase()) && !DatabaseProvider().dao.isExist(val);
    return val.replaceAll(' ', '').isNotEmpty;
  }

  static bool validateText(String val){
    return val.isNotEmpty;
  }

  static bool validateReal(String val){
    return double.tryParse(val) != null;
  }

  static bool validateInteger(String val){
    return int.tryParse(val) != null;
  }

  static String dateToString(int mills){
    final date = DateTime.fromMicrosecondsSinceEpoch(mills);
    return "${date.day.toString().padLeft(2,'0')}.${date.month.toString().padLeft(2,'0')}.${date.year.toString().padLeft(4,'0')}";
  }

  //DD.MM.YYYY
  static int toDate(String date){
    var dateTime = DateTime.parse('${date.substring(6,10)}-${date.substring(3,5)}-${date.substring(0,2)}');
    return dateTime.microsecondsSinceEpoch;
  }

  static String modelToString(Dictionary dictionary, Map<String, dynamic> model) {
    if (showFields){
      String str = '{';
      for (Field field in dictionary.fields) {
        switch (FieldType.from(field.type)) {
          case FieldType.integer:
          case FieldType.text:
          case FieldType.real:
            str += '${model[field.field]}, ';
            break;
          case FieldType.date:
            str += '${dateToString(model[field.field])}, ';
            break;
          case FieldType.foreign:
            str += '${modelToStringBy(field.type, model[field.field])}, ';
            break;
        }
      }

      return str.replaceRange(str.length - 2, str.length, '}');
    } else {
      Field field = dictionary.fields.first;
      switch (FieldType.from(field.type)) {
        case FieldType.integer:
        case FieldType.text:
        case FieldType.real:
          return '${model[field.field]}';
        case FieldType.date:
          return dateToString(model[field.field]);
        case FieldType.foreign:
          return modelToStringBy(field.type, model[field.field]);
      }
    }
  }

  static String modelToStringBy(int dictionaryId, int modelId){
    Dictionary subDictionary = DatabaseProvider().dao.streamAll.value.where((element) => element.id == dictionaryId).first;
    var val = DatabaseProvider().dao.modelStreamAll(subDictionary).value;
    Map<String, dynamic> subModel = DatabaseProvider().dao.modelStreamAll(subDictionary).value.where((element) => element['id'] == modelId).first;

    return modelToString(subDictionary, subModel);
  }
}