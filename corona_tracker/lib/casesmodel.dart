class CasesList {
  List<Cases> casesList;

  CasesList({
    this.casesList,
  });

  factory CasesList.fromJson(List<dynamic> parsedJson) {
    List<Cases> casesList = new List<Cases>();
    casesList = parsedJson.map((i) => Cases.fromJson(i)).toList();

    return new CasesList(
      casesList: casesList,
    );
  }
}

class Cases {
  String iso2;
  String provinceState;
  String countryRegion;
  double lat;
  double long;
  int confirmed;
  int recovered;
  int deaths;

  Cases({
    this.iso2,
    this.provinceState,
    this.countryRegion,
    this.lat,
    this.long,
    this.confirmed,
    this.recovered,
    this.deaths,
  });

  Cases.fromJson(Map<String, dynamic> json) {
    iso2 = json['iso2'];
    provinceState = json['provinceState'];
    countryRegion = getName(json);
    lat = json['lat'].toDouble();
    long = json['long'].toDouble();
    confirmed = json['confirmed'];
    recovered = json['recovered'];
    deaths = json['deaths'];
  }

  getName(Map<String, dynamic> json) {
    if (json['provinceState'] == null)
      return json['countryRegion'];
    else
      return '${json['provinceState']} ${json['countryRegion']}';
  }
}
