class DataModel {
  Confirmed confirmed;
  Recovered recovered;
  Deaths deaths;

  DataModel({this.confirmed, this.recovered, this.deaths});

  DataModel.fromJson(Map<String, dynamic> json) {
    confirmed = json['confirmed'] != null
        ? new Confirmed.fromJson(json['confirmed'])
        : null;
    recovered = json['recovered'] != null
        ? new Recovered.fromJson(json['recovered'])
        : null;
    deaths =
        json['deaths'] != null ? new Deaths.fromJson(json['deaths']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.confirmed != null) {
      data['confirmed'] = this.confirmed.toJson();
    }
    if (this.recovered != null) {
      data['recovered'] = this.recovered.toJson();
    }
    if (this.deaths != null) {
      data['deaths'] = this.deaths.toJson();
    }
    return data;
  }
}

class Confirmed {
  int confirmedvalue;
  String confirmeddetail;

  Confirmed({this.confirmedvalue, this.confirmeddetail});

  Confirmed.fromJson(Map<String, dynamic> json) {
    confirmedvalue = json['value'];
    confirmeddetail = json['detail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.confirmedvalue;
    data['detail'] = this.confirmeddetail;
    return data;
  }
}

class Recovered {
  int recoveredvalue;
  String recovereddetail;

  Recovered({this.recoveredvalue, this.recovereddetail});

  Recovered.fromJson(Map<String, dynamic> json) {
    recoveredvalue = json['value'];
    recovereddetail = json['detail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.recoveredvalue;
    data['detail'] = this.recovereddetail;
    return data;
  }
}

class Deaths {
  int deathsvalue;
  String deathsdetail;

  Deaths({this.deathsvalue, this.deathsdetail});

  Deaths.fromJson(Map<String, dynamic> json) {
    deathsvalue = json['value'];
    deathsdetail = json['detail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.deathsvalue;
    data['detail'] = this.deathsdetail;
    return data;
  }
}
