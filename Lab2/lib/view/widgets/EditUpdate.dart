import 'dart:math';

import 'package:app/utils/Utils.dart';
import 'package:flutter/material.dart';

import '../../db/DatabaseProvider.dart';
import '../../db/dictionary/dictionary.dart';
import '../../db/dictionary/field.dart';


class EditUpdate extends StatefulWidget{
  final Dictionary dictionary;
  final Map<String, dynamic> model;
  final ValueChanged<bool> update;

  const EditUpdate(this.dictionary, this.model, this.update, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _EditUpdateState();
  }
}

class _EditUpdateState extends State<EditUpdate>{
  late List<bool> _listIsValid;
  late Map<String, TextEditingController> _dateController;

  @override
  void initState() {
    _listIsValid = widget.dictionary.fields.map((e) => true).toList();

    _dateController = {};

    for(Field field in widget.dictionary.fields){
      if(FieldType.from(field.type) == FieldType.date){
        _dateController[field.field] = TextEditingController(text: widget.model[field.field] != null ? Utils.dateToString(widget.model[field.field]) : null);
      }
    }
    super.initState();
  }

  bool isValid(){
    for(bool valid in _listIsValid){
      if (!valid) return false;
    }
    for(Field field in widget.dictionary.fields){
      if (widget.model[field.field] == null) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            for (int index = 0; index < widget.dictionary.fields.length; index++)
              item(index)
          ],
        )
    );
  }

  Widget item(int index){
    Field field = widget.dictionary.fields[index];
    FieldType type = FieldType.from(field.type);
    return Padding(
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
                Padding(
                  padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 5),
                  child: Icon(
                      type.icon()
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                  width: 250,
                  child: type == FieldType.foreign ?
                  DropdownButton(
                    items: [
                      for (Map<String, dynamic> e in DatabaseProvider().dao.stream.value.where((element) => element.id == field.type).isNotEmpty
                          ? DatabaseProvider().dao.modelStream(DatabaseProvider().dao.stream.value.where((element) => element.id == field.type).first).valueOrNull ?? [] : [])
                        DropdownMenuItem(
                          value: e['id'],
                          child: Text(Utils.modelToString(DatabaseProvider().dao.stream.value.where((element) => element.id == field.type).first, e)),
                        )
                    ],
                    onChanged: (value){
                      setState(() {
                        widget.model[field.field] = value;
                        if (value != null){
                          _listIsValid[index] = true;
                        }
                      });
                      widget.update(isValid());
                    },
                    value: widget.model[field.field],
                    hint: Text(widget.model[field.field] != null?  Utils.modelToStringBy(field.type, widget.model[field.field]) : '${widget.model[field.field]}'),
                    isExpanded: true,
                    itemHeight: null,
                  )
                      :
                  type != FieldType.date
                      ? TextFormField(
                    keyboardType: type == FieldType.integer || type == FieldType.real ? TextInputType.number : null,
                    maxLines: type == FieldType.text? null : 1,
                    initialValue: widget.model[field.field] != null ? '${widget.model[field.field]}' : null,
                    onChanged: (value){
                      setState(() {
                        switch(type){
                          case FieldType.integer:
                            _listIsValid[index] = Utils.validateInteger(value);
                            widget.model[field.field] = int.tryParse(value);
                            break;
                          case FieldType.text:
                            _listIsValid[index] = Utils.validateText(value);
                            widget.model[field.field] = value;
                            break;
                          case FieldType.real:
                            _listIsValid[index] = Utils.validateReal(value);
                            widget.model[field.field] = double.tryParse(value);
                            break;
                          case FieldType.date:
                          case FieldType.foreign:
                            break;
                        }
                      });
                      widget.update(isValid());
                    },
                    decoration: InputDecoration(
                      labelText: field.title,
                      errorText: _listIsValid[index] ? null : 'Ошибка',
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(2))
                      ),
                    ),
                  ) : TextFormField(
                    controller: _dateController[field.field],
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1970),
                          lastDate: DateTime(2101)
                      );
                      if (pickedDate != null){
                        setState(() {
                          widget.model[field.field] = pickedDate.microsecondsSinceEpoch;
                          _dateController[field.field]?.text =
                              Utils.dateToString(widget.model[field.field]) ?? '';
                        });

                        widget.update(isValid());
                      }
                    },
                    decoration: InputDecoration(
                        labelText: field.title,
                        errorText: _listIsValid[index] ? null : 'Ошибка',
                        border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(2))
                        )
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container()
              ],
            )
          ],
        ),
      ),
    );
  }

}
