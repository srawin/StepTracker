import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
int prevConsecutiveSteps = 0;

class FirestoreDatabase {
  final String uid="user1";

  Future updateUserData(String date, int dailySteps, int consecutiveSteps, int totalSteps, int recordDailySteps, int recordConsecutiveSteps) async {
    final CollectionReference stepsStore = FirebaseFirestore.instance.collection(uid);
    if(consecutiveSteps>prevConsecutiveSteps){
      prevConsecutiveSteps=consecutiveSteps;
    }
    await stepsStore.doc(date).set({
      'date':date,
      'dailySteps':dailySteps,
      'consecutiveSteps':prevConsecutiveSteps,
      'totalSteps':totalSteps,
    });
    final CollectionReference recordStore = FirebaseFirestore.instance.collection(uid);
    return await recordStore.doc("record").set({
      'recordDailySteps':recordDailySteps,
      'recordConsecutiveSteps':recordConsecutiveSteps,
      'recordTotalSteps':totalSteps,
    });
  }

  Future<bool> returnDate(String date) async{
    var a = await FirebaseFirestore.instance.collection(uid).doc(date).get();
    return a.exists;
  }

}
