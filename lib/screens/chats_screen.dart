import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/screens/private_chat_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/utils.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        title: Text('Chats'),
        backgroundColor: mobileBackgroundColor,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data();

              return FirebaseAuth.instance.currentUser!.uid != userData['uid']
                  ? InkWell(
                      onTap: () {
                        nextScreen(
                            context,
                            PrivateChatScreen(
                                uid: userData['uid'],
                                profilePic: userData['photoUrl'],
                                username: userData['username']));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 23,
                              backgroundImage:
                                  NetworkImage(userData['photoUrl']),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(userData['username'])
                          ],
                        ),
                      ),
                    )
                  : Container();
            },
          );
        },
      ),
    );
  }
}
