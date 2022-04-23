import 'package:flutter/material.dart';
import 'historylist.dart';

class historyCard extends StatelessWidget {
  final historyList _historyList;

  historyCard(this._historyList);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text ("Date: ${_historyList.date}\nDaily steps taken: ${_historyList.dailySteps}\nMost consecutive steps: ${_historyList.consecutiveSteps}\nTotal steps so far: ${_historyList.totalSteps}"),
            )
          ]
        )
      )
    );
  }
  
}