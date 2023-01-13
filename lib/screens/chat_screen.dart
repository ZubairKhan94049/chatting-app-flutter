import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';

late User logedInUser;
class ChatScreen extends StatefulWidget {
  static const id = "chat_screen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final fireStore = FirebaseFirestore.instance.collection("usermessages");
  final msgTextController = TextEditingController();
  late String messageText;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        logedInUser = user;
        print(logedInUser.email);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('usermessages').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 20.0),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: snapshot.data!.docs.length + 1,
                        itemBuilder: (context, index) {
                          if (index == snapshot.data!.docs.length) {
                            return Container(
                              height: 100.0,
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MessageBuble(
                                sender: snapshot.data!.docs[index]['sender']
                                    .toString(),
                                msgTxt: snapshot.data!.docs[index]['text']
                                    .toString(),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                }
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: TextField(
                        controller: msgTextController,
                        onChanged: (value) {
                          messageText = value;
                        },
                        decoration: kMessageTextFieldDecoration.copyWith(
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                      msgTextController.clear();
                      String id =
                          DateTime.now().millisecondsSinceEpoch.toString();
                      fireStore.doc(id).set(
                          {'sender': logedInUser.email, 'text': messageText});
                    },
                    child: Icon(
                      Icons.send,
                      size: 50.0,
                    ),
                    // child: Text(
                    //   'Send',
                    //   style: kSendButtonTextStyle,
                    // ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBuble extends StatelessWidget {
  final String sender;
  final String msgTxt;
  MessageBuble({required this.sender, required this.msgTxt});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: logedInUser.email == sender
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          sender,
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
        Material(
          elevation: 10,
          borderRadius: logedInUser.email == sender
              ? const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                )
              : const BorderRadius.only(
                  topRight: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
          color: logedInUser.email == sender
              ? Colors.lightBlueAccent
              : Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            child: Text(
              "${msgTxt}",
              style: TextStyle(
                color:
                    logedInUser.email == sender ? Colors.white : Colors.black,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
