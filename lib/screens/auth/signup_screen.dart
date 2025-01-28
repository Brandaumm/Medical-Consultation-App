import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import '../doctor/doctor_home_page.dart';
import '../patient/patient_home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  final _formKey = GlobalKey<FormState>();
  String userType = 'Paciente';
  String email = '';
  String password = '';
  String phoneNumber = '';
  String firstName = '';
  String lastName = '';
  String city = 'Natal';
  String profileImageUrl = '';
  String category = 'Dentista';
  String qualification = '';
  String yearsOfExperience = '';
  double latitude = 0.0;
  double longitude = 0.0;

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  final Location _location = Location();
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar', style: TextStyle(fontSize: 16)),
      ),
      body: _isLoading
          ? CircularProgressIndicator()
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: _imageFile != null
                              ? Image.file(
                                  File(_imageFile!.path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Color(0xffF0EFFF),
                                  width: 100,
                                  height: 100,
                                  child: Center(
                                    child: Icon(
                                      Icons.add_a_photo,
                                      color: Colors.grey.shade600,
                                      size: 30,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tipo de Usuario',
                              style: TextStyle(fontSize: 16),
                            ),
                            Wrap(
                              spacing: 8.0,
                              children:
                                  ['Paciente', 'Doutor'].map((String type) {
                                final isSelected = userType == type;
                                return ChoiceChip(
                                  checkmarkColor: Colors.white,
                                  label: Text(type),
                                  selected: isSelected,
                                  selectedColor: Color(0xff0064FA),
                                  backgroundColor: Color(0xffF0EFFF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    side: BorderSide(
                                      color: isSelected
                                          ? Color(0xff0064FA)
                                          : Color(0xff0064FA),
                                      width: 2.0,
                                    ),
                                  ),
                                  onSelected: (bool selected) {
                                    setState(() {
                                      userType = (selected ? type : null)!;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        height: 44,
                        child: TextFormField(
                          style: TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xffF0EFFF),
                            contentPadding:
                                EdgeInsets.only(left: 10, right: 10),
                            labelText: 'Email',
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
                          validator: (val) =>
                              val!.isEmpty ? 'Digite um email' : null,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 44,
                        child: TextFormField(
                          style: TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xffF0EFFF),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            labelText: 'Senha',
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
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
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
                        height: 10,
                      ),
                      SizedBox(
                        height: 44,
                        child: TextFormField(
                          style: TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xffF0EFFF),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            labelText: 'Numero de telefone',
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
                          keyboardType: TextInputType.phone,
                          onChanged: (val) => phoneNumber = val,
                          validator: (val) => val!.isEmpty
                              ? 'Por favor, digite um numero de telefone'
                              : null,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 44,
                        child: TextFormField(
                          style: TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xffF0EFFF),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            labelText: 'Nome',
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
                          keyboardType: TextInputType.text,
                          onChanged: (val) => firstName = val,
                          validator: (val) =>
                              val!.isEmpty ? 'Porfavor insira seu nome' : null,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 44,
                        child: TextFormField(
                          style: TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xffF0EFFF),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            labelText: 'Sobrenome',
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
                          keyboardType: TextInputType.text,
                          onChanged: (val) => lastName = val,
                          validator: (val) =>
                              val!.isEmpty ? 'Insira seu sobrenome' : null,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        height: 44,
                        child: DropdownButtonFormField<String>(
                          value: city,
                          items: ['Natal', 'Mossoro', 'Recife', 'Parnamirim']
                              .map((String city) {
                            return DropdownMenuItem(
                              value: city,
                              child: Text(
                                city,
                                style: TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              city = val!;
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xffF0EFFF),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            labelText: 'Cidade',
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
                          validator: (val) =>
                              val == null ? 'Selecione uma cidade' : null,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      if (userType == 'Doutor') ...[
                        SizedBox(
                          height: 44,
                          child: TextFormField(
                            style: TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xffF0EFFF),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                              labelText: 'Qualificações',
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
                            onChanged: (val) => qualification = val,
                            validator: (val) => val!.isEmpty
                                ? 'Por favor, insira uma qualificação'
                                : null,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 44,
                          child: DropdownButtonFormField<String>(
                            value: category,
                            items: [
                              'Dentista',
                              'Cardiologista',
                              'Oncologista',
                              'Cirurgião'
                            ].map((String category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(
                                  category,
                                  style: TextStyle(fontSize: 16),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                category = val!;
                              });
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xffF0EFFF),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                              labelText: 'Categoria',
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
                            validator: (val) =>
                                val == null ? 'Selecione uma categoria' : null,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 44,
                          child: TextFormField(
                            style: TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xffF0EFFF),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                              labelText: 'Anos de experiencia',
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
                            keyboardType: TextInputType.number,
                            onChanged: (val) => yearsOfExperience = val,
                            validator: (val) => val!.isEmpty
                                ? 'Por favor, insira os anos de experiencia'
                                : null,
                          ),
                        ),
                      ],
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _getLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffFA9600),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Inserir localização atual',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      if (latitude != 0.0 && longitude != 0.0)
                        Text('Localização: ($latitude, $longitude)'),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff0064FA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Cadastrar',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              )),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> _getLocation() async {
    final locationData = await _location.getLocation();
    setState(() {
      latitude = locationData.latitude!;
      longitude = locationData.longitude!;
    });
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        User? user = userCredential.user;

        if (user != null) {
          String userTypePath = userType == 'Doutor' ? 'Doutores' : 'Pacientes';
          Map<String, dynamic> userData = {
            'uid': user.uid,
            'email': email,
            'phoneNumber': phoneNumber,
            'firstName': firstName,
            'lastName': lastName,
            'city': city,
            'profileImageUrl': profileImageUrl,
            'latitude': latitude,
            'longitude': longitude,
          };

          if (userType == 'Doutor') {
            userData['qualification'] = qualification;
            userData['category'] = category;
            userData['yearsOfExperience'] = yearsOfExperience;
            userData['totalReviews'] = 0;
            userData['averageRating'] = 0.0;
            userData['numberOfReviews'] = 0;
          }

          await _database.child(userTypePath).child(user.uid).set(userData);

          if (_imageFile != null) {
          Reference storageReference = FirebaseStorage.instance.ref().child(
            '$userTypePath/${user.uid}/profileImageUrl');
          UploadTask uploadTask = storageReference.putFile(File(_imageFile!.path));
         TaskSnapshot taskSnapshot = await uploadTask;

          if (taskSnapshot.state == TaskState.success) {
            String downloadUrl = await taskSnapshot.ref.getDownloadURL();
            print('Download URL: $downloadUrl');
            
            await _database.child(userTypePath).child(user.uid).update({
              'profileImageUrl': downloadUrl,
            });
          } else {
            print('Upload failed: ${taskSnapshot.state}');
          }
        }

    
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  userType == 'Doutor' ? DoctorHomePage() : PatientHomePage(),
            ),
          );
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
}
