import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';

class PreviewPage extends StatelessWidget {
  final List<Map> msgList;
  final String baseURL = "https://api.whatsapp.com/send?phone=";
  PreviewPage(this.msgList);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preview Message"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          for (var msg in msgList) {
            if (msg["phone"] != null) {
              var url = "${baseURL}91${msg['phone']}&text=${msg['messages']}";
              print(url);
              AndroidIntent intent = AndroidIntent(
                  action: 'action_view',
                  data: Uri.encodeFull(url),
                  // flags: <int>[Flag.FLAG_ACTIVITY_CLEAR_TOP],
                  package: "com.whatsapp.w4b");
              intent.launch();
            }
          }
        },
        child: Icon(Icons.send),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: msgList.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: <Widget>[
                ListTile(
                    title: Text(msgList[index]["messages"]),
                    subtitle: Text(msgList[index]['phone'])),
                Divider()
              ],
            );
          },
        ),
      ),
    );
  }
}
