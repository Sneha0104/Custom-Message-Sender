class Avasar {
  String avasarname;
  String avasarcategory;
  String avasartype;
  String avasardeadline;
  String avasardday;
  String avasarcost;
  String avasarcontact;
  String avasaremail;
  String avasarbenefits;
  String avasarlink;
  String avasarvenue;
  String avasardistrict;
  String venuetype;
  bool lkg;
  bool ukg;
  bool cl1;
  bool cl2;
  bool cl3;
  bool cl4;
  bool cl5;
  bool cl6;
  bool cl7;
  bool cl8;
  bool cl9;
  bool cl10;
  bool cl11;
  bool cl12;
  bool ug;
  bool pg;
  bool y;

  Avasar(
      {this.avasarname,
      this.avasarcategory,
      this.avasartype,
      this.avasardeadline,
      this.avasardday,
      this.avasarcost,
      this.avasarbenefits,
      this.avasarlink,
      this.avasarcontact,
      this.avasarvenue,
      this.avasardistrict,
      this.venuetype,
      this.avasaremail,
      this.lkg,
      this.ukg,
      this.cl1,
      this.cl2,
      this.cl3,
      this.cl4,
      this.cl5,
      this.cl6,
      this.cl7,
      this.cl8,
      this.cl9,
      this.cl10,
      this.cl11,
      this.cl12,
      this.ug,
      this.pg,
      this.y});

  Avasar.fromJson(Map<String, dynamic> json) {
    avasarname = json['avasarname'] ?? "";
    avasarcategory = json['avasarcategory'] ?? "";
    avasartype = json['avasartype'] ?? "";
    avasardeadline = json['avasardeadline'];
    avasardday = json['avasardday'];
    avasarcost = json['avasarcost'];
    avasarbenefits = json['avasarbenefits'];
    avasarlink = json['avasarlink'];
    avasarvenue = json['avasarvenue'];
    avasardistrict = json['avasardistrict'];
    venuetype = json['venuetype'];
    avasaremail = json['avasaremail'];
    avasarcontact = json['avasarcontact'].toString();
    print(avasarcontact);
    lkg = bv(json['lkg']);
    ukg = bv(json['ukg']);
    cl1 = bv(json['cl1']);
    cl2 = bv(json['cl2']);
    cl3 = bv(json['cl3']);
    cl4 = bv(json['cl4']);
    cl5 = bv(json['cl5']);
    cl6 = bv(json['cl6']);
    cl7 = bv(json['cl7']);
    cl8 = bv(json['cl8']);
    cl9 = bv(json['cl9']);
    cl10 = bv(json['cl10']);
    cl11 = bv(json['cl11']);
    cl12 = bv(json['cl12']);
    ug = bv(json['ug']);
    pg = bv(json['pg']);
    y = bv(json['y']);
  }
  bool bv(String val) {
    return val == "Y";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avasarname'] = this.avasarname;
    data['avasarcategory'] = this.avasarcategory;
    data['avasartype'] = this.avasartype;
    data['avasardeadline'] = this.avasardeadline;
    data['avasardday'] = this.avasardday;
    data['avasarcost'] = this.avasarcost;
    data['avasarbenefits'] = this.avasarbenefits;
    data['avasarlink'] = this.avasarlink;
    data['avasarvenue'] = this.avasarvenue;
    data['avasardistrict'] = this.avasardistrict;
    data['venuetype'] = this.venuetype;
    data['lkg'] = this.lkg;
    data['ukg'] = this.ukg;
    data['cl1'] = this.cl1;
    data['cl2'] = this.cl2;
    data['cl3'] = this.cl3;
    data['cl4'] = this.cl4;
    data['cl5'] = this.cl5;
    data['cl6'] = this.cl6;
    data['cl7'] = this.cl7;
    data['cl8'] = this.cl8;
    data['cl9'] = this.cl9;
    data['cl10'] = this.cl10;
    data['cl11'] = this.cl11;
    data['cl12'] = this.cl12;
    data['ug'] = this.ug;
    data['pg'] = this.pg;
    data['y'] = this.y;
    return data;
  }
}
