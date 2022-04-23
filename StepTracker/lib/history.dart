import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'historycard.dart';
import 'main.dart';
import 'historylist.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final String uid="user1";
  List<Object> _historyList = [];

  @override
  void didChangeDependencies(){
    super.didChangeDependencies  ();
    showData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.red,
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: _historyList.length,
          itemBuilder: (context, index){
            return historyCard(_historyList[index] as historyList);
          },
        )
      )

    );
  }

  Future showData() async{
    var a = await FirebaseFirestore.instance.collection(uid).orderBy("date", descending:true).get();
    if (mounted) {
      setState((){
        _historyList = List.from(a.docs.map((doc)=> historyList.fromSnapshot(doc)));
      });
    }
  }
}
