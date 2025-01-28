import 'package:doctorappointment/models/doctor.dart';
import 'package:flutter/material.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Color(0xffF0EFFF),
        border: Border.all(color: Color(0xffC8C4FF)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Card(
        color: Color(0xffF0EFFF),
        elevation: 0.0,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        child: ListTile(
          leading: Container(
            width: 55,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: Color(0xff0064FA)),
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(doctor.profileImageUrl),
            ),
          ),
          title: Text(
            '${doctor.firstName} ${doctor.lastName}',
            style: TextStyle(fontSize: 15, color: Color(0xff006AFA)),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Row(children: [
                Text('${doctor.category} - ${doctor.city}',
                style: TextStyle(fontSize: 15, color: Color(0xff006AFA)),)
              ],),
              Text(
                'Experiencia: ${doctor.yearsOfExperience} anos',
                style: TextStyle(
                        fontSize: 15,
                        color: Color(0xff006AFA),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}