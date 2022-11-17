import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  bool _is_add_item = false;
  bool _isItemDetails = false;
  bool _isDateDetail = false;
  final List<String> entries = <String>['A', 'B', 'C'];
  final List<DateTime> dateEntries = <DateTime>[DateTime.now(), DateTime.now(), DateTime.now()];
  final List<int> colorCodes = <int>[600, 500, 100];
  String currentEntry = '';
  DateTime currentDateTime = DateTime.now();
  DateTime _dateShowDetail = DateTime.now();
  final _dateTextController = TextEditingController();
  final _contentTextController = TextEditingController();

  void _incrementCounter() {
    setState(() {
      _is_add_item = !_is_add_item;
    });
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _is_add_item = false;
      _isItemDetails = false;
      _isDateDetail = false;
    });
  }

  Widget _body(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    if (_is_add_item) {
      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _dateTextController,
              textInputAction: TextInputAction.next,
              enabled: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '日付',
                  // inputの端にカレンダーアイコンをつける
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {

                    // textFieldがの値からデフォルトの日付を取得する
                    DateTime initDate = DateTime.now();
                    try {
                      initDate = DateFormat('yyyy/MM/dd').parse(_dateTextController.text);
                    } catch (_) {}

                    // DatePickerを表示する
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: initDate,
                      firstDate: DateTime(2016),
                      lastDate: DateTime.now().add(Duration(days: 360),),
                    );

                    // DatePickerで取得した日付を文字列に変換
                    String? formatedDate;
                    try {
                      formatedDate = DateFormat('yyyy/MM/dd').format(picked!);
                    } catch (_) {}
                    if (formatedDate != null) {
                      _dateTextController.text = formatedDate;
                    }
                  },
                ),
              ),
                  // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              focusNode: FocusNode(
                debugLabel: "datePicker",
                
              )
            ),
            TextFormField(
              controller: _contentTextController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey.currentState!.validate()) {
                        setState(() => {
                          _is_add_item=false,
                          entries.add(_contentTextController.text),
                          dateEntries.add(DateFormat('yyyy/MM/dd').parse(_dateTextController.text)),
                          colorCodes.add((Random().nextDouble() * 900).toInt()),
                          _contentTextController.text='',
                          _dateTextController.text='',
                        });
                      }
                      },
                    child: const Text('Submit'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => {
                        _is_add_item=false,
                        _contentTextController.text='',
                        _dateTextController.text='',
                      });
                    },
                    child: const Text('back'),
                  ),
              ],)
            ),
          ],
        ),
      );
    } else if(_isItemDetails){
      return Column(
        children: [
          Text(currentEntry),
          Text(currentDateTime.toString()),
          ElevatedButton(
            onPressed: () { setState(() {
              _isItemDetails = false;
            }); },
            child: const Text('back'),

          ),
        ],
      );
    } else if(_isDateDetail){
      final List<String> _entries = <String>[];
      final List<DateTime> _dateEntries = <DateTime>[];
      final List<int> _colorCodes = <int>[];

      for (int i = 0; i < entries.length; i++) {
        if (DateFormat('yyyy/MM/DD').format(dateEntries[i]) == DateFormat('yyyy/MM/DD').format(_dateShowDetail)) {
          _entries.add(entries[i]);
          _dateEntries.add(dateEntries[i]);
          _colorCodes.add(colorCodes[i]);
        }
      }

      return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _entries.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _dateShowDetail = DateTime.now();
                          _isDateDetail = false;
                        });
                      },
                      child: const Text('back'),
                    ),
                  )
                ],
              );
            } else {
              return GestureDetector(
                  onTap: (){
                    setState(() {
                      currentEntry = _entries[index-1];
                      currentDateTime = _dateEntries[index-1];
                      _isItemDetails = true;
                    });
                  },
                  child: Container(
                    height: 50,
                    color: Colors.amber[_colorCodes[index-1]],
                    child: Center(child: Text('Entry ${_entries[index-1]} / until ${_dateEntries[index-1]}')),
                  )
              );
            }
          }
      );
    } else if(_selectedIndex == 1){
      return TableCalendar(
        firstDay: DateTime.utc(2010, 1, 1),
        lastDay: DateTime.utc(2030, 1, 1),
        focusedDay: DateTime.now(),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _isDateDetail = true;
            _dateShowDetail = selectedDay;
          });
        },
      );
    }else {
      return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: entries.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
                onTap: (){
                  setState(() {
                    currentEntry = entries[index];
                    currentDateTime = dateEntries[index];
                    _isItemDetails = true;
                  });
                  },
                child: Container(
                  height: 50,
                  color: Colors.amber[colorCodes[index]],
                  child: Center(child: Text('Entry ${entries[index]} / until ${dateEntries[index]}')),
                )
            );
          }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: _body(context),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'カレンダー'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'お知らせ'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'アカウント'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void dispose() {
    _dateTextController.dispose();
    _contentTextController.dispose();
    super.dispose();
  }
}
