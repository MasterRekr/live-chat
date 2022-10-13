import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:live_chat_messenger/services/sharedpref_helper.dart';
import 'package:live_chat_messenger/services/auth.dart';
import 'package:live_chat_messenger/services/database.dart';
import 'package:live_chat_messenger/screens/chatscreen.dart';
import 'package:live_chat_messenger/screens/signin.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSearching = false;
  String? myName, myProfilePic, myUserName, myEmail, lastMessage;
  Stream? usersStream, chatRoomsStream;

  TextEditingController searchUsernameEditingController =
      TextEditingController();

  Future<dynamic> getMyInfoFromSharedPreferences() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getProfileUrl();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    setState(() {});
  }

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  // Function for when the search button is clicked
  onSearchBtnClick() async {
    isSearching = true;
    setState(() {});
    usersStream = await DatabaseMethods()
        .getUserByUserName(searchUsernameEditingController.text);
    setState(() {});
  }

  // List of all chats
  Widget chatRoomList() {
    return StreamBuilder<dynamic>(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return ChatRoomListTile(
                      ds["lastMessage"], ds.id, myUserName.toString());
                })
            : Center(child: CircularProgressIndicator.adaptive());
      },
    );
  }

  // Displays the ProfilePic, Username and Lastmessage or Email of the searched User
  Widget searchListUserTile({String? profileUrl, name, username, email}) {
    // If UserTile is clicked on get Chatinfo or create a new Chat
    return GestureDetector(
      onTap: () {
        var chatRoomId =
            getChatRoomIdByUsernames(myUserName.toString(), username);
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, username]
        };
        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: profileUrl == null
                  ? Image.asset(
                      'assets/userProfile.png',
                      height: 30,
                      width: 30,
                    )
                  : Image.network(
                      profileUrl,
                      height: 30,
                      width: 30,
                    ),
            ),
            SizedBox(width: 12),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(name), Text(email)])
          ],
        ),
      ),
    );
  }

  // List displayed when the SearchButton is clicked
  Widget searchUsersList() {
    return StreamBuilder<dynamic>(
      stream: usersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return searchListUserTile(
                      profileUrl: ds["imgUrl"],
                      name: ds["name"],
                      email: ds["email"],
                      username: ds["username"]);
                },
              )
            : Center(
                child: CircularProgressIndicator.adaptive(),
              );
      },
    );
  }

  getChatRooms() async {
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  onScreenLoaded() async {
    await getMyInfoFromSharedPreferences();
    getChatRooms();
  }

  @override
  void initState() {
    onScreenLoaded();
    super.initState();
  }

  // Homescreen UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live Chat"),
        toolbarHeight: 100,
        backgroundColor: Colors.transparent,
        bottomOpacity: 0.0,
        elevation: 0.0,
        actions: [
          // Exit to sign in screen
          InkWell(
            onTap: () {
              AuthMethods().signOut().then((s) {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => SignIn()));
              });
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.exit_to_app)),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(50), bottom: Radius.circular(0))),
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    isSearching
                        ? GestureDetector(
                            onTap: () {
                              isSearching = false;
                              searchUsernameEditingController.text = "";
                              setState(() {});
                            },
                            child: Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(Icons.adaptive.arrow_back_rounded)),
                          )
                        : Container(),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 16),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey,
                                width: 1,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(24)),
                        child: Row(
                          children: [
                            Expanded(
                                child: TextField(
                              controller: searchUsernameEditingController,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "username"),
                            )),
                            // Searchbutton GestureDetector
                            GestureDetector(
                                onTap: () {
                                  if (searchUsernameEditingController.text !=
                                      "") {
                                    onSearchBtnClick();
                                  }
                                },
                                child: Icon(Icons.search))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // If Searchbutton was clicked -> display searchUsersList
                // If Searchbutton was not clicked -> display chatRoomList
                isSearching ? searchUsersList() : chatRoomList()
              ],
            )),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername;
  ChatRoomListTile(this.lastMessage, this.chatRoomId, this.myUsername);

  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", username = "";

  getThisUserInfo() async {
    List<String> splitChatRoomId = widget.chatRoomId.split('_');
    if (splitChatRoomId[0] != widget.myUsername &&
        splitChatRoomId[1] == widget.myUsername) {
      username = splitChatRoomId[0];
    } else if (splitChatRoomId[1] != widget.myUsername &&
        splitChatRoomId[0] == widget.myUsername) {
      username = splitChatRoomId[1];
    }

    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
    if (querySnapshot.docs.isNotEmpty) {
      name = "${querySnapshot.docs[0]["name"]}";
      profilePicUrl = querySnapshot.docs[0]["imgUrl"] ?? '';
      setState(() {});
    }
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name)));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: profilePicUrl.isEmpty
                ? Image.asset(
                    'assets/userProfile.png',
                    height: 30,
                    width: 30,
                  )
                : Image.network(
                    profilePicUrl,
                    height: 30,
                    width: 30,
                  ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 3),
              Text(widget.lastMessage)
            ],
          )
        ],
      ),
    );
  }
}
