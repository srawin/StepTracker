import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'database.dart';
import 'history.dart';

import 'package:pedometer/pedometer.dart';

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return const MaterialApp(
      title: "StepTracker",
      home: Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<Homepage> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  int totalStep = 0;
  int dailyStep = 0;
  int consecutiveStep = 0;
  int longestConsecutiveStep = 0;
  int longestDailyStep = 0;
  String _status = 'Stopped', _dailySteps = '', _totalSteps = '', _consecutiveSteps = '', _longestDailyStep = '', _longestConsecutiveStep = '';
  late String formatted;
  bool finishedInit=false;

  final String uid="user1";

  @override
  void initState() {
    super.initState();
    initPlatformState();
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    formatted = formatter.format(now);
    findData(formatted);
  }

  Future findData(date) async{
    DocumentSnapshot a = await FirebaseFirestore.instance.collection(uid).doc(date).get();
    if(await FirestoreDatabase().returnDate(formatted)){
      dailyStep = a.get("dailySteps");
      totalStep = a.get("totalSteps");
      _dailySteps = dailyStep.toString();
      _totalSteps = totalStep.toString();
    }
    DocumentSnapshot b = await FirebaseFirestore.instance.collection(uid).doc("record").get();
    if(await FirestoreDatabase().returnDate("record")){
      longestDailyStep = b.get("recordDailySteps");
      longestConsecutiveStep = b.get("recordConsecutiveSteps");
      totalStep = b.get("recordTotalSteps");
      _longestDailyStep = longestDailyStep.toString();
      _longestConsecutiveStep = longestConsecutiveStep.toString();
      _totalSteps = totalStep.toString();
    }
    finishedInit=true;
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    if(_status == 'stopped'){
      consecutiveStep = 0;
    }
    setState(() {
      _status = event.status;
    });
  }

  Future onStepCount(StepCount event) async {
    if(finishedInit==true){
      if(!await FirestoreDatabase().returnDate(formatted)){
        dailyStep = 0;
      }
      totalStep = totalStep + 1;
      dailyStep = dailyStep + 1;
      consecutiveStep = consecutiveStep + 1;
      if(consecutiveStep>longestConsecutiveStep){
        longestConsecutiveStep = consecutiveStep;
      }
      if(dailyStep>longestDailyStep){
        longestDailyStep = dailyStep;
      }
      FirestoreDatabase().updateUserData(formatted,dailyStep,consecutiveStep,totalStep,longestDailyStep,longestConsecutiveStep);
      setState(() {
        _dailySteps = dailyStep.toString();
        _totalSteps = totalStep.toString();
        _consecutiveSteps = consecutiveStep.toString();
        _longestDailyStep = longestDailyStep.toString();
        _longestConsecutiveStep = longestConsecutiveStep.toString();
      });
    }
  }

  void onPedestrianStatusError(error) {
    setState(() {
      _status = 'Pedestrian Status not available';
    });
  }

  void onStepCountError(error) {
    setState(() {
      _dailySteps = 'Step Count not available';
      _consecutiveSteps = 'Step Count not available';
      _totalSteps = 'Cannot access Firestore';
    });
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StepTracker'),
        backgroundColor: Colors.red,
        actions:[IconButton(icon:const Icon(Icons.library_books),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder:(context)=>History()));
        })],
      ),
      body: Center(
        child: Column(

          children: <Widget>[
            const Divider(
              height: 150,
              thickness: 0,
              color: Colors.white,
            ),
            const Text(
              'Pedestrian status:',
              style: TextStyle(fontSize: 30),
            ),
            Icon(
              _status == 'walking'
                  ? Icons.directions_walk
                  : _status == 'stopped'
                  ? Icons.accessibility_new
                  : Icons.accessibility_new,
              size: 100,
            ),
            Center(
              child: Text(
                _status,
                style: _status == 'walking' || _status == 'stopped'
                    ? const TextStyle(fontSize: 30)
                    : const TextStyle(fontSize: 30)
              ),
            ),
            const Divider(
              height: 100,
              thickness: 0,
              color: Colors.white,
            ),
            Text(
              'Daily steps taken: ' + _dailySteps,
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Consecutive steps taken: ' + _consecutiveSteps,
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Total steps taken: ' + _totalSteps,
              style: const TextStyle(fontSize: 20),
            ),
            const Divider(
              height: 25,
              thickness: 0,
              color: Colors.white,
            ),
            Text(
              'Most daily steps taken: ' + _longestDailyStep,
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Most consecutive steps taken: ' + _longestConsecutiveStep,
              style: const TextStyle(fontSize: 20),
            )
          ],
        ),
      ),
    );
  }
}
