import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flushbar/flushbar.dart';

class MyHomePage extends StatefulWidget
{
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  DateTime _dateTime = DateTime.now();
  String _alarmTime;
  String _alarmTimeFormatted;
  String _alarmTimeDisplay = "Set Alarm";
  String alarmName = "Alarm";
  bool timeReached = false;

  var snackBar;

  String status = 'test';

  final TextEditingController alarmNameController = new TextEditingController();

  String _timeString;

  bool buttonFlag;
  Timer t;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    buttonFlag = true;
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    super.initState();

    var initializationSettingsIOS = new IOSInitializationSettings();

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    alarmNameController.text = alarmName;
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;
      //print(_timeString);

      if (_alarmTimeFormatted == _timeString && buttonFlag == false) {
        const oneSec = const Duration(seconds: 2);
        t = new Timer.periodic(oneSec, (Timer t) =>
            FlutterRingtonePlayer.playRingtone(looping: true));
        timeReached = true;
        print("Alarm Ringing");
      }
    });
  }

  String _formatDateTime(DateTime dateTime) {
    String time = DateFormat('hh:mm:ss').format(dateTime);
    //print(time);
    return time;
  }

  static String _formatAlarmTime(DateTime dateTime) {
    String time = DateFormat('hh:mm a').format(dateTime);
    //print(time);
    return time;
  }

  @override
  Widget build(BuildContext context) {
    String currentDateTime = DateFormat.jm().format(DateTime.now());
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.blueGrey,
          appBar: AppBar(
            backgroundColor: Colors.black54,
            title: Text('Secret Alarm Clock', style: TextStyle(
                fontFamily: 'Tomorrow'
            ),),
          ),
          body:
          Center(
            child: Column(
              children: <Widget>[
                Expanded(
                  child :Container(
//              padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.all(10.0),
                    child:
                    MaterialButton(
                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                      child:
                      Text('$alarmName', style: new TextStyle(
                        fontSize: 50.0,
                        fontFamily: 'Tomorrow',
                        //fontWeight: FontWeight.w400
                      )),
                      color: Colors.orangeAccent,
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext builder) {
                              return Container(
                                  height: MediaQuery
                                      .of(context)
                                      .size
                                      .height,
                                  //MediaQuery.of(context).copyWith().size.height,
                                  width: 100,
                                  child: alarmNamePicker()
                              );
                            });
                      },
                    ),
                    width: MediaQuery.of(context).copyWith().size.width * 5/6,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.all(10.0),
                    child:
                    MaterialButton(
                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                      child:
                      Text('$_alarmTimeDisplay', style: new TextStyle(
                        fontSize: 50.0,
                        fontFamily: 'Tomorrow',
                      )),
                      color: Colors.greenAccent,
                      onPressed: () {
                        buttonFlag = true;
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext builder) {
                              return Container(
                                  height: 300,
                                  //MediaQuery.of(context).copyWith().size.height,
                                  width: 200,
                                  child: alarmTimePicker()
                              );
                            });
                      }
                      ,
                    ),
                    width: MediaQuery.of(context).copyWith().size.width * 5/6,
                  ),
                ),
                Expanded(
                    flex: 2,
                    child: Center(
                        child: ClipOval(
                          child: Material(
                            color: Colors.blue,
                            child: InkWell(
                              splashColor: Colors.redAccent,
                              child: SizedBox(
                                width: 300,
                                height: 300,
                                child: buttonFlag ? Icon(Icons.play_arrow,
                                  size: 100,) : Icon(Icons.stop, size: 100,),
                              ),
                              onTap: () async {
                                if (buttonFlag) {
                                  buttonFlag = false;
                                  setState(() {
                                    //_dateTime = dateTime;
                                    _alarmTime = _dateTime.toString();
                                    _alarmTimeFormatted =
                                        _formatDateTime(_dateTime);
                                    _alarmTimeDisplay = _formatAlarmTime(_dateTime);
                                    status = 'Alarm Set';


                                    if (buttonFlag == false)
                                    {
                                      scheuleAtParticularTime(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              _dateTime.millisecondsSinceEpoch));
                                    }
                                  });

                                  showSimpleFlushBar(context);
                                }

                                else {

                                  if(timeReached == false)
                                  {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext) =>
                                            CupertinoAlertDialog(
                                              title: Text("Warning"),
                                              content: Text("Alarm will turn off"),
                                              actions: <Widget>[
                                                CupertinoDialogAction(
                                                  isDefaultAction: true,
                                                  child: Text("Cancel"),
                                                  onPressed: () {
                                                    print(("Cancel"));
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                CupertinoDialogAction(
                                                  isDefaultAction: true,
                                                  child: Text("Okay"),
                                                  onPressed: () async{
                                                    print(("Okay"));
                                                    Navigator.of(context).pop();
                                                    buttonFlag = true;
                                                    //print(_alarmTime);
                                                    print(_alarmTimeFormatted);
                                                    await _cancelNotification();
                                                    timeReached = false;
                                                    status = 'Alarm Canceled';
                                                    showSimpleFlushBar(context);
                                                  },
                                                )
                                              ],
                                            )
                                    );
                                  }
                                  else
                                  {
                                    if(timeReached)
                                    {
                                      t.cancel();
                                      status = 'Alarm Stopped';
                                      showSimpleFlushBar(context);
                                    }

                                    buttonFlag = true;
                                    //print(_alarmTime);
                                    print(_alarmTimeFormatted);
                                    FlutterRingtonePlayer.stop();

                                    await _cancelNotification();
                                    timeReached = false;
                                  }
                                }
                              },
                            ),
                          ),
                        )
                    )
                ),

              ],
            ),
          ),

        ) );
  }

  Future scheuleAtParticularTime(DateTime timee) async
  {
    var time = Time(timee.hour, timee.minute, timee.second);
    print(time.toString());
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'repeatDailyAtTime channel id',
        'repeatDailyAtTime channel name',
        'repeatDailyAtTime description');
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails(
        presentAlert: true, presentBadge: true);
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    flutterLocalNotificationsPlugin.showDailyAtTime(0, alarmName,
        _alarmTimeDisplay, time, platformChannelSpecifics);
    //alarmTime = _formatDateTime(timee);
    print('scheduled');
  }

  Future<void> _cancelNotification() async
  {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  Widget alarmTimePicker() {
    return
      CupertinoDatePicker(
        initialDateTime: _dateTime,
        //use24hFormat: false,
        mode: CupertinoDatePickerMode.time,
        onDateTimeChanged: (dateTime) {
          setState(() {
            _dateTime = dateTime;
            _alarmTimeDisplay = _formatAlarmTime(dateTime);
          });
        },
      );
  }

  Widget alarmNamePicker() {
    return new Center(
      child: new Column(
        children: <Widget>[
          new TextField(
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 50),
              maxLength: 20,
              decoration: new InputDecoration(
                  hintText: "Alarm Name"
              ),
              controller: alarmNameController,
              textInputAction: TextInputAction.done,
              onSubmitted: (String str) {
                setState(() {
                  alarmName = str;
                  print(alarmName);
                });
              }
          ),
        ],
      ),
    );
  }

  alertDialogWarning() {
    return CupertinoAlertDialog(
      title: Text("Warning"),
      content: Text("Alarm will turn off"),
      actions: <Widget>[
        CupertinoDialogAction(
          isDefaultAction: true,
          child: Text("Okay"),
          onPressed: () {
            print(("Okay"));
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  void showSimpleFlushBar(BuildContext context){
    Flushbar(
      message: status,
      duration: Duration(seconds: 3),
      flushbarStyle: FlushbarStyle.GROUNDED,
      isDismissible: true,
    )..show(context);
  }
}