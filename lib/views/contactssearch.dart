import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:custom_message_sender/util/contacts.dart';
import 'package:custom_message_sender/util/extensions.dart';
import 'package:custom_message_sender/views/ctgroupedit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactsSelector extends StatefulWidget {
  ContactsSelector(this.contacts);
  final List contacts;

  @override
  _ContactsSelectorState createState() => _ContactsSelectorState();
}

class _ContactsSelectorState extends State<ContactsSelector> {
  List val;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  // automate group button
  IconButton automateGroupButton(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.brightness_auto),
        onPressed: () async {
          // Handle onPress
          // SharedPreferences prefs = await SharedPreferences.getInstance();
          //TextEditingController text = new TextEditingController();
          TextEditingController groupControl = TextEditingController();
          TextEditingController locationControl = TextEditingController();
          TextEditingController classControl = TextEditingController();
          TextEditingController typeControl = TextEditingController();
          //take the details to filter the group
          await automateGroupForm(context, groupControl, locationControl,
              classControl, typeControl);
        });
  }

  IconButton addGroupButton(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.add),
        onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          TextEditingController text = new TextEditingController();
          await enterGroupName(context, text);
          val = null;
          if (text.text.isNotEmpty) {
            await showContactsSelector(text);
            if (val != null) {
              var data = {"name": text.text, "contacts": val};
              List<String> ctLists = prefs.getStringList("contactsGrp");
              if (ctLists == null) {
                ctLists = [];
                ctLists.add(jsonEncode(data));
                prefs.setStringList("contactsGrp", ctLists);
              } else {
                ctLists.add(jsonEncode(data));
                prefs.setStringList("contactsGrp", ctLists);
              }
            }
          }
          setState(() {});
        });
  }

  IconButton clearSharedPrefs() {
    return IconButton(
        icon: Icon(Icons.delete),
        onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.clear();
          setState(() {});
        });
  }

// automate group form
  Future<String> automateGroupForm(
      BuildContext context,
      TextEditingController groupControl,
      TextEditingController locationControl,
      TextEditingController classControl,
      TextEditingController typeControl) {
    // func for dialog | accept text and return to icon

    return showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              title: Text("Group Name"),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: groupControl,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Group Name'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: locationControl,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Location'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: classControl,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Class'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: typeControl,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Type Y or N or group name'),
                  ),
                ),
                FlatButton(
                    onPressed: () async {
                      String message = await addCustomGroup(
                          groupControl.text,
                          locationControl.text,
                          classControl.text,
                          typeControl.text);
                      Fluttertoast.showToast(msg: message);
                      // Close the popup
                      Navigator.pop(context, "Group Name");
                      // Refresh the group list widget
                      setState(() {});
                    },
                    child: Text("OK"))
              ],
            ));
  }

  Future enterGroupName(BuildContext context, TextEditingController text) {
    return showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              title: Text("Enter Contact Group Name"),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: text,
                  ),
                ),
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("OK"))
              ],
            ));
  }

  Future<String> addCustomGroup(String groupName, String locationName,
      String className, String typeName) async {
    List contacts = await getContacts();
    List filteredContacts;

    filteredContacts = contacts
        .where((ct) {
          print(typeName);
          List splitList = ct["fullName"].split('-');
          //  location , class and typeName are entered
          if (!locationName.isNullOrEmpty() &&
              !className.isNullOrEmpty() &&
              !typeName.isNullOrEmpty() &&
              splitList.length > 0) {
            if (locationName == splitList[0].trim() &&
                hasClassNameInFullName(splitList, className) &&
                hasType(splitList, typeName.trim())) {
              return true;
            }
           
          }
           // Only locationName is entered 
          else if (className.isNullOrEmpty() &&
              typeName.isNullOrEmpty() &&
              !locationName.isNullOrEmpty() &&
              splitList.length > 0 &&
              locationName == splitList[0].trim()) {
            return true;
            
          } 
          // Only className is entered
          else if (locationName.isNullOrEmpty() &&
              typeName.isNullOrEmpty() &&
              !className.isNullOrEmpty() &&
              splitList.length > 1 &&
              hasClassNameInFullName(splitList, className)) {
            return true;
          } 
          //Only typeName is entered
          else if (locationName.isNullOrEmpty() &&
              className.isNullOrEmpty() &&
              !typeName.isNullOrEmpty() &&
              hasType(splitList, typeName.trim())) {
            print("tu");
            return true;
          }
          //location and typeName  entered
           if (!locationName.isNullOrEmpty() &&
              className.isNullOrEmpty() &&
              !typeName.isNullOrEmpty() &&
              splitList.length > 0) {
            if (locationName == splitList[0].trim() &&
                hasType(splitList, typeName.trim())) {
              return true;
            }
           
          }
          //location and className entered
           if (!locationName.isNullOrEmpty() &&
              !className.isNullOrEmpty() &&
              typeName.isNullOrEmpty() &&
              splitList.length > 0) {
            if (locationName == splitList[0].trim() &&
                hasClassNameInFullName(splitList, className) 
                ) {
              return true;
            }
           
          }
          //className and typeName
           if (locationName.isNullOrEmpty() &&
              !className.isNullOrEmpty() &&
              !typeName.isNullOrEmpty() &&
              splitList.length > 0) {
            if (hasClassNameInFullName(splitList, className) &&
                hasType(splitList, typeName.trim())) {
              return true;
            }
           
          }
          return false;
        })
        .map((ct) => ct["phoneNumber"])
        .toList();

    print(filteredContacts);

    if (filteredContacts.length == 0) {
      return "No contacts found for this filter";
    }

    // add the contacts to a new group
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = {"name": groupName, "contacts": filteredContacts};
    // Fetch existing groups from shared preferences
    List<String> ctLists = prefs.getStringList("contactsGrp");
    if (ctLists == null) {
      ctLists = [];
      // Add the group and its contacts
      ctLists.add(jsonEncode(data));
      // Save the group to shared prefs
      prefs.setStringList("contactsGrp", ctLists);
    } else {
      // Add the group and its contacts
      ctLists.add(jsonEncode(data));
      // Save the group to shared prefs
      prefs.setStringList("contactsGrp", ctLists);
    }

    return "Group created";
  }

  hasClassNameInFullName(List splitList, className) {
    if (splitList.length > 1 &&
        splitList[1].trim().toLowerCase() == className.trim().toLowerCase()) {
      return true;
    } else if (splitList.length > 2 && splitList[2].trim().toLowerCase() == className.trim().toLowerCase()) {
      return true;
    } else {
      return false;
    }
  }

  List paidTime = ["2W", "1M", "3M", "6M", "1Y"];
// to check if type is paid or not
  hasType(List splitList, typeName) {
    // print(paidTime.contains(splitList[2].trim()));

    //print(splitList[2]);
    if (splitList.length > 2 &&
        paidTime.contains(splitList[2].trim()) &&
        typeName == "Y") {
      return true;
    } else if (splitList.length > 2 &&
        !paidTime.contains(splitList[2].trim()) &&
        typeName == "N") {
      return true;
    } else if (typeName != "Y" &&
        typeName != "N" &&
        splitList.length > 2 &&
        typeName.trim().toLowerCase() == splitList[1].trim().toLowerCase()) {
      return true;
    } else {
      return false;
   }
  }

  showContactsSelector(TextEditingController text) {
    return showModalBottomSheet(
        context: context,
        builder: (context) => Form(
              key: _formKey,
              autovalidate: true,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new MultiSelect(
                          titleText: text.text,
                          validator: (dynamic value) {
                            if (value == null) {
                              return 'Please select one or more contact(s)';
                            }
                            return null;
                          },
                          errorText: 'Please select one or more contact(s)',
                          dataSource: widget.contacts,
                          textField: 'fullName',
                          valueField: 'phoneNumber',
                          filterable: true,
                          onSaved: (value) {
                            val = value;
                          }),
                    ),
                  ),
                  FlatButton(
                      onPressed: () {
                        _onFormSaved();
                        Navigator.pop(context);
                      },
                      child: Text("Save")),
                ],
              ),
            ));
  }

  void _onFormSaved() {
    final FormState form = _formKey.currentState;
    form.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Select Contact Group"),
          actions: <Widget>[
            automateGroupButton(context),
            addGroupButton(context),
            clearSharedPrefs()
          ],
        ),
        body: FutureBuilder(
          future: SharedPreferences.getInstance(),
          builder: (BuildContext context,
              AsyncSnapshot<SharedPreferences> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return LinearProgressIndicator();
                break;
              default:
                List<String> data = snapshot.data.getStringList("contactsGrp");
                var contactsJson = jsonDecode(data.toString());
                if (data != null) {
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: <Widget>[
                          ListTile(
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () async {
                                      await showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              EditView(contactsJson[index],
                                                  index, widget.contacts));
                                      setState(() {});
                                    }),
                                IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      List<String> ctLists =
                                          prefs.getStringList("contactsGrp");
                                      ctLists.removeAt(index);
                                      prefs.setStringList(
                                          "contactsGrp", ctLists);
                                      setState(() {});
                                    }),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(context, contactsJson[index]);
                            },
                            title: Text(
                              contactsJson[index]["name"],
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                                "No Of Contacts : ${contactsJson[index]["contacts"].length.toString()}",
                                style: TextStyle(fontSize: 15)),
                          ),
                          Divider()
                        ],
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Text("Add New Group Using + Button"),
                  );
                }
            }
          },
        ));
  }
}
