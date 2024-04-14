import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChatRoomPage extends StatelessWidget {
  const ChatRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            //  This is where our chat will display
            Expanded(
              child: Container(
                color: Colors.yellow,
              ),
            ),

            // Message Box
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: const Row(
                children: [
                  Flexible(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type Your Message..."),
                    ),
                  ),
                  Icon(Icons.send),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
