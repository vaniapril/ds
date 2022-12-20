import 'package:app/utils/Utils.dart';
import 'package:app/view/widgets/EditUpdate.dart';
import 'package:flutter/material.dart';

import '../db/DatabaseProvider.dart';
import '../db/dictionary/dictionary.dart';
import '../db/dictionary/field.dart';

class AddScreen extends StatefulWidget{
  final Dictionary dictionary;
  final List<Map<String, dynamic>>? allVersions;

  const AddScreen(this.dictionary, {this.allVersions, super.key});

  @override
  State<StatefulWidget> createState() {
    return _AddScreenState();
  }
}

class _AddScreenState extends State<AddScreen>{
  late int currentVersion;
  late int maxVersion;
  late EditUpdate child;

  late Map<String, dynamic> model;
  bool isValid = false;

  @override
  void initState() {
    currentVersion = (widget.allVersions?.length ?? 1) - 1;
    maxVersion = currentVersion;

    child = newChild();

    super.initState();
  }

  EditUpdate newChild(){
    model = {};
    model.addEntries(widget.allVersions?[currentVersion].entries ?? widget.dictionary.fields.map((e) => MapEntry(e.field, null)));

    return EditUpdate(
        widget.dictionary,
        model,
        (value){
          setState(() {
            isValid = value;
          });
        },
        key: UniqueKey()
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: widget.allVersions == null ? Text("Создать") : Text("Измененить"),
        actions: [
          if(widget.allVersions != null)
          IconButton(
              onPressed: currentVersion > 0? () async {
                setState(() {
                  currentVersion -= 1;
                  child = newChild();
                });
              } : null,
              icon: const Icon(Icons.chevron_left)
          ),
          if(widget.allVersions != null)
          IconButton(
              onPressed: currentVersion < maxVersion? () async {
                setState(() {
                  currentVersion += 1;
                  child = newChild();
                });
              } : null,
              icon: const Icon(Icons.chevron_right)
          ),
          IconButton(
              onPressed: isValid? () async {
                if (widget.allVersions == null){
                  await DatabaseProvider().dao.modelCreate(widget.dictionary, model);
                } else {
                  model['version'] = maxVersion;
                  await DatabaseProvider().dao.modelUpdate(widget.dictionary, model);
                }
                Navigator.pop(context);
              } : null,
              icon: const Icon(Icons.check)
          ),
        ],
      ),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: child,
      ),
    );
  }

}
