import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String? doctorId;
  final String? doctorName;
  final String? patientId;
  final String? patientName;

  ChatScreen({
    this.doctorId,
    this.doctorName,
    this.patientId,
    this.patientName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance; 
  final DatabaseReference _chatListDatabase =
      FirebaseDatabase.instance.ref().child('ChatList');
  final DatabaseReference _chatDatabase =
      FirebaseDatabase.instance.ref().child('Chat');
  final TextEditingController _messageController = TextEditingController(); //Controlador de texto da mensagem digitada
  String? _currentUserId; //id do atual usuario

  bool get isDoctor => _currentUserId == widget.doctorId; //verifica se é doutor

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentUserId = _auth.currentUser?.uid;
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      String message = _messageController.text.trim(); //Retira espacos inuteis
      String chatId = _chatDatabase.push().key!; //ID de cada mensagem 
      String timeStamp = DateTime.now().toIso8601String(); //Horario do envio

      String senderUid;
      String receiverUid;

      if (isDoctor) { //Se for doutor, doutor sera o remetente e o paciente o receptor
        senderUid = _currentUserId!;
        receiverUid = widget.patientId!;
      } else { //inverso
        senderUid = _currentUserId!;
        receiverUid = widget.doctorId!;
      }

      _chatDatabase.child(chatId).set({ //Salvando mensagem
        'message': message,
        'receiver': receiverUid,
        'sender': senderUid,
        'timestamp': timeStamp,
      });

      _chatListDatabase.child(senderUid).child(receiverUid).set({
        'id': receiverUid,
      });

      _chatListDatabase.child(receiverUid).child(senderUid).set({
        'id': senderUid,
      });

      _messageController.clear(); //Limpa o campo depois de enviar a mensagem
    }
  }

  @override
  Widget build(BuildContext context) {
    String? chatPartnerName = isDoctor ? widget.patientName : widget.doctorName; //Nome do parceiro da conversa

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '$chatPartnerName', //Nome do chat
            style: TextStyle(fontSize: 16),
          ),
        ),
        body: Column(
          children: [
            Expanded(
                child: StreamBuilder( //Reconstroi sempre que há mudanças
                    stream: _chatDatabase.onValue, //Sempre que houver mudanca
                    builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                      if (!snapshot.hasData ||
                          snapshot.data?.snapshot.value == null) {
                        return Center(child: Text('Nenhuma mensagem ainda.'));
                      } //Verficação de dados disponiveis
                      Map<dynamic, dynamic> messagesMap = snapshot
                          .data!.snapshot.value as Map<dynamic, dynamic>;
                      List<Map<String, dynamic>> messagesList = []; //Lista das mensagens

                      messagesMap.forEach((key, value) { //Filtra as mensagens da conversa para que apenas as mensagens entre os dois lados sejam mostradadas
                        if ((value['sender'] == _currentUserId &&
                                value['receiver'] == widget.doctorId) || //Se remetende é o usuario e destinatario é o mdeidoc
                            (value['sender'] == widget.doctorId &&
                                value['receiver'] == _currentUserId) || //Se remetente é o medico e o destinatario é o usuario
                            (value['sender'] == _currentUserId &&
                                value['receiver'] == widget.patientId) || //Se o remetente é o usuario e o destinatario é o paciente
                            (value['sender'] == widget.patientId &&
                                value['receiver'] == _currentUserId)) { //Se o remetente é o paciente e o destinatario o usuario atual
                          messagesList.add({
                            'message': value['message'],
                            'sender': value['sender'],
                            'timestamp': value['timestamp'],
                          }); //Adicionando as mensagem que possuem as regras na lista
                        }
                      });
                      messagesList.sort(
                          (a, b) => a['timestamp'].compareTo(b['timestamp'])); //Ordena as mensagens por ordem de envio

                      return ListView.builder(
                          itemCount: messagesList.length, //Numero total de mensagens
                          itemBuilder: (context, index) {
                            bool isMe =
                                messagesList[index]['sender'] == _currentUserId; //Verifica se a mensagem foi adicionada pelo atual usuario
                            return Align( //Se for verdadeira a mensagem ficara a direita, se nao a esquerda
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 16),
                                margin: EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? Color(0xffC8C4FF)
                                      : Color(0xffE3E3E3),
                                  borderRadius: isMe
                                      ? BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.zero)
                                      : BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.zero,
                                          bottomRight: Radius.circular(10)),
                                ),
                                child: Text(messagesList[index]['message']),
                              ),
                            );
                          });
                    })),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row( //Campo para inserir mensagem
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(fontSize: 14),
                        controller: _messageController,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xffF0EFFF),
                            hintText: 'Digite sua mensagem.',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Color(0xffC8C4FF)))),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: _sendMessage,
                      icon: Icon(
                        Icons.send,
                        size: 30,
                        color: Color(0xff0064FA),
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}