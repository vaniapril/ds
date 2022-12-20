import 'package:app/db/DatabaseProvider.dart';
import 'package:app/db/dictionary/dictionary.dart';
import 'package:app/utils/Utils.dart';
import 'package:app/view/CreateScreen.dart';
import 'package:flutter/material.dart';

import 'TableScreen.dart';

class ListScreen extends StatefulWidget{
  const ListScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ListScreenState();
  }
}

class _ListScreenState extends State<ListScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Справочники"),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(context: context, builder: (context) {
                  return SimpleDialog(
                    children: [
                      StatefulBuilder(builder: (context, setState){
                        return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Показывать поля'),
                              Switch(value: Utils.showFields, onChanged: (value){
                                setState(() {
                                  Utils.showFields = value;
                                });
                              })
                            ]);
                      })
                    ],
                  );
                });
              },
              icon: const Icon(Icons.settings),
            ),
            IconButton(
              onPressed: () {
                showDialog(context: context, builder: (context) {
                  return AlertDialog(
                    title: Text('Выполнил:'),
                    content: Text('Прилепский Иван Игоревич, 4 курс, 4 группа, 2022 год'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Ok')
                      )
                    ],
                  );
                });
              },
              icon: const Icon(Icons.info_outline),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateScreen()));
            },
            child: const Icon(Icons.add)
        ),
        body: StreamBuilder<List<Dictionary>>(
          stream: DatabaseProvider().dao.stream,
          builder: (context, snapshot){
            List<Dictionary> list = snapshot.data ?? [];
            return ListView.builder(
                padding: EdgeInsets.only(bottom: 90),
                itemCount: list.length,
                itemBuilder: (context ,index) => ListTile(
                  leading: const Icon(
                      Icons.list_alt
                  ),
                  title: Text(
                      list[index].title
                  ),
                  subtitle: Text(
                      list[index].fieldsString()
                  ),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TableScreen(list[index])));
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete_forever),
                    onPressed: (){
                      showDialog(context: context, builder: (context){
                        return AlertDialog(
                          title: Text('Delete ${list[index].title}?'),
                          actions: [
                            TextButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                },
                                child: Text("Cancel")
                            ),
                            TextButton(
                                onPressed: (){
                                  DatabaseProvider().dao.delete(list[index]);
                                  Navigator.pop(context);
                                },
                                child: Text("Ok")
                            )
                          ],
                        );
                      });
                    },
                  ),
                )
            );
          },
        )
    );
  }
}