import 'package:doctorappointment/models/doctor.dart';
import 'package:doctorappointment/screens/doctor/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorDetailPage extends StatefulWidget {
  final Doctor doctor;

  const DoctorDetailPage({super.key, required this.doctor});

  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _requestDatabase = FirebaseDatabase.instance
      .ref('Requests'); 

  TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes de médicos'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 115,
                    height: 115,
                    decoration: BoxDecoration(
                      color: Color(0xffF0EFFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: widget.doctor.profileImageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.doctor.profileImageUrl,
                              fit: BoxFit.fitWidth,
                            ),
                          )
                        : Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${widget.doctor.firstName} ${widget.doctor.lastName}',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 4),
                      Text(
                        widget.doctor.category,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text('De: ${widget.doctor.city}',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(
                        height: 6,
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Image.asset(
                              'images/phone_call.png',
                              width: 30,
                              height: 30,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              _makePhoneCall(widget.doctor.phoneNumber);
                            },
                          ),
                          IconButton(
                            icon: Image.asset(
                              'images/chat_icon.png',
                              width: 30,
                              height: 30,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              String currentUserId = _auth.currentUser!.uid;
                              String doctorName ='${widget.doctor.firstName.toString()} ${widget.doctor.lastName.toString()}';

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                      doctorId: widget.doctor.uid,
                                      doctorName: doctorName,
                                      patientId: currentUserId,
                                      ),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffFFB342),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _openMap();
                  },
                  child: Text('VER LOCALIZAÇÃO NO MAPA',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
              SizedBox(height: 50),
              Text('Selecione a Data e Hora', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Color(0xffF0EFFF),
                  border: Border.all(
                    color: Color(0xffC8C4FF),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff0064FA),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _selectDate(context),
                            child: Text(
                              _selectedDate == null
                                  ? 'Selecione a Data'
                                  : DateFormat('MM/dd/yyyy')
                                      .format(_selectedDate!),
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff0064FA),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _selectTime(context),
                            child: Text(
                              _selectedTime == null
                                  ? 'Selecione a hora'
                                  : _selectedTime!.format(context),
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      style: TextStyle(fontSize: 16),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Descrição',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Color(0xffF0EFFF),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff0064FA),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _bookAppointment();
                  },
                  child: Text(
                    'AGENDAR CONSULTA',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _openMap() async {
    final String googleMapUrl =
        'https://www.google.com/maps/search/?api=1&query=${widget.doctor.latitude},${widget.doctor.longitude}';
    if (await canLaunch(googleMapUrl)) {
      await launch(googleMapUrl);
    } else {
      throw 'Não pode abrir o mapa';
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      throw 'Não foi possivel chamar esse numer $phoneNumber';
    }
  }


  void _bookAppointment() {
    if (_selectedDate != null &&
        _selectedTime != null &&
        _descriptionController.text.isNotEmpty) {
      String date = DateFormat('MM/dd/yyyy').format(_selectedDate!);
      String time = _selectedTime!.format(context);
      String description = _descriptionController.text;
      String requestId = _requestDatabase.push().key!;
      String currentUserId = _auth.currentUser!.uid;
      String receiverId = widget.doctor.uid;
      String status = 'pending';

      _requestDatabase.child(requestId).set({
        'date': date,
        'time': time,
        'description': description,
        'id': requestId,
        'receiver': receiverId,
        'sender': currentUserId,
        'status': status,
      }).then((_) {
        setState(() {
          _selectedDate = null;
          _selectedTime = null;
          _descriptionController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Agendamento solicitado com sucesso')));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('O agendamento sofreu uma falha, tente novamente mais tarde')));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Selecione uma Data e hora para agendar')));
    }
  }
}
