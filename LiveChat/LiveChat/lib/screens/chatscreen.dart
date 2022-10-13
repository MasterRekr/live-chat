import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_chat_messenger/services/sharedpref_helper.dart';
import 'package:live_chat_messenger/services/database.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class ChatScreen extends StatefulWidget {
  final String chatWithUsername, name;
  ChatScreen(this.chatWithUsername, this.name);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Variables
  String? chatRoomId, messageId = "";
  Stream? messageStream;
  String? myName, myProfilePic, myUserName, myEmail;
  TextEditingController messageTextEditingController = TextEditingController();

  Future<dynamic> getMyInfoFromSharedPreferences() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getProfileUrl();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();

    chatRoomId = getChatRoomIdByUsernames(widget.chatWithUsername, myUserName!);
  }

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  // Add message to Firebase
  addMessage(bool sendClicked) {
    if (messageTextEditingController.text != "") {
      String message = messageTextEditingController.text;

      // Get and save the timestamp of the message
      var lastMessageTs = DateTime.now();

      // Save all relevant information for the message
      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myUserName,
        "ts": lastMessageTs,
      };

      // MessageId
      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }
      // Update lastMessage
      DatabaseMethods()
          .addMessage(chatRoomId!, messageId!, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSentAt": lastMessageTs,
          "lastMessageSentBy": myUserName
        };
        DatabaseMethods()
            .updateLastMessageSent(chatRoomId!, lastMessageInfoMap);

        if (sendClicked) {
          // Remove the text in the message input field
          messageTextEditingController.text = "";
          // Make the messageid blank
          messageId = "";
        }
      });
    }
  }

  // Message box
  Widget chatMessageTile(String message, bool sendByMe) {
    return Row(
      // If sending -> message on right, if receiving -> message on left
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
              minWidth: 0,
              minHeight: 0,
              maxWidth: (MediaQuery.of(context).size.width) * 0.9,
              maxHeight: (MediaQuery.of(context).size.height)),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                // Different appearance for sending and receiving
                bottomLeft: sendByMe ? Radius.circular(24) : Radius.circular(0),
                bottomRight:
                    sendByMe ? Radius.circular(0) : Radius.circular(24),
              ),
              color: Colors.blue[800],
            ),
            padding: EdgeInsets.all(16),
            child: Flexible(
                child: Text(
              message,
              style: TextStyle(color: Colors.white),
              softWrap: false,
              maxLines: 10,
            )),
          ),
        ),
      ],
    );
  }

  // Live-Chat function
  Widget chatMessages() {
    return StreamBuilder<dynamic>(
      stream: messageStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.only(bottom: 80, top: 20), //70 16
                itemCount: snapshot.data.docs.length,
                reverse: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return chatMessageTile(
                      ds["message"], myUserName == ds["sendBy"]);
                })
            // If no messages have been sent, display loading icon
            : Center(child: CircularProgressIndicator.adaptive());
      },
    );
  }

  getAndSetMessages() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  doThisOnLaunch() async {
    await getMyInfoFromSharedPreferences();
    getAndSetMessages();
  }

  @override
  void initState() {
    doThisOnLaunch();
    super.initState();
  }

  // Chatscreen UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: Colors.blue[800],
        bottomOpacity: 0.0,
        elevation: 0.0,
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topRight,
                colors: [Color.fromARGB(255, 211, 211, 211), Colors.white])),
        child: Stack(
          children: [
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    // Text Input Field
                    Expanded(
                        child: TextField(
                      controller: messageTextEditingController,
                      onChanged: (value) {
                        addMessage(false);
                      },
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "type something...",
                          hintStyle:
                              TextStyle(color: Colors.black.withOpacity(0.6))),
                    )),
                    // Send Button
                    GestureDetector(
                      onTap: () {
                        addMessage(true);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 10, color: Colors.blue.shade800),
                            color: Colors.blue[800],
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
