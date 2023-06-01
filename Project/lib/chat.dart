import 'package:Project/app_state.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final String roomID = ModalRoute.of(context)!.settings.arguments as String;
    final chatService = Provider.of<ApplicationState>(context);

    FirebaseAuth auth = FirebaseAuth.instance;
    User? cuser = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(icon: const Icon(Icons.calculate), onPressed:(){Navigator.pushNamed(context, '/calculate');}),
        ],
        
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatService.getMessages(roomID),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot message = snapshot.data!.docs[index];
                    DateTime dateTime;
                    if (message['timestamp'] == null) {
                      dateTime = DateTime.now();
                    } else {
                      Timestamp timestamp = message['timestamp'];
                      dateTime = timestamp.toDate();
                    }
                    String formattedDateTime =
                        DateFormat('kk:mm').format(dateTime);

                    if (cuser!.uid == message['userId']) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Card(
                              child: ListTile(
                                leading: ClipOval(
                                    child: Image.network(
                                  message['photoURL']!,
                                  fit: BoxFit.cover,
                                  width: 30,
                                  height: 30,
                                )),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(message['name']! + ": ",
                                        style: TextStyle(fontSize: 10)),
                                    Text(message['text']),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Text(formattedDateTime),
                        ],
                      );
                    } else {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Card(
                              child: ListTile(
                                trailing: ClipOval(
                                    child: Image.network(
                                  message['photoURL']!,
                                  fit: BoxFit.cover,
                                  width: 30,
                                  height: 30,
                                )),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(message['name']! + ": ",
                                        style: TextStyle(fontSize: 10)),
                                    Text(message['text']),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Text(formattedDateTime),
                        ],
                      );
                    }
                  },
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Leave a message',
                    fillColor: Color.fromARGB(255, 225, 225, 225),
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your message to continue';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                color: Color.fromARGB(255, 225, 225, 225),
                child: IconButton(
                  onPressed: () async {
                    if (_messageController.text.isEmpty) {
                    } else {
                      await chatService.addMessage(
                          _messageController.text, roomID);
                      _messageController.clear();
                    }
                  },
                  icon: Row(
                    children: const [
                      Icon(Icons.send),
                      SizedBox(width: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
