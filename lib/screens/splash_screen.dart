import 'package:doctorappointment/screens/auth/login_page.dart';
import 'package:doctorappointment/screens/doctor/doctor_home_page.dart';
import 'package:doctorappointment/screens/patient/patient_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
     _checkAuthUser();
  }

  Future<void> _checkAuthUser() async {
    User? user = _auth.currentUser;

    if (user == null) {
      await Future.delayed(const Duration(seconds: 1));
      _navigateToLogin();
    } else {
      DatabaseReference userRef = _database.child("Doutor").child(user.uid);
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        await Future.delayed(const Duration(seconds: 6));
        _navigateToDoctorHomePage();
      } else {
        userRef = _database.child("Patient").child(user.uid);
        snapshot = await userRef.get();
        if (snapshot.exists) {
          await Future.delayed(const Duration(seconds: 6));
          _navigateToPatientHomePage();
        } else {
          await Future.delayed(const Duration(seconds: 6));
          _navigateToLogin();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: const Color(0xff0064FA),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 10, top: 80),
                child: Text(textAlign: TextAlign.end,
                  'Cuidando\nCurando',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        )),
              ),
              Expanded(child: Image.asset('images/dna_image.png', width: MediaQuery.of(context).size.width),)
            ],
          )),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void _navigateToDoctorHomePage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const DoctorHomePage()));
  }

  void _navigateToPatientHomePage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const PatientHomePage()));
  }
}
