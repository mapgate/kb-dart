import 'dart:collection';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/formatters.dart';
import 'src/kb/kb.dart';
import 'src/kb/model.dart';
import 'src/widgets/movie_page.dart';

void main() => runApp(MyApp());

class ThursdayModel with ChangeNotifier {
  KbApi kbApi = KbApi();
  bool _loading = false;
  int _current = 0;
  final List<ThursdayRecord> _titles = [];
  final List<DateTime> _thursdays = [];

  ThursdayModel() {
    loadDates();
    if (_thursdays.length > 0) {
      load();
    }
  }

  getLoading() => _loading;

  getTitles() => _titles;

  UnmodifiableListView<ThursdayRecord> get titles =>
      UnmodifiableListView(_titles);

  UnmodifiableListView<DateTime> get thursdays =>
      UnmodifiableListView(_thursdays);

  DateTime get current {
    if (_thursdays.length > _current) {
      return _thursdays[_current];
    } else {
      return null;
    }
  }

  DateTime get prev {
    if (_thursdays.length > (_current + 1)) {
      return _thursdays[_current + 1];
    } else {
      return null;
    }
  }

  DateTime get next {
    if ((_thursdays.length > (_current - 1)) && (_current > 0)) {
      return _thursdays[_current - 1];
    } else {
      return null;
    }
  }

  nextThursday() {
    if (_current > 0) {
      _current -= 1;
      load();
      notifyListeners();
    }
  }

  prevThursday() {
    if ((_current + 1) < _thursdays.length) {
      _current += 1;
      load();
      notifyListeners();
    }
  }

  void loadDates() async {
    _loading = true;
    notifyListeners();
    try {
      _thursdays.clear();
      _thursdays.addAll(await kbApi.getThursdays());
      notifyListeners();
    } catch (exception) {
      _loading = false;
      notifyListeners();
    }
  }

  void load() async {
    _loading = true;
    notifyListeners();
    try {
      _titles.clear();
      _titles.addAll(await kbApi.getThursdayBoxOffice(_thursdays[_current]));
      _loading = false;
      notifyListeners();
    } catch (exception) {
      _loading = false;
      notifyListeners();
    }
  }
}

class WeekendModel with ChangeNotifier {
  KbApi kbApi = KbApi();
  bool _loading = false;
  final List<WeekendRecord> _titles = [];
  final List<DateTime> _weekends = [];

  WeekendModel() {
    load();
  }

  getLoading() => _loading;

  getTitles() => _titles;

  UnmodifiableListView<WeekendRecord> get titles =>
      UnmodifiableListView(_titles);

  UnmodifiableListView<DateTime> get weekends =>
      UnmodifiableListView(_weekends);

  void load() async {
    _loading = true;
    notifyListeners();
    try {
      _weekends.clear();
      _weekends.addAll(await kbApi.getWeekends());
      notifyListeners();
    } catch (exception) {}
    try {
      _titles.clear();
      _titles.addAll(await kbApi.getWeekendBoxOffice(weekends[0]));
      _loading = false;
      notifyListeners();
    } catch (exception) {
      _loading = false;
      notifyListeners();
    }
  }
}

class YearModel with ChangeNotifier {
  KbApi kbApi = KbApi();
  bool _loading = false;
  final List<YearRecord> _titles = [];

  YearModel() {
    load();
  }

  getLoading() => _loading;

  getTitles() => _titles;

  UnmodifiableListView<YearRecord> get titles => UnmodifiableListView(_titles);

  void load() async {
    _loading = true;
    notifyListeners();
    try {
      _titles.clear();
      _titles.addAll(await kbApi.getYearBoxOffice());
      notifyListeners();
    } catch (exception) {
      _loading = false;
      notifyListeners();
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<BottomNavigationBarProvider>(
              create: (context) => BottomNavigationBarProvider()),
          ChangeNotifierProvider<YearModel>(create: (context) => YearModel()),
          ChangeNotifierProvider<WeekendModel>(
              create: (context) => WeekendModel()),
          ChangeNotifierProvider<ThursdayModel>(
              create: (context) => ThursdayModel()),
        ],
        child: MaterialApp(
          title: 'kb-app',
          theme: ThemeData(
            primarySwatch: Colors.indigo,
          ),
          home: BoxOfficePage(),
        ));
  }
}

class ThursdayBoxOffice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final thursday = Provider.of<ThursdayModel>(context);
    return thursday.getLoading()
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      itemCount: thursday.titles.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return ButtonBar(
              alignment: MainAxisAlignment.center,
              layoutBehavior: ButtonBarLayoutBehavior.constrained,
              buttonPadding:
              EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              //buttonHeight: 21,
              children: <Widget>[
                RaisedButton(
                  child: Text(thursday.prev == null
                      ? ''
                      : '${fullDateFormatter.format(thursday.prev)}'),
                  onPressed: thursday.prev == null
                      ? null
                      : () {
                    thursday.prevThursday();
                  },
                ),
                RaisedButton(
                  color: Theme
                      .of(context)
                      .bottomAppBarColor,
                  //color:Colors.white,
                  //color: Colors.deepOrange,
                  child: Text(
                      '${fullDateFormatter.format(thursday.current)}'),
                  onPressed: thursday.current == null ? null : () {},
                ),
                RaisedButton(
                  child: Text(thursday.next == null
                      ? ''
                      : '${fullDateFormatter.format(thursday.next)}'),
                  onPressed: thursday.next == null
                      ? null
                      : () {
                    thursday.nextThursday();
                  },
                ),
              ]);
        } else
          return Card(
            //color: Colors.indigo,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: 6,
                ),
                Container(
                  width: 40,
                  child: Text('${thursday.titles[index - 1].pos}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 21)),
                ),
                SizedBox(
                  width: 6,
                ),
                Flexible(
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                          child:
                          Text('${thursday.titles[index - 1].title}',
                              style: TextStyle(
                                //color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16))),
                      Text(
                          '${decimalFormatter.format(
                              thursday.titles[index - 1].boxOffice)}',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            //color: Colors.white,
                              fontWeight: FontWeight.w100,
                              fontSize: 18)),
                    ],
                  ),
                ),
              ],
            ),
          );
      },
      //separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}

class WeekendBoxOffice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weekend = Provider.of<WeekendModel>(context);
    return weekend.getLoading()
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      itemCount: weekend.titles.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Center(
              child: Text(
                  '${fullDateFormatter.format(weekend.weekends[0])}'));
        } else
          return Card(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: 6,
                ),
                Container(
                  width: 40,
                  child: Text('${weekend.titles[index - 1].pos}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 21)),
                ),
                SizedBox(
                  width: 6,
                ),
                Flexible(
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                          child:
                          Text('${weekend.titles[index - 1].title}',
                              style: TextStyle(
                                //color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16))),
                      Text(
                          '${decimalFormatter.format(
                              weekend.titles[index - 1].boxOffice)}',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            //color: Colors.white,
                              fontWeight: FontWeight.w100,
                              fontSize: 18)),
                    ],
                  ),
                ),
              ],
            ),
          );
      },
      //separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}

class YearBoxOffice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final year = Provider.of<YearModel>(context);
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      itemCount: year.titles.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
            onTap: () {
              Route route =
              MaterialPageRoute(
                  builder: (context) => MoviePage(year.titles[index]));
              Navigator.push(context, route);
            },
            child: Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: 6,
                  ),
                  Container(
                    width: 40,
                    child: Text('${year.titles[index].pos}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 21)),
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Flexible(
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                            child: Text('${year.titles[index].title}',
                                style: TextStyle(
                                  //color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16))),
                        Text(
                            '${decimalFormatter.format(year.titles[index]
                                .boxOffice)}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              //color: Colors.white,
                                fontWeight: FontWeight.w100,
                                fontSize: 18)),
                      ],
                    ),
                  ),
                ],
              ),
            ));
      },
      //separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}

class BottomNavigationBarProvider with ChangeNotifier {
  int _currentIndex = 0;

  List<String> _titles = <String>['THURSDAY', 'WEEKEND', 'YEAR'];

  List<Widget> _widgets = <Widget>[
    ThursdayBoxOffice(),
    WeekendBoxOffice(),
    YearBoxOffice()
  ];

  get currentIndex => _currentIndex;

  get currentTitle => _titles[_currentIndex];

  get currentWidget => _widgets[_currentIndex];

  get loading => false;

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  update() {
    if (currentWidget is YearBoxOffice) {
      //(currentWidget as YearBoxOffice).update();
    }
  }
}

class BoxOfficePage extends StatelessWidget {
  final rng = new Random();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BottomNavigationBarProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('${provider.currentTitle}'), actions: <Widget>[
        // action button
        IconButton(
          icon: Icon(Icons.autorenew),
          onPressed: () async {
            var idx = provider.currentIndex;
            if (idx == 0) {
              Provider.of<ThursdayModel>(context, listen: false).load();
            } else if (idx == 1) {
              Provider.of<WeekendModel>(context, listen: false).load();
            } else if (idx == 2) {
              Provider.of<YearModel>(context, listen: false).load();
            }
          },
        ),
      ]),
      body: provider.currentWidget,
      bottomNavigationBar: new BottomNavigationBar(
        selectedItemColor: Colors.deepOrange,
        //backgroundColor: Colors.indigoAccent,
        currentIndex: provider.currentIndex,
        onTap: (index) {
          provider.currentIndex = index;
        },
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(
              icon: const Icon(Icons.today), title: new Text("THURSDAY")),
          new BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today),
              title: new Text("WEEKEND")),
          new BottomNavigationBarItem(
              icon: const Icon(Icons.date_range), title: new Text("YEAR"))
        ],
      ),
    );
  }
}
