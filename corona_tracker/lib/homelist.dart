import 'dart:convert';

import 'package:corona_tracker/casesmodel.dart';
import 'package:corona_tracker/indicator.dart';
import 'package:corona_tracker/model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeList extends StatefulWidget {
  @override
  _HomeListState createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {
  final TextEditingController searchQuery = new TextEditingController();
  final key = new GlobalKey<ScaffoldState>();

  DataModel dataModel;
  CasesList casesList;
  CasesList searchList;
  int touchedIndex;
  bool isLoading = true;
  Icon actionIcon = new Icon(
    Icons.search,
  );
  Widget appBarTitle = Text(
    "Corona Tracker",
  );
  bool isSearching = false;
  String searchText = "";

  _HomeListState() {
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
    print("${response.body}");

    final data = json.decode(response.body);
    dataModel = new DataModel.fromJson(data);

    String url1 = 'https://covid19.mathdro.id/api/confirmed';

    var response1 = await http.get(url1);
    print("${response1.body}");

    final data1 = json.decode(response1.body);
    casesList = new CasesList.fromJson(data1);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: key,
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: appBarTitle,
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  setState(() {
                    if (this.actionIcon.icon == Icons.search) {
                      this.actionIcon = new Icon(
                        Icons.close,
                      );
                      this.appBarTitle = new TextField(
                        controller: searchQuery,
                        style: new TextStyle(),
                        decoration: new InputDecoration(
                            prefixIcon: new Icon(Icons.search),
                            hintText: "Search...",
                            hintStyle: new TextStyle(fontSize: 18)),
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
                  Visibility(
                    visible: false,
                    child: Expanded(
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Indicator(
                                          color: Color(0xfff8b250),
                                          text: 'Confirmed',
                                          isSquare: false,
                                          size: touchedIndex == 1 ? 18 : 16,
                                          textColor: touchedIndex == 1
                                              ? Colors.black
                                              : Colors.grey,
                                        ),
                                        Text(
                                            '${dataModel.confirmed.confirmedvalue}'),
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
                                          size: touchedIndex == 2 ? 18 : 16,
                                          textColor: touchedIndex == 2
                                              ? Colors.black
                                              : Colors.grey,
                                        ),
                                        Text('${dataModel.deaths.deathsvalue}'),
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
                                          size: touchedIndex == 3 ? 18 : 16,
                                          textColor: touchedIndex == 3
                                              ? Colors.black
                                              : Colors.grey,
                                        ),
                                        Text(
                                            '${dataModel.recovered.recoveredvalue}'),
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
                  ),
                  Expanded(
                    flex: 4,
                    child: ListView(
                      children: isSearching ? _buildSearchList() : _buildList(),
                    ),
                  ),
                ],
              )
            : Center(
                child:
                    Container(height: 70, child: CircularProgressIndicator())),
      ),
    );
  }

  getName(int index) {
    if (casesList.casesList[index].provinceState == null)
      return casesList.casesList[index].countryRegion;
    else
      return '${casesList.casesList[index].provinceState} - ${casesList.casesList[index].countryRegion}';
  }

  getName1(Cases cases) {
    if (cases.provinceState == null)
      return cases.countryRegion;
    else
      return '${cases.provinceState} - ${cases.countryRegion}';
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
              value: dataModel.confirmed.confirmedvalue.toDouble(),
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
              value: dataModel.deaths.deathsvalue.toDouble(),
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
              value: dataModel.recovered.recoveredvalue.toDouble(),
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
      );
      this.appBarTitle = new Text(
        "Corona Tracker",
      );
      isSearching = false;
      searchQuery.clear();
    });
  }

  Widget childItem(Cases cases) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black,
                backgroundImage: NetworkImage(
                  'https://www.countryflags.io/${cases.iso2?.toLowerCase()}/flat/64.png',
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: Text(
                      getName1(cases),
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Indicator(
                          color: Color(0xfff8b250),
                          text: cases.confirmed.toString(),
                          isSquare: false,
                          size: 13,
                          textColor: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: Indicator(
                          color: Colors.redAccent.shade100,
                          text: cases.deaths.toString(),
                          isSquare: false,
                          size: 13,
                          textColor: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: Indicator(
                          color: Color(0xff13d38e),
                          text: cases.recovered.toString(),
                          isSquare: false,
                          size: 13,
                          textColor: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildList() {
    return casesList.casesList.map((item) {
      print(item.provinceState);
      return childItem(item);
    }).toList();
  }

  List<Widget> _buildSearchList() {
    if (searchText.isEmpty) {
      return casesList.casesList.map((item) => childItem(item)).toList();
    } else {
      searchList = new CasesList();
      searchList.casesList = new List();
      for (int i = 0; i < casesList.casesList.length; i++) {
        String name =
            '${casesList.casesList[i].provinceState} ${casesList.casesList[i].countryRegion}'
                .toLowerCase();
        if (name.toLowerCase().contains(searchText.toLowerCase())) {
          searchList.casesList.add(casesList.casesList[i]);
        }
      }
      return searchList.casesList.map((item) => childItem(item)).toList();
    }
  }
}
