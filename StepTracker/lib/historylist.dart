class historyList {
  String? date;
  int? dailySteps;
  int? consecutiveSteps;
  int? totalSteps;

  historyList();

  Map<String, dynamic> toJson() => {'date': date, 'dailySteps':dailySteps,'consecutiveSteps':consecutiveSteps, 'totalSteps':totalSteps };

  historyList.fromSnapshot(snapshot)
    : date=snapshot.data()['date'],
        dailySteps=snapshot.data()['dailySteps'],
        consecutiveSteps=snapshot.data()['consecutiveSteps'],
        totalSteps=snapshot.data()['totalSteps'];
}