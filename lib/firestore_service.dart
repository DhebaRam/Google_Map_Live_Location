import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_map_demo/users_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirestoreService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> updateUserLocation(String userId, LatLng location) async {
    try {
      print("Update User Location Method Called --- >");
      await _firestore.collection('users').doc(userId).update({
        'location': {'lat': location.latitude, 'lng': location.longitude},
      });
    } on FirebaseException catch (e) {
      print('Ann error due to firebase occured $e');
    } catch (err) {
      print('Ann error occured $err');
    }
  }

  static Stream<List<User>> userCollectionStream() {
    Stream<List<User>> data = _firestore.collection('users').orderBy('timestamp').snapshots().map((snapshot) => snapshot.docs.map((doc) {
        print('Lat Loh ---- > ${doc.id}');
        return User(name: '${doc.get('name')}', location:  Location(lat: doc.get('location')['lng'], lng: doc.get('location')['lat']));
      }).toList());
    print("User Collection Stream Method Called --- >  ${data.map((event) => event.first.name.toString())}");
  return data;
  }
}