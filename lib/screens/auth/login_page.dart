import 'package:doctorappointment/screens/auth/signup_screen.dart';
import 'package:doctorappointment/screens/doctor/doctor_home_page.dart';
import 'package:doctorappointment/screens/patient/patient_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool _isLoading = false;
  bool _isNavigation = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: _isLoading
            ? CircularProgressIndicator()
            : Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 48,),
                          Image.asset('images/cross.png'),
                          SizedBox(height: 10,),
                          Text('Bem vindo!', style: TextStyle(fontSize: 24)),
                          Text('Login', style: TextStyle(fontSize: 24),),
                          SizedBox(height: 60,),
                          SizedBox(
                            height: 44,
                            child: TextFormField(
                              style:  TextStyle(fontSize: 24),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xffF0EFFF),
                                contentPadding: EdgeInsets.only(left: 10, right: 10),
                                labelText: 'Email',
                                labelStyle:  TextStyle(fontSize: 24),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0), 
                                  borderSide: BorderSide(
                                    color: Color(0xff0064FA), 
                                    width: 1.0, 
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: Color(0xff0064FA), 
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: Color(0xff0064FA), 
                                    width: 1.0,  
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (val) => email = val,
                              validator: (val) => val!.isEmpty ? 'Insira um email' : null,
                            ),
                          ),
                          SizedBox(height: 10,),
                          SizedBox(
                            height: 44,
                            child: TextFormField(
                              style:  TextStyle(fontSize: 24),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xffF0EFFF),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                labelText: 'Senha',
                                labelStyle:  TextStyle(fontSize: 24),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: Color(0xff0064FA),
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: Color(0xff0064FA),
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: Color(0xff0064FA),
                                    width: 1.0,
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey.shade400,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _obscureText,
                              keyboardType: TextInputType.text,
                              onChanged: (val) => password = val,
                              validator: (val) => val!.length < 6
                                  ? 'A senha deve conter no minimo 6 caracteres'
                                  : null,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff0064FA), 
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0), 
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), 
                              ),
                              child: Text(
                                'Login',
                                style:  TextStyle(fontSize: 24),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => RegisterPage()));
                              },
                              child: Text('Não possui conta? cadastre-se', style:  TextStyle(fontSize: 24),),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        User? user = userCredential.user;

        if (user != null) {
          DatabaseReference userRef = _database.child('Doutores').child(user.uid);
          DataSnapshot snapshot = await userRef.get();

          if (snapshot.exists) {
            _navigateToDoctorHome();
          } else {
            userRef = _database.child('Pacientes').child(user.uid);
            snapshot = await userRef.get();
            if (snapshot.exists) {
              _navigateToPatientHome();
            } else {
              _showErrorDialog('Usuario não encontrado');
            }
          }
        }
      } catch (e) {
        _showErrorDialog(e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToDoctorHome() {
    if(!_isNavigation){
      _isNavigation = true;
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => DoctorHomePage()));
    }
  }

  void _navigateToPatientHome() {
    if(!_isNavigation){
      _isNavigation = true;
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PatientHomePage()));
    }
  }

}