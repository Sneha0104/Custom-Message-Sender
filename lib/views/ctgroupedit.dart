import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:multiple_select/multi_drop_down.dart';
import 'package:multiple_select/multiple_select.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditView extends StatefulWidget {
  EditView(this.ctJson, this.indx, this.cts);

  final ctJson;
  final List cts;
  final int indx;

  @override
  _EditViewState createState() => _EditViewState();
}

class _EditViewState extends State<EditView> {
  List contacts;
  int listLen;
  var newCt;
  List val;
  List _selectedValues = [];

  @override
  void initState() {
    super.initState();
    for (var ct in widget.ctJson["contacts"]) {
      _selectedValues.add(ct.toString().split(":")[1]);
    }
  }

  getVal() {
    List<MultipleSelectItem> dispVal = [];
    for (var ct in widget.cts) {
      dispVal.add(MultipleSelectItem.build(
        value: ct["phoneNumber"].toString().split(":")[1],
        display: ct["fullName"].toString(),
        content: ct["fullName"].toString(),
      ));
    }
    return dispVal;
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.cts);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MultipleDropDown(
                placeholder: widget.ctJson['name'],
                disabled: false,
                values: _selectedValues,
                elements: getVal(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Text("SAVE"),
        // padding: EdgeInsets.only(left: 100, right: 100),
        onPressed: () async {
          var newCtList = [];
          for (var selCt in _selectedValues) {
            var ctInfo;
            for (var ct in widget.cts) {
              if (selCt.toString() ==
                  ct["phoneNumber"].toString().split(":")[1]) {
                ctInfo = ct;
                break;
              }
            }
            newCtList.add(ctInfo["phoneNumber"]);
          }
          SharedPreferences prefs = await SharedPreferences.getInstance();
          List<String> ctLists = prefs.getStringList("contactsGrp");
          List contactsJson = jsonDecode(ctLists.toString());
          List<String> ctj = [];
          for (var ct in contactsJson) {
            List cts;
            if (ct["name"] == widget.ctJson["name"]) {
              cts = newCtList;
            } else {
              cts = ct["contacts"];
            }
            ctj.add(jsonEncode({"name": ct["name"], "contacts": cts}));
          }
          prefs.setStringList("contactsGrp", ctj);
          Navigator.pop(context);
        },
      ),
    );
  }
}
