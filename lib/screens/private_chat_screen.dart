import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/providers/user_provider.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/widgets/message_tile.dart';
import 'package:instagram_flutter/models/user.dart' as model;
import 'package:provider/provider.dart';

class PrivateChatScreen extends StatefulWidget {
  final uid;
  final profilePic;
  final username;
  const PrivateChatScreen(
      {Key? key,
      required this.profilePic,
      required this.username,
      required this.uid})
      : super(key: key);

  @override
  _PrivateChatScreenState createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  TextEditingController messageController = TextEditingController();

  // Stream? chats;

  @override
  void initState() {
    super.initState();
    // FirestoreMethods()
    //     .getChats(FirebaseAuth.instance.currentUser!.uid, widget.uid)
    //     .then((value) {
    //   setState(() {
    //     chats = value;
    //   });
    // });

    print('${widget.uid} - > receiver');
    print('${FirebaseAuth.instance.currentUser!.uid} - > sender');
  }

  determineUserIndex() async {
    QuerySnapshot snap =
        await FirebaseFirestore.instance.collection('chats').get();

    for (int i = 0; i < snap.size; i++) {}
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Row(
          children: [
            InkWell(
              child: CircleAvatar(
                radius: 15,
                backgroundImage: NetworkImage(widget.profilePic),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              widget.username,
              style: const TextStyle(fontSize: 13),
            )
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chats').snapshots(),
        builder: (context, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Menampilkan loading saat data sedang dimuat
          }

          if (chatSnapshot.hasError) {
            return Text('Error: ${chatSnapshot.error.toString()}');
          }

          if (chatSnapshot.hasData) {
            final chatDocs = chatSnapshot.data!.docs;

            if (chatDocs.isEmpty) {
              return const Center(child: Text('Tidak ada percakapan.'));
            }

            // Temukan percakapan yang sesuai dengan senderId dan receiverId
            QueryDocumentSnapshot<Object?>? matchingChat;

            for (var chatDoc in chatDocs) {
              final data = chatDoc.data() as Map<String, dynamic>;
              final participants = data['participants'] as List<dynamic>;
              if (participants.contains(user.uid) &&
                  participants.contains(widget.uid)) {
                matchingChat = chatDoc;
                break;
              }
            }

            if (matchingChat != null) {
              final chatId = matchingChat.id;

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chatId)
                    .collection('messages')
                    .orderBy('time',
                        descending:
                            false) // Sesuaikan dengan kebutuhan pengurutan
                    .snapshots(),
                builder: (context, messageSnapshot) {
                  if (messageSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (messageSnapshot.hasError) {
                    return Text('Error: ${messageSnapshot.error.toString()}');
                  }

                  if (messageSnapshot.hasData) {
                    final messageDocs = messageSnapshot.data!.docs;
                    return ListView.builder(
                      itemCount: messageDocs.length,
                      itemBuilder: (context, index) {
                        final message =
                            messageDocs[index].data() as Map<String, dynamic>;
                        final senderId = message['sender'];
                        final messageText = message['message'];

                        // Sesuaikan tampilan pesan di sini
                        return MessageTile(
                            message: messageText,
                            sender: senderId,
                            sendByMe: user.uid == message['sender']);
                      },
                    );
                  } else {
                    return const Center(child: Text('Tidak ada pesan.'));
                  }
                },
              );
            } else {
              return const Center(child: Text('Tidak ada percakapan.'));
            }
          } else {
            return const Center(child: Text('Tidak ada percakapan.'));
          }
        },
      ),

      //-------------------------------------------------------------------------
      // StreamBuilder<QuerySnapshot>(
      //   stream: FirebaseFirestore.instance
      //       .collection('chats')
      //       .where('participants', whereIn: [user.uid, widget.uid]).snapshots(),
      //   builder: (context, chatSnapshot) {
      //     if (chatSnapshot.connectionState == ConnectionState.waiting) {
      //       return CircularProgressIndicator(); // Menampilkan loading saat data sedang dimuat
      //     }

      //     if (chatSnapshot.hasError) {
      //       return Text('Error: ${chatSnapshot.error.toString()}');
      //     }

      //     if (chatSnapshot.hasData) {
      //       final chatDocs = chatSnapshot.data!.docs;
      //       if (chatDocs.isEmpty) {
      //         return const Center(child: Text('Tidak ada percakapan.'));
      //       }

      //       final chatId = chatDocs[0].id;

      //       return StreamBuilder<QuerySnapshot>(
      //         stream: FirebaseFirestore.instance
      //             .collection('chats')
      //             .doc(chatId)
      //             .collection('messages')
      //             .orderBy('time',
      //                 descending:
      //                     false) // Sesuaikan dengan kebutuhan pengurutan
      //             .snapshots(),
      //         builder: (context, messageSnapshot) {
      //           if (messageSnapshot.connectionState ==
      //               ConnectionState.waiting) {
      //             return CircularProgressIndicator();
      //           }

      //           if (messageSnapshot.hasError) {
      //             return Text('Error: ${messageSnapshot.error.toString()}');
      //           }

      //           if (messageSnapshot.hasData) {
      //             final messageDocs = messageSnapshot.data!.docs;
      //             return ListView.builder(
      //               itemCount: messageDocs.length,
      //               itemBuilder: (context, index) {
      //                 final message =
      //                     messageDocs[index].data() as Map<String, dynamic>;
      //                 final senderId = message['sender'];
      //                 final messageText = message['message'];

      //                 // Sesuaikan tampilan pesan di sini
      //                 return MessageTile(
      //                     message: messageText,
      //                     sender: senderId,
      //                     sendByMe: user.uid == message['sender']);
      //               },
      //             );
      //           } else {
      //             return Text('Tidak ada pesan.');
      //           }
      //         },
      //       );
      //     } else {
      //       return Text('Tidak ada percakapan.');
      //     }
      //   },
      // ),
      //------------------------------------------------------------------------
      // StreamBuilder(
      //   stream: chats,
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return CircularProgressIndicator();
      //     }

      //     if (snapshot.hasError) {
      //       return Text('Error: ${snapshot.error.toString()}');
      //     }
      //     if (snapshot.hasData){
      //       final messageDocs = snapshot.data.docs;
      //     }
      //     return snapshot.hasData
      //         ? ListView.builder(
      //             itemBuilder: (context, index) {
      //               return MessageTile(
      //                   message: snapshot.data.docs[index]['message'],
      //                   sender: snapshot.data.docs[index]['sender'],
      //                   sendByMe:
      //                       user.uid == snapshot.data.docs[index]['sender']);
      //             },
      //             itemCount: snapshot.data.docs.length,
      //           )
      //         : Container();
      //   },
      // ),
      bottomNavigationBar: Container(
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        width: kToolbarHeight,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: TextField(
                  controller: messageController,
                  decoration: const InputDecoration(hintText: 'Send a message'),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                await FirestoreMethods()
                    .sendChats(FirebaseAuth.instance.currentUser!.uid,
                        widget.uid, messageController.text)
                    .whenComplete(() => messageController.clear());
              },
              child: const Icon(Icons.send_sharp),
            ),
            const SizedBox(
              width: 10,
            )
          ],
        ),
      ),
    );
  }
}
