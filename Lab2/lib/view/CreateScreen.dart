import 'package:app/utils/Utils.dart';
import 'package:flutter/material.dart';

import '../db/DatabaseProvider.dart';
import '../db/dictionary/dictionary.dart';
import '../db/dictionary/field.dart';

class CreateScreen extends StatefulWidget{
  const CreateScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return CreateScreenState();
  }
}


class CreateScreenState extends State<CreateScreen>{
  final _list = [RawField('', FieldType.integer.to())];
  String _title = "";

  final _listIsValid = [true];
  bool _titleIsValid = true;

  bool isValid(){
    for(bool valid in _listIsValid){
      if (!valid) return false;
    }
    for(RawField f in _list){
      if(f.title.isEmpty) return false;
    }
    return _titleIsValid && _title.isNotEmpty;
  }

  int count = 1;
  late List<Dictionary> dictionaries;

  @override
  void initState(){
    super.initState();
    dictionaries = DatabaseProvider().dao.stream.value;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Новый справочник"),
        actions: isValid()? [
          IconButton(
              onPressed: () async {
                await DatabaseProvider().dao.create(_title, _list);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check))
        ] : null,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          setState(() {
            _list.add(RawField('', FieldType.integer.to()));
            _listIsValid.add(true);
          });
        },
        child: const Icon(Icons.add),
      ),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(10,30,10,5),
              child: TextField(
                decoration: InputDecoration(
                    labelText: 'Название',
                    errorText: _titleIsValid ? null : 'Ошибка',
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(2))
                    )
                ),
                onChanged: (val){
                  setState(() {
                    _title = val;
                    _titleIsValid = Utils.validateTitle(val);
                  });
                },
              ),
            ),
            const Divider(),
            Expanded(
                child:SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 90),
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int index = 0; index < _list.length; index++)
                          Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: ShapeDecoration(
                                  color: index == 0 ? Color(0xFF4FC3F7) : Colors.white60,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(5))
                                  )
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 5),
                                        child: Icon(
                                            Icons.list_alt
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                                        width: 150,
                                        child: TextField(
                                          onChanged: (value){
                                            setState(() {
                                              _list[index].title = value;
                                              /*
                                        for (int i = 0; i < _list.length; i++){
                                          if(_list.where((element) => element.title == _list[i].title).length > 1){
                                            _listIsValid[i] = false;
                                          } else {
                                            _listIsValid[i] = Utils.validateTitle(_list[i].title);
                                          }
                                        }
                                         */

                                              _listIsValid[index] = Utils.validateTitle(_list[index].title);
                                            });
                                          },
                                          decoration: InputDecoration(
                                              labelText: 'Поле ${index + 1}',
                                              errorText: _listIsValid[index] ? null : 'Ошибка',
                                              border: const OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(2))
                                              )
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 100,
                                        child: DropdownButton(
                                          value: _list[index].type < 0? _list[index].type : 0,
                                          items: [
                                            for(FieldType type in FieldType.simpleValues)
                                              DropdownMenuItem(child: Text(type.name), value: type.to()),
                                            if (dictionaries.isNotEmpty)
                                              DropdownMenuItem(child: Divider()),
                                            if (dictionaries.isNotEmpty)
                                              DropdownMenuItem(child: Text(FieldType.foreign.name), value: 0),
                                          ],
                                          onChanged: (value){
                                            setState(() {
                                              if(value < 0){
                                                _list[index].type = value;
                                              } else {
                                                showDialog(
                                                    context: context,
                                                    builder: (context){
                                                      Dictionary dictionary = dictionaries.first;

                                                      return StatefulBuilder(
                                                          builder: (context, setStatee)=>SimpleDialog(
                                                            children: [
                                                              DropdownButton(
                                                                  value: dictionary,
                                                                  items: dictionaries.map((e) => DropdownMenuItem(child: Text(e.title), value: e)).toList(),
                                                                  onChanged: (value){
                                                                    setStatee((){
                                                                      dictionary = value ?? dictionary;
                                                                    });
                                                                  }
                                                              ),
                                                              TextButton(
                                                                  onPressed: (){
                                                                    setState(() {
                                                                      _list[index].type = dictionary.id;
                                                                      Navigator.pop(context);
                                                                    });
                                                                  },
                                                                  child: Text('Ok')
                                                              )
                                                            ],
                                                          )
                                                      );
                                                    }
                                                );
                                              }
                                            });
                                          },
                                          isExpanded: true,
                                          itemHeight: null,
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      _list.length > 1 ? IconButton(
                                        icon: const Icon(Icons.delete_forever),
                                        onPressed: (){
                                          setState(() {
                                            _list.removeAt(index);
                                          });
                                        },
                                      ) : Container()
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                )
            )
          ],
        ),
      ),
    );
  }

}