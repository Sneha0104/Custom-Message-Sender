class Student {
  int no;
  String studentname;
  String parentname;
  String dateofbirth;
  String gender;
  String std;
  String school;
  String state;
  String district;
  String email;
  var whatsapp;
  List<String> interests;

  Student(
      {this.no,
      this.studentname,
      this.parentname,
      this.dateofbirth,
      this.gender,
      this.std,
      this.school,
      this.state,
      this.district,
      this.email,
      this.whatsapp,
      this.interests});

  Student.fromJson(Map<String, dynamic> json) {
    no = json['no'];
    studentname = json['studentname'];
    parentname = json['parentname'];
    dateofbirth = json['dateofbirth'];
    gender = json['gender'];
    std = json['class'].toString();
    school = json['school'];
    state = json['state'];
    district = json['district'];
    email = json['email'];
    whatsapp = json['whatsapp'];
    interests = json['interests'].toString().split(",").toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['no'] = this.no;
    data['studentname'] = this.studentname;
    data['parentname'] = this.parentname;
    data['dateofbirth'] = this.dateofbirth;
    data['gender'] = this.gender;
    data['class'] = this.std;
    data['school'] = this.school;
    data['state'] = this.state;
    data['district'] = this.district;
    data['email'] = this.email;
    data['whatsapp'] = this.whatsapp;
    data['interests'] = this.interests;
    return data;
  }
}
