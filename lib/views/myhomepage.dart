import 'dart:convert';
import 'dart:io';
import 'package:custom_message_sender/addmessage/home_view.dart';
import 'package:custom_message_sender/model/avasar.dart';
import 'package:custom_message_sender/model/student.dart';
import 'package:custom_message_sender/views/previewpage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:custom_message_sender/util/contacts.dart';
import 'package:custom_message_sender/util/sharedprefs.dart';
import 'package:custom_message_sender/views/contactssearch.dart';
import 'package:flutter/material.dart';
import 'package:groovin_widgets/outline_dropdown_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:custom_message_sender/addmessage/db_halper.dart';

//Things We Need
//Load Given Json
//Parse Json
class MyHomePage extends StatefulWidget {
  // MyHomePage({cstMessage});
  final TextEditingController custMessage;

  MyHomePage({Key key,this.custMessage}) : super(key: key);
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  File avasarJsonFile;
  File studentsJsonFile;
  List<Student> students = <Student>[];
  List stuFromCt = [];
  List<Avasar> avasars = <Avasar>[];
  String avsrButtton = "AVASAR";
  String contButton = "STUDENTS";
  var ctGroup;
  int dropDown;
  TextEditingController custmMsg;
  TextEditingController newMsg;
  TextEditingController phoneNo;
  TextEditingController title;
  bool custMsgEnabled = true;
  bool enableContacts = false;
  final DatabaseHelper databaseHelper = DatabaseHelper();

  final _tcBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(
        const Radius.circular(10.0),
      ),
      borderSide: BorderSide(color: Colors.transparent));

  @override
  void initState() {
    phoneNo = TextEditingController();
    custmMsg = TextEditingController();
    newMsg = TextEditingController();
    title = TextEditingController();
    super.initState();
  }

  // add button at the side of select message box
  // not being in use at the moment
  addNewMessageDialog(BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return SimpleDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text("Add New Message"),
            children: <Widget>[
              FlatButton(
                onPressed: () async {
                  await writeNewMessage(newMsg.text);
                  // await writeNewMessage(title.text);
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("CANCEL"),
              )
            ],
          );
        });
  }

  Padding jsonButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          MaterialButton(
            color: Colors.green[400],
            padding: EdgeInsets.only(left: 30, right: 30),
            onPressed: () async {
              avasarJsonFile = await FilePicker.getFile();
              String jsonFile = avasarJsonFile.readAsStringSync();
              var avasrJson = jsonDecode(jsonFile);
              for (var avasar in avasrJson)
                avasars.add(Avasar.fromJson(avasar));
              setState(() {
                avsrButtton = p.basename(avasarJsonFile.path);
              });
            },
            child: Text(
              avsrButtton,
              style: TextStyle(color: Colors.white),
            ),
          ),
          MaterialButton(
            color: Colors.green[400],
            padding: EdgeInsets.only(left: 30, right: 30),
            onPressed: () async {
              studentsJsonFile = await FilePicker.getFile();
              String jsonFile = studentsJsonFile.readAsStringSync();
              var studentJson = jsonDecode(jsonFile);
              for (var student in studentJson)
                students.add(Student.fromJson(student));
              setState(() {
                enableContacts = true;
                contButton = p.basename(studentsJsonFile.path);
              });
            },
            child: Text(contButton, style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // customMessage(String customMsg) {
  //   print('ethi sajuuuuuu');

  //   setState(() {
  //     custmMsg.text = customMsg;
  //   });
  // }

  Padding customMsgField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: widget.custMessage,
        textCapitalization: TextCapitalization.sentences,
        minLines: 1,
        maxLines: 40,
        enabled: custMsgEnabled,
        decoration: InputDecoration(
          labelText: "Custom Message",
          border: _tcBorder,
        ),
      ),
    );
  }

  Padding dropDownField(List<String> dropList, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: OutlineDropdownButton(
        value: dropDown,
        onChanged: (val) {
          setState(() {
            dropDown = val;
            if (val != 0) custmMsg.text = dropList[val];
          });
        },
        items: dropList.asMap().entries.map((entry) {
          return DropdownMenuItem(
            child: ListTile(
              title: Text(entry.value),
              subtitle: Divider(color: Colors.black),
              trailing: InkWell(
                child: entry.key != 0 ? Icon(Icons.delete) : SizedBox(),
                onTap: () {
                  removeMsg(dropList, entry.key);
                  setState(() {
                    dropDown = 0;
                    custmMsg.text = "";
                  });
                },
              ),
            ),
            value: entry.key,
          );
        }).toList(),
        hint: Text("Select message"),
        inputDecoration: InputDecoration(
            suffixIcon: InkWell(
                onTap: () async {
                  // calling the addmessage funtion here
                  // makes a message like a note with title and message body
                  // Control goes to homeview(), writemessage in shared prefs gets updated
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (BuildContext context) => new HomeView()));
                  print('here again');
                  setState(() {});
                },
                child: Icon(Icons.add)),
            contentPadding: EdgeInsets.all(15),
            border: _tcBorder),
      ),
    );
  }

  dropDownMenu() {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return LinearProgressIndicator();
            break;
          default:
            List<String> dropList = snapshot.data.getStringList("dropDownOpt");
            if (dropList != null)
              return dropDownField(dropList, context);
            else
              return dropDownField(['Custom Message'], context);
        }
      },
    );
  }

  Padding phoneNoField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        readOnly: true,
        onTap: () async {
          stuFromCt.clear();
          List contacts = await getContacts();
          ctGroup = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ContactsSelector(contacts)));
          var cts = ctGroup["contacts"];
          //List<Student> sts = [];
          for (var ct in cts) {
            var splitted = ct.split(":");

            String ctPhone = splitted[1]
                .toString()
                .replaceAll(" ", "")
                .replaceAll("+91", "");
            RegExp regExp = RegExp(r'([^-]*$)');
            String parentName = regExp
                .firstMatch(splitted[0].toString().split("&")[0])
                .group(0)
                .toString()
                .trim();

            List<String> names = [];
            if (splitted[0].toString().contains("+"))
              names = splitted[0].toString().split("&")[1].split("+");
            else
              names.add(splitted[0].toString().split("&")[1]);
            for (var name in names) {
              stuFromCt.add(
                  {"name": name, "phone": ctPhone, "parentName": parentName});
            }
          }
          if (ctGroup != null)
            setState(() {
              phoneNo.text = ctGroup['name'];
            });
        },
        enabled: custMsgEnabled,
        controller: phoneNo,
        decoration: InputDecoration(
            labelText: "Contacts Group",
            contentPadding: EdgeInsets.all(20),
            border: _tcBorder),
      ),
    );
  }

// have to change it's location to a new dart file
  getClassValue(Student student, Avasar av) {
    switch (student.std) {
      case "1":
        if (av.cl1 == true)
          return false;
        else
          return true;
        break;
      case "2":
        if (av.cl2 == true)
          return false;
        else
          return true;
        break;
      case "3":
        if (av.cl3 == true)
          return false;
        else
          return true;
        break;
      case "4":
        if (av.cl4 == true)
          return false;
        else
          return true;
        break;
      case "5":
        if (av.cl5 == true)
          return false;
        else
          return true;
        break;
      case "6":
        if (av.cl6 == true)
          return false;
        else
          return true;
        break;
      case "7":
        if (av.cl7 == true)
          return false;
        else
          return true;
        break;
      case "8":
        if (av.cl8 == true)
          return false;
        else
          return true;
        break;
      case "9":
        if (av.cl9 == true)
          return false;
        else
          return true;
        break;
      case "10":
        if (av.cl10 == true)
          return false;
        else
          return true;
        break;
      case "11":
        if (av.cl11 == true)
          return false;
        else
          return true;
        break;
      case "12":
        if (av.cl12 == true)
          return false;
        else
          return true;
        break;
      case "LKG":
        if (av.lkg == true)
          return false;
        else
          return true;
        break;
      case "UKG":
        if (av.ukg == true)
          return false;
        else
          return true;
        break;
      case "UG":
        if (av.ug == true)
          return false;
        else
          return true;
        break;
      case "PG":
        if (av.pg == true)
          return false;
        else
          return true;
        break;
      default:
        return true;
    }
  }

  FlatButton submitButton() {
    return FlatButton(
      onPressed: () async {
        /*
            Example Of Message
            *Flair Fashion Weekend Season 2* Kids Model Auditions in Crowne Plaza on Jan 12. 
            You can walk in. No prior Registration required.
            Contact No : 9746200009
        */
        List<Map> messages = [];

        if (!custmMsg.text.contains("<events>")) {
          for (var students in stuFromCt) {
            String msg =
                custmMsg.text.replaceAll("<fname>", students["parentName"]);
            msg = msg.replaceAll("<sname>", students["name"]);
            messages.add({"messages": msg, "phone": students['phone']});
          }
        }
        if (avasars != null && students != null) {
          for (var stud in stuFromCt) {
            Student student;
            for (var studnt in students) {
              if (studnt.whatsapp.toString().toString().toLowerCase().contains(
                      stud["phone"].toString().toString().toLowerCase()) &&
                  studnt.studentname
                      .toLowerCase()
                      .contains(stud["name"].toString().toLowerCase())) {
                student = studnt;
              }
            }
            if (student == null) {
              continue;
            }

            List<Avasar> matchedAvasar = [];
            for (var avasar in avasars) {
              for (var interest in student.interests) {
                // print({interest, avasar.avasarcategory});
                if (avasar.avasarcategory.contains(interest.trim())) {
                  if (avasar.avasardistrict.toLowerCase() ==
                          student.district.toLowerCase() ||
                      avasar.avasardistrict.toLowerCase() ==
                          student.state.toLowerCase() ||
                      avasar.avasardistrict.toLowerCase() == "india" ||
                      avasar.avasardistrict.toLowerCase() == "online") {
                    matchedAvasar.add(avasar);
                  }
                } else if (avasar.avasartype.contains(interest.trim())) {
                  if (avasar.avasardistrict.toLowerCase() ==
                          student.district.toLowerCase() ||
                      avasar.avasardistrict.toLowerCase() ==
                          student.state.toLowerCase() ||
                      avasar.avasardistrict.toLowerCase() == "india" ||
                      avasar.avasardistrict.toLowerCase() == "online") {
                    matchedAvasar.add(avasar);
                  }
                }
              }
            }
            matchedAvasar.removeWhere((av) => getClassValue(student, av));
            int avsrlen = matchedAvasar.length >= 3 ? 3 : matchedAvasar.length;
            String avasarMsg = "";
            String formatDate(DateTime date) =>
                new DateFormat("MMMM d").format(date);
            for (var i = 0; i < avsrlen; i++) {
              String contactString;
              if (matchedAvasar[i].avasarlink != null) {
                contactString =
                    "Reach them at : ${matchedAvasar[i].avasarlink}";
              } else {
                contactString = "Contact : ${matchedAvasar[i].avasarcontact}";
              }
              String date;
              if (matchedAvasar[i].avasardday == null)
                date =
                    formatDate(DateTime.parse(matchedAvasar[i].avasardeadline));
              else
                date = formatDate(DateTime.parse(matchedAvasar[i].avasardday));

              var msg =
                  "\n${i + 1}. *${matchedAvasar[i].avasarname}* ${matchedAvasar[i].avasartype} at ${matchedAvasar[i].avasarvenue} on $date \n$contactString\n";
              avasarMsg += msg;
            }
            if (avasarMsg.isNotEmpty) {
              avasarMsg = "These are recommendations\n" + avasarMsg;
            }

            if (stud["parentName"] == "") {
              print("Empty Parent : " + stud["name"]);
            }
            var cstMessage = custmMsg.text
                .replaceAll("<fname>", stud["parentName"])
                .replaceAll("<sname>", stud["name"])
                .replaceAll("<events>", avasarMsg);
            messages.add({"messages": cstMessage, "phone": stud['phone']});
          }
        }
        if (messages.isNotEmpty) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => PreviewPage(messages)));
        }
      },
      color: Theme.of(context).primaryColor,
      child: SizedBox(
          width: 350,
          height: 40,
          child: Center(
              child: Text(
            "SEND",
            style: TextStyle(color: Colors.white),
          ))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECE5DD),
      appBar: new AppBar(
        title: Text("Avasarshala Helper"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Padding(
            padding: EdgeInsets.only(top: 100),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "LOAD JSONS",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                ),
                jsonButtons(),
                phoneNoField(),
                dropDownMenu(),
                customMsgField(),
                submitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
