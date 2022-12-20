import 'dart:math';

import 'package:app/db/dictionary/dictionary.dart';
import 'package:app/utils/Utils.dart';
import 'package:app/view/AddScreen.dart';
import 'package:flutter/material.dart';

import '../db/DatabaseProvider.dart';
import '../db/dictionary/field.dart';

class TableScreen extends StatefulWidget{
  final Dictionary dictionary;

  const TableScreen(this.dictionary, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _TableScreenState();
  }
}

class _TableScreenState extends State<TableScreen>{

  late Field orderBy;
  late bool reverse;

  @override
  void initState() {
    orderBy = widget.dictionary.fields.first;
    reverse = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.dictionary.title),
          actions: [
            IconButton(
                onPressed: () async {
                  Map<String, dynamic> model = {};

                  for(Field field in widget.dictionary.fields){
                    switch (FieldType.from(field.type)){
                      case FieldType.integer:
                        var r = Random();
                        model[field.field] = r.nextInt(10000000);
                        break;
                      case FieldType.text:
                        var r = Random();
                        const char = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ';
                        model[field.field] = String.fromCharCodes(List.generate(r.nextInt(20) + 1, (index) => char.codeUnits[r.nextInt(char.length)]));
                        break;
                      case FieldType.real:
                        var r = Random();
                        model[field.field] = double.parse(((r.nextDouble() * 1000) - 500).toStringAsFixed(3));
                        break;
                      case FieldType.date:
                        var r = Random();
                        model[field.field] = r.nextInt(670360400) * 1000000 + 1000000000000000;
                        break;
                      case FieldType.foreign:
                        Dictionary subDictionary = DatabaseProvider().dao.streamAll.value.where((element) => element.id == field.type).first;
                        List<Map<String, dynamic>> list = DatabaseProvider().dao.modelStreamAll(subDictionary).value;
                        if (list.isNotEmpty){
                          var r = Random();
                          model[field.field] = list[r.nextInt(list.length)]['id'];
                        } else {
                          return;
                        }
                        break;
                    }
                  }

                  await DatabaseProvider().dao.modelCreate(widget.dictionary, model);
                },
                icon: Icon(Icons.add_box_outlined)
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddScreen(widget.dictionary)));
            },
            child: const Icon(Icons.add)
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: DatabaseProvider().dao.modelStream(widget.dictionary),
          builder: (context, snapshot){
            List<Map<String, dynamic>> list = snapshot.data ?? [];
            list.sort((m1, m2) => m1[orderBy.field].compareTo(m2[orderBy.field]) * (reverse? -1: 1));

            final rowHeight = list.map((e){
              int maxLines = 1;
              for(Field field in widget.dictionary.fields){
                if(field.type == FieldType.text.to()){
                  String str = e[field.field];
                  if (str != null){
                    maxLines = max(str.split('\n').length, maxLines);
                  }
                }
                if(FieldType.from(field.type) == FieldType.foreign){
                  String str = Utils.modelToStringBy(field.type, e[field.field]);
                  if (str != null){
                    maxLines = max(str.split('\n').length, maxLines);
                  }
                }
              }
              return 30.0 + 16 * (maxLines - 1);
            }).toList();

            return list.isNotEmpty ? Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: 15, right: 15),
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(top: 15, bottom: 90),
                  scrollDirection: Axis.vertical,
                  child: Row(
                    children: [
                      for (Field field in widget.dictionary.fields)
                        IntrinsicWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              InkWell(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 0.5),
                                    color: Colors.grey[300],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          field.title,
                                          textAlign: TextAlign.center
                                      ),
                                      if(field == orderBy)
                                        Icon(reverse? Icons.arrow_upward
                                            : Icons.arrow_downward)
                                    ],
                                  ),
                                ),
                                onTap: (){
                                  setState(() {
                                    if(orderBy == field){
                                      reverse = !reverse;
                                    } else {
                                      orderBy = field;
                                    }
                                  });
                                },
                              ),
                              for (int i = 0; i < list.length; i++)
                                InkWell(
                                  child: Container(
                                    height: rowHeight[i],
                                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 0.5,
                                          color: Colors.grey.withOpacity(0.5),
                                        )),
                                    child: Text(
                                        FieldType.from(field.type) == FieldType.date ? Utils.dateToString(list[i][field.field]):
                                        FieldType.from(field.type) == FieldType.foreign ? Utils.modelToStringBy(field.type, list[i][field.field]):
                                        '${list[i][field.field]}',
                                        textAlign: TextAlign.center
                                    ),
                                  ),
                                  onTap: () async {
                                    final versions = await DatabaseProvider().dao.modelGetAllVersions(widget.dictionary, list[i]);
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddScreen(
                                        widget.dictionary,
                                        allVersions: versions
                                    )));
                                  },
                                )
                            ],
                          ),
                        ),
                      Column(
                        children: [
                          Container(
                            height: 40,
                          ),
                          for (int i = 0; i < list.length; i++)
                            InkWell(
                              child: Container(
                                height: rowHeight[i],
                                child: Icon(Icons.delete_forever),
                              ),
                              onTap: (){
                                DatabaseProvider().dao.modelDelete(widget.dictionary, list[i]);
                              },
                            )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ) : Center(
              child: Text('Справочник ${widget.dictionary.title} пуст'),
            );
          },
        )
    );
  }

}



