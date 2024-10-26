import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lejit/chat_service.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Define the file path or load from a specific path
  final chatFile = await getChatFile();
  runApp(MyApp(chatFile: chatFile));
}

class MyApp extends StatelessWidget {
  final File chatFile;
  const MyApp({Key? key,
  required this.chatFile
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Interface',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: ChatScreen(chatFile: chatFile),
    );
  }
}

// Helper function to locate or create the file if it doesn't exist
Future<File> getChatFile() async {
  final directory = await getApplicationDocumentsDirectory();
  // Log the directory
  print(directory.path);
  final file = File('${directory.path}/chat_messages.txt');
  // Create the file with some default content if it doesn't exist
  if (!await file.exists()) {
    await file.writeAsString('user:Hi\nbot:Hello! How can I assist you?');
  }
  else {
    await file.writeAsString('user:Hi\nbot:Hello! How can I assist you?');
    print('File already exists');
    // Prin
  }
  return file;
}

class ChatScreen extends StatefulWidget {
  final File chatFile;

  ChatScreen({required this.chatFile});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatService _chatService;
  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(chatFile: widget.chatFile);
    loadMessages();
  }

  Future<void> loadMessages() async {
    final lines = await widget.chatFile.readAsLines();
    print(lines);
    setState(() {
      messages = lines.map((line) {
        final parts = line.split(':');
        return {'sender': parts[0], 'message': parts[1]};
      }).toList();
    });
  }

  void handleSendMessage(String message) async {
    setState(() {
      messages.add({'sender': 'user', 'message': message});
    });

    final botReply = await _chatService.sendMessageToGemini(message);

    setState(() {
      messages.add({'sender': 'bot', 'message': botReply});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Here'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.white70, size: 28),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white70, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ChatBubble(
                  message: message['message']!,
                  isSentByUser: message['sender'] == 'user',
                );
              },
            ),
          ),
          ChatInputField(onSend: handleSendMessage),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSentByUser;

  ChatBubble({required this.message, required this.isSentByUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        margin: EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: isSentByUser ? Colors.grey[800] : Colors.black,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          message,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}

class ChatInputField extends StatelessWidget {
  final Function(String) onSend;

  ChatInputField({required this.onSend});

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration:  InputDecoration(
        hintText: "Type a message...",
        hintStyle: const TextStyle(
          color: Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              final message = _controller.text;
              if (message.isNotEmpty) {
                onSend(message);
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}