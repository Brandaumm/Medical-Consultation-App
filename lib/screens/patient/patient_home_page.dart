import 'package:doctorappointment/profile_page.dart';
import 'package:doctorappointment/screens/doctor/doctor_list_page.dart';
import 'package:doctorappointment/screens/patient/chat_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _children = [
    DoctorListPage(),
    ChatListPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async{
    return await showDialog(context: context, builder: (context) => AlertDialog(
      title: Text('Você tem certeza?'),
      content: Text('Deseja sair do aplicativo?'),
      actions: <Widget>[
        TextButton(
          onPressed: (){
          Navigator.of(context).pop(false);

        }, child: Text('Não')),

        TextButton(onPressed: (){
          Navigator.of(context).pop(true);
          SystemNavigator.pop();
        }, child: Text('Sim')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:  _onWillPop,
      child: Scaffold(
        body: _children.elementAt(_selectedIndex),
        bottomNavigationBar:
            BottomNavigationBar(items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
        ),
      ),
    );
  }
}
