import 'package:permission_handler/permission_handler.dart' as perms;
import 'package:contacts_service/contacts_service.dart';
// import 'package:easy_contact_picker/easy_contact_picker.dart';


Future<List> getContacts() async {
  List contacts = [];
  await perms.Permission.contacts.request();
  var status = await perms.Permission.contacts.status;
  if (status.isGranted) {
    Iterable<Contact> contcs =
        await ContactsService.getContacts(withThumbnails: false);
    contcs.forEach((Contact ct) {
      var parentName = ct.givenName ?? "";
      var childName = ct.familyName ?? "";
      String ctphone;
      try {
        ctphone = ct.phones.first.value.toString();
      } catch (e) {
        print(parentName);
        print(ct.phones);
        ctphone = "";
      }
      contacts.add(CustomContacts(parentName, ctphone, childName).toJson());
    });
  }
  return contacts;
}

class CustomContacts {
  final String parentName;
  final String phoneNumber;
  final String lname;
  CustomContacts(this.parentName, this.phoneNumber, this.lname);

  Map<String, dynamic> toJson() {
    return {
      "fullName": "${this.parentName} ${this.lname}",
      "phoneNumber": "$parentName&${this.lname}:${this.phoneNumber}",
    };
  }
}
