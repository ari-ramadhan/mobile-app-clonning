import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/models/user.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/screens/like_screen.dart';
import 'package:instagram_flutter/screens/profile_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/utils.dart';
import 'package:instagram_flutter/widgets/comment_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../widgets/like_animation.dart';

class CommentsScreen extends StatefulWidget {
  final snap;
  const CommentsScreen({Key? key, required this.snap}) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool replyMode = false;
  bool isViewReplies = false;

  Set<String> commentsToViewReplies = Set();

  String commentId = '';
  String commentUsername = '';

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('Comments'),
        centerTitle: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.snap['postId'])
            .collection('comments')
            .orderBy('datePublished', descending: false)
            .snapshots(),
        builder: (context, commentSnapshot) {
          if (commentSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          print('tes : ${commentSnapshot.connectionState}');
          print('datanya : ${commentSnapshot.hasData}');
          return ListView.builder(
            itemCount: commentSnapshot.data!.docs.length,
            itemBuilder: (context, index) {
              // return CommentCard(
              //   snap: commentSnapshot.data!.docs[index].data(),
              //   postId: widget.snap['postId'],
              // );
              final snap = commentSnapshot.data!.docs[index].data();
              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => nextScreen(
                              context, ProfileScreen(uid: snap['uid'])),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(snap['profilePic']),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                          text: snap['name'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                        text: ' ${snap['text']}',
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                          DateFormat.yMMMd().format(widget
                                              .snap['datePublished']
                                              .toDate()),
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey[400])),
                                    ),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('posts')
                                          .doc(widget.snap['postId'])
                                          .collection('comments')
                                          .doc(snap['commentId'])
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        }

                                        if (snapshot.hasError) {
                                          return const Text('null');
                                        }

                                        if (!snapshot.hasData) {
                                          return const Text('null1');
                                        }

                                        final userLiked =
                                            snapshot.data!.get('likes') as List;

                                        return InkWell(
                                          onTap: () {
                                            nextScreen(
                                                context,
                                                LikeScreen(
                                                  snap: widget.snap['postId'],
                                                  isCommentLike: true,
                                                  commentId: snap['commentId'],
                                                ));
                                          },
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 2.3),
                                            child: Text(
                                              '${userLiked.length} likes',
                                              style: TextStyle(
                                                  color: Colors.grey[300]),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2.3),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            replyMode = true;
                                            commentId = snap['commentId'];
                                            commentUsername = snap['name'];
                                          });
                                          if (replyMode) {
                                            setState(() {
                                              commentId = snap['commentId'];
                                            });
                                          }
                                        },
                                        child: Text(
                                          'reply',
                                          style: TextStyle(
                                              color: Colors.grey[300]),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8).copyWith(bottom: 0),
                          child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(widget.snap['postId'])
                                  .collection('comments')
                                  .doc(snap['commentId'])
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }

                                if (snapshot.hasError) {
                                  return const Text('null');
                                }

                                if (!snapshot.hasData) {
                                  return const Text('null1');
                                }

                                final userLiked =
                                    snapshot.data!['likes'] as List;

                                return LikeAnimation(
                                    smallLike: true,
                                    isAnimating: userLiked.contains(user.uid),
                                    child: IconButton(
                                        onPressed: () async {
                                          FirestoreMethods().likeComment(
                                              widget.snap['postId'],
                                              snap['commentId'],
                                              user.uid,
                                              snap['likes']);
                                        },
                                        icon: snap['likes'].contains(user.uid)
                                            ? const Icon(
                                                Icons.favorite,
                                                color: Colors.red,
                                                size: 16,
                                              )
                                            : const Icon(
                                                Icons.favorite_border,
                                                size: 16,
                                              )));
                              }),
                        )
                      ],
                    ),

                    //view replies Versi for loop
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .doc(widget.snap['postId'])
                          .collection('comments')
                          .doc(snap['commentId'])
                          .collection('reply')
                          .orderBy("datePublished", descending: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator(); // Loading spinner saat data dimuat.
                        }

                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return  Container();
                        }

                        if (snapshot.data!.docs.length > 0) {
                          final docs = snapshot.data!.docs;

                          return
                              // isViewReplies
                              //     ?
                              Column(
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    // Saat tombol "View Replies" ditekan
                                    setState(() {
                                      if (commentsToViewReplies
                                          .contains(snap['commentId'])) {
                                        commentsToViewReplies
                                            .remove(snap['commentId']);
                                      } else {
                                        commentsToViewReplies.add(snap['commentId']);
                                      }
                                    });
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.only(left: 52),
                                    child: Text(
                                      '---- View ${commentsToViewReplies.contains(snap['commentId']) ? 'Less' : 'All'} ${snapshot.data!.docs.length} replies',
                                      style: TextStyle(color: Colors.grey[400]),
                                    ),
                                  )),
                              commentsToViewReplies.contains(snap['commentId'])
                                  ? Column(
                                    mainAxisSize: MainAxisSize.max,
                                      children: [
                                        for (int i = 0; i < docs.length; i++)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            child: Row(
                                              children: [
                                                const SizedBox(
                                                  width: 50,
                                                ),
                                                CircleAvatar(
                                                  radius: 16,
                                                  backgroundImage: NetworkImage(
                                                      docs[i].data()[
                                                          'profilePic']),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20),
                                                  child: Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        RichText(
                                                          text: TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                  text: docs[i]
                                                                          .data()[
                                                                      'name'],
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                              TextSpan(
                                                                text:
                                                                    ' ${docs[i].data()['text']}',
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 4),
                                                              child: Text(
                                                                  DateFormat
                                                                          .yMMMd()
                                                                      .format(docs[
                                                                              i]
                                                                          .data()[
                                                                              'datePublished']
                                                                          .toDate()),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: Colors
                                                                              .grey[
                                                                          400])),
                                                            ),
                                                            const SizedBox(
                                                              width: 12,
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                      ],
                                    )
                                  : Container()
                            ],
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: replyMode
          ? Container(
              width: kToolbarHeight,
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    // height: double.minPositive,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Replying $commentUsername'),
                        GestureDetector(
                            onTap: () {
                              setState(() {
                                replyMode = false;
                                commentId = '';
                                commentUsername = '';
                              });
                            },
                            child: const Icon(Icons.close))
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(user.photoUrl),
                      ),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                              hintText:
                                  'Reply this comment as ${user.username}',
                              border: InputBorder.none),
                        ),
                      )),
                      InkWell(
                        onTap: () async {
                          await FirestoreMethods().replyComments(
                              user.uid,
                              widget.snap['postId'],
                              commentId,
                              _commentController.text,
                              user.photoUrl,
                              user.username);
                          setState(() {
                            _commentController.clear();
                          });
                        },
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: const Text(
                              'Post',
                              style: TextStyle(color: Colors.blueAccent),
                            )),
                      )
                    ],
                  ),
                ],
              ),
            )
          : Container(
              width: kToolbarHeight,
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user.photoUrl),
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                          hintText: replyMode
                              ? 'Reply this comment as ${user.username}'
                              : 'Comment as ${user.username}',
                          border: InputBorder.none),
                    ),
                  )),
                  InkWell(
                    onTap: () async {
                      replyMode
                          ? await FirestoreMethods().replyComments(
                              user.uid,
                              widget.snap['postId'],
                              commentId,
                              _commentController.text,
                              user.photoUrl,
                              user.username)
                          : await FirestoreMethods().postComment(
                              widget.snap['postId'],
                              _commentController.text,
                              user.uid,
                              user.username,
                              user.photoUrl);
                      setState(() {
                        _commentController.clear();
                        if (replyMode) {
                          replyMode = false;
                          commentId = '';
                          commentUsername = '';
                        }
                      });
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: const Text(
                          'Post',
                          style: TextStyle(color: Colors.blueAccent),
                        )),
                  )
                ],
              ),
            ),
    );
  }
}
