import 'package:doctorappointment/models/booking.dart';
import 'package:doctorappointment/screens/auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _requestDatabase = FirebaseDatabase.instance.ref().child('Requests');
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async{
    String? currentUserId = _auth.currentUser?.uid;
    if(currentUserId != null){
      await _requestDatabase.orderByChild('sender').equalTo(currentUserId).once().then((DatabaseEvent event){
        if(event.snapshot.value != null){
          Map<dynamic,dynamic> bookingMap = event.snapshot.value as Map<dynamic,dynamic>;
          List<Booking> tempBookings = [];
          bookingMap.forEach((key,value){
            tempBookings.add(Booking.fromMap(Map<String, dynamic>.from(value)));
          });
          setState(() {
            _bookings = tempBookings;
            _isLoading = false;
          });
        }else{
          setState(() {
            _isLoading =  false;
          });
        }
      });
    }
  }


  void _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,  
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Perfil do Médico'),
      actions: [
        IconButton(onPressed: _logout, icon: Icon(Icons.logout))
      ],
    ),
    body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : _bookings.isEmpty
            ? Center(child: Text('Nenhuma consulta diponivel'))
            : ListView.builder(
                itemCount: _bookings.length, 
                itemBuilder: (context, index) {
                  final booking = _bookings[index];
                  return ListTile(
                    title: Text(booking.description), 
                    subtitle: Text('Data ${booking.date} Hora: ${booking.time}'), 
                    trailing:  Text(booking.status),
                  );
                },
              ),
  );
}

}