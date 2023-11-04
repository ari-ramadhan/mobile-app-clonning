import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/screens/profile_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/utils.dart';

class LikeScreen extends StatefulWidget {
  final snap;
  final bool isCommentLike;
  final String commentId;
  const LikeScreen(
      {Key? key,
      required this.snap,
      required this.isCommentLike,
      this.commentId = ''})
      : super(key: key);

  @override
  _LikeScreenState createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen> {
  Future<bool> checkFollowing(String uid) async {
    try {
      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      List following = (snap.data()! as dynamic)['followers'];
      print(following.length);
      if (!following.contains(uid)) {
        print('Tidak ada: $uid');
        return false;
      } else {
        print('ada: $uid');
        return false;
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('Likes'),
        centerTitle: false,
      ),
      body: StreamBuilder(
        stream: widget.isCommentLike
            ? FirebaseFirestore.instance
                .collection('posts')
                .doc(widget.snap)
                .collection('comments')
                .doc(widget.commentId)
                .snapshots()
            : FirebaseFirestore.instance
                .collection('posts')
                .doc(widget.snap['postId'])
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error : ${snapshot.error.toString()}'),
            );
          }

          final userLiked = snapshot.data!['likes'] as dynamic;

          return ListView.builder(
            itemCount: userLiked.length,
            itemBuilder: (context, index) {
              print('jumlah like : ${userLiked.length}');
              return snapshot.hasData
                  ? FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(userLiked[index])
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Text('User does not exist.');
                        }

                        final userData =
                            snapshot.data!.data() as Map<String, dynamic>;

                        return ListTile(
                            onTap: () => nextScreen(
                                context, ProfileScreen(uid: userData['uid'])),
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(userData['photoUrl']),
                            ),
                            title: Text(userData['username']),
                            trailing: FirebaseAuth.instance.currentUser!.uid !=
                                    userData['uid']
                                ? StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }

                                      if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      }

                                      if (!snapshot.hasData ||
                                          !snapshot.data!.exists) {
                                        return const Text(
                                            'Current user does not exist.');
                                      }

                                      final currentUserData = snapshot.data!
                                          .data() as Map<String, dynamic>;
                                      final isFollowing =
                                          currentUserData['following']
                                              .contains(userLiked[index]);

                                      return ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            side: isFollowing
                                                ? const BorderSide(
                                                    width: 0.3,
                                                    color: Colors.white)
                                                : null,
                                            backgroundColor: isFollowing
                                                ? Colors.black
                                                : Colors.blue),
                                        onPressed: () async {
                                          if (isFollowing) {
                                            await FirestoreMethods().followUser(
                                                FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                userData['uid']);
                                          } else {
                                            await FirestoreMethods().followUser(
                                                FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                userData['uid']);
                                          }
                                        },
                                        child: Text(isFollowing
                                            ? 'Followed'
                                            : 'Follow'),
                                      );
                                    },
                                  )
                                : null);
                      },
                    )
                  : Center(
                      child: Text('Not a single person liked this post'),
                    );
            },
          );
        },
      ),
    );
  }
}
