import 'dart:async';
import 'dart:convert';

import 'package:corona_tracker/autocomplete_textfield.dart';
import 'package:corona_tracker/casesmodel.dart';
import 'package:corona_tracker/homelist.dart';
import 'package:corona_tracker/indicator.dart';
import 'package:corona_tracker/model.dart';
import 'package:corona_tracker/uatheme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController searchQuery = new TextEditingController();
  final key = new GlobalKey<ScaffoldState>();

  DataModel dataModel;
  CasesList casesList;

  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  Widget appBarTitle = Text(
    "Corona Tracker",
  );
  bool isSearching = false;
  String searchText = "";
  int confirmed, deaths, recovered;
  List<String> allCountries = new List();
  int touchedIndex;
  bool isLoading = true;
  Set<Marker> markers;
  Completer<GoogleMapController> controller = Completer();
  static LatLng center;
  LatLng lastMapPosition;
  String country = 'WorldWide';
  String flag =
      'http://pngimg.com/uploads/globe/globe_PNG58.png';
  GoogleMapController mapController;

  void _onCameraMove(CameraPosition position) {
    lastMapPosition = position.target;
  }

  void _onMapCreated(GoogleMapController controller1) {
    mapController = controller1;
    controller.complete(controller1);
    mapController.setMapStyle(
        '[{"featureType": "all","elementType": "geometry","stylers": [{"color": "#242f3e"}]},{"featureType": "all","elementType": "labels.text.stroke","stylers": [{"lightness": -80}]},{"featureType": "administrative","elementType": "labels.text.fill","stylers": [{"color": "#746855"}]},{"featureType": "administrative.locality","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi.park","elementType": "geometry","stylers": [{"color": "#263c3f"}]},{"featureType": "poi.park","elementType": "labels.text.fill","stylers": [{"color": "#6b9a76"}]},{"featureType": "road","elementType": "geometry.fill","stylers": [{"color": "#2b3544"}]},{"featureType": "road","elementType": "labels.text.fill","stylers": [{"color": "#9ca5b3"}]},{"featureType": "road.arterial","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.arterial","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "road.highway","elementType": "geometry.fill","stylers": [{"color": "#746855"}]},{"featureType": "road.highway","elementType": "geometry.stroke","stylers": [{"color": "#1f2835"}]},{"featureType": "road.highway","elementType": "labels.text.fill","stylers": [{"color": "#f3d19c"}]},{"featureType": "road.local","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.local","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "transit","elementType": "geometry","stylers": [{"color": "#2f3948"}]},{"featureType": "transit.station","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "water","elementType": "geometry","stylers": [{"color": "#17263c"}]},{"featureType": "water","elementType": "labels.text.fill","stylers": [{"color": "#515c6d"}]},{"featureType": "water","elementType": "labels.text.stroke","stylers": [{"lightness": -20}]}]');
  }

  _HomeState() {
    searchQuery.addListener(() {
      if (searchQuery.text.isEmpty) {
        setState(() {
          isSearching = false;
          searchText = "";
        });
      } else {
        setState(() {
          isSearching = true;
          searchText = searchQuery.text;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    isSearching = false;
    getData();
  }

  getData() async {
    String url = 'https://covid19.mathdro.id/api';

    var response = await http.get(url);

    final data = json.decode(response.body);
    dataModel = new DataModel.fromJson(data);
    confirmed = dataModel.confirmed.confirmedvalue;
    deaths = dataModel.deaths.deathsvalue;
    recovered = dataModel.recovered.recoveredvalue;
    String url1 = 'https://covid19.mathdro.id/api/confirmed';

    var response1 = await http.get(url1);

    final data1 = json.decode(response1.body);
    casesList = new CasesList.fromJson(data1);

    for (int i = 0; i < casesList.casesList.length; i++)
      allCountries.add(casesList.casesList[i].countryRegion);

    center = LatLng(double.parse('42.165726'), double.parse('-74.948051'));
    lastMapPosition = center;
    markers = await getMarkers();
    setState(() {
      isLoading = false;
    });
  }

  getMarkers() async {
    Set<Marker> markersSet = new Set();
    for (int i = 0; i < casesList.casesList.length; i++) {
      if (casesList.casesList[i].lat != null &&
          casesList.casesList[i].long != null) {
        double lat = casesList.casesList[i].lat;
        double lng = casesList.casesList[i].long;
        print(lat);
        print(lng);
        markersSet.add(
          new Marker(
            visible: true,
            markerId: MarkerId(casesList.casesList[i].lat.toString()),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              onTap: () {},
              title:
                  'Cases ${casesList.casesList[i].confirmed} - ${getName(i)}',
              snippet:
                  'Recovered ${casesList.casesList[i].recovered}, Deaths ${casesList.casesList[i].deaths}',
            ),
          ),
        );
        print("*******************************");
      }
    }
    return markersSet;
  }

  getName(int index) {
    if (casesList.casesList[index].provinceState == null)
      return casesList.casesList[index].countryRegion;
    else
      return '${casesList.casesList[index].provinceState} - ${casesList.casesList[index].countryRegion}';
  }

  @override
  Widget build(BuildContext context) {
    UATheme.init(context);
    return SafeArea(
      child: Scaffold(
        key: key,
        resizeToAvoidBottomPadding: false,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => HomeList()));
          },
          child: Icon(Icons.list),
        ),
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: appBarTitle,
          leading: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ClipRRect(
              child: Image.asset('assets/images/icon.jpg'),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
          ),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  setState(() {
                    if (this.actionIcon.icon == Icons.search) {
                      this.actionIcon = new Icon(
                        Icons.close,
                        color: Colors.white,
                      );
                      this.appBarTitle = SimpleAutoCompleteTextField(
                        key: null,
                        clearOnSubmit: false,
                        suggestionsAmount: 100,
                        suggestions: allCountries,
                        decoration: InputDecoration(
                          hintText: 'Search',
                        ),
                        textSubmitted: (val) {
                          print(val);
                          searchText = val;
                          setData();
                          setState(() {});
                        },
                      );
                      _handleSearchStart();
                    } else {
                      _handleSearchEnd();
                    }
                  });
                },
                icon: actionIcon)
          ],
        ),
        body: !isLoading
            ? Column(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  ListTile(
                                    leading: Image.network(
                                      flag,
                                      height: UATheme.extraLargeSize(),
                                      width: UATheme.extraLargeSize() * 1.5,
                                    ),
                                    title: Text(
                                      country,
                                      style: TextStyle(
                                          fontSize: UATheme.normalSize()),
                                    ),
                                    contentPadding: EdgeInsets.only(left: 10),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Container(
                                      height: 1,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Indicator(
                                        color: Color(0xfff8b250),
                                        text: 'Confirmed',
                                        isSquare: false,
                                        size: touchedIndex == 0
                                            ? UATheme.normalSize()
                                            : UATheme.tinySize(),
                                        textColor: touchedIndex == 0
                                            ? Colors.white
                                            : Colors.grey,
                                      ),
                                      Text(
                                        '$confirmed',
                                        style: TextStyle(
                                            fontSize: UATheme.tinySize()),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Indicator(
                                        color: Colors.redAccent.shade100,
                                        text: 'Deaths',
                                        isSquare: false,
                                        size: touchedIndex == 1
                                            ? UATheme.normalSize()
                                            : UATheme.tinySize(),
                                        textColor: touchedIndex == 1
                                            ? Colors.white
                                            : Colors.grey,
                                      ),
                                      Text(
                                        '$deaths',
                                        style: TextStyle(
                                            fontSize: UATheme.tinySize()),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Indicator(
                                        color: Color(0xff13d38e),
                                        text: 'Recovered',
                                        isSquare: false,
                                        size: touchedIndex == 2
                                            ? UATheme.normalSize()
                                            : UATheme.tinySize(),
                                        textColor: touchedIndex == 2
                                            ? Colors.white
                                            : Colors.grey,
                                      ),
                                      Text(
                                        '$recovered',
                                        style: TextStyle(
                                            fontSize: UATheme.tinySize()),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: PieChart(
                                PieChartData(
                                    pieTouchData: PieTouchData(
                                        touchCallback: (pieTouchResponse) {
                                      setState(() {
                                        if (pieTouchResponse.touchInput
                                                is FlLongPressEnd ||
                                            pieTouchResponse.touchInput
                                                is FlPanEnd) {
                                          touchedIndex = -1;
                                        } else {
                                          touchedIndex = pieTouchResponse
                                              .touchedSectionIndex;
                                        }
                                      });
                                    }),
                                    startDegreeOffset: 180,
                                    borderData: FlBorderData(
                                      show: false,
                                    ),
                                    sectionsSpace: 3,
                                    centerSpaceRadius: 0,
                                    sections: showingSections()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: GoogleMap(
                      myLocationButtonEnabled: false,
                      mapToolbarEnabled: false,
                      myLocationEnabled: true,
                      onMapCreated: _onMapCreated,
                      markers: markers,
                      onCameraMove: _onCameraMove,
                      initialCameraPosition: CameraPosition(
                        target: center,
                        zoom: 5.0,
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(
      3,
      (i) {
        final isTouched = i == touchedIndex;
        final double opacity = isTouched ? 1 : 0.6;
        switch (i) {
          case 0:
            return PieChartSectionData(
              color: const Color(0xfff8b250).withOpacity(opacity),
              value: confirmed.toDouble(),
              title: '',
              radius: MediaQuery.of(context).size.width * 0.18,
              titleStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff044d7c)),
            );
          case 1:
            return PieChartSectionData(
              color: Colors.redAccent.shade100,
              value: deaths.toDouble(),
              title: '',
              radius: MediaQuery.of(context).size.width * 0.18,
              titleStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff90672d)),
            );
          case 2:
            return PieChartSectionData(
              color: const Color(0xff13d38e).withOpacity(opacity),
              value: recovered.toDouble(),
              title: '',
              radius: MediaQuery.of(context).size.width * 0.18,
              titleStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff0c7f55)),
            );
          default:
            return null;
        }
      },
    );
  }

  void _handleSearchStart() {
    setState(() {
      isSearching = true;
    });
  }

  void _handleSearchEnd() {
    setState(() {
      this.actionIcon = new Icon(
        Icons.search,
        color: Colors.white,
      );
      this.appBarTitle = new Text(
        "Corona Tracker",
        style: new TextStyle(color: Colors.white),
      );
      isSearching = false;
      searchText = "";
      setData();
      setState(() {});
    });
  }

  setData() {
    if (searchText == "") {
      confirmed = dataModel.confirmed.confirmedvalue;
      deaths = dataModel.deaths.deathsvalue;
      recovered = dataModel.recovered.recoveredvalue;
      country = 'WorldWide';
      flag =
            'http://pngimg.com/uploads/globe/globe_PNG58.png';
    } else {
      for (int i = 0; i < casesList.casesList.length; i++) {
        String countryRegion =
            '${casesList.casesList[i].countryRegion?.toLowerCase()}';
        if (countryRegion == searchText.toLowerCase()) {
          country = casesList.casesList[i].countryRegion;
          flag =
              'https://www.countryflags.io/${casesList.casesList[i].iso2?.toLowerCase()}/flat/64.png';
          confirmed = casesList.casesList[i].confirmed;
          deaths = casesList.casesList[i].deaths;
          recovered = casesList.casesList[i].recovered;
        }
      }
    }
  }
}
