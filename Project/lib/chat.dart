import 'package:Project/app_state.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
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
                    return ListTile(
                      title: Text(message['text']),
                      subtitle: Text(message['userId']),
                    );
                  },
                );
              },
            ),
          ),
          TextField(
            controller: _messageController,
            onSubmitted: (message) async {
              await chatService.addMessage(message, roomID);
              _messageController.clear();
            },
          ),
        ],
      ),
    );
  }
}
