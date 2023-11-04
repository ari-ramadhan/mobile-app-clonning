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
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          print('tes : ${snapshot.connectionState}');
          print('datanya : ${snapshot.hasData}');
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              // return CommentCard(
              //   snap: snapshot.data!.docs[index].data(),
              //   postId: widget.snap['postId'],
              // );
              final snap = snapshot.data!.docs[index].data();
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
                        if (snapshot.data!.docs.length > 0) {
                          final docs = snapshot.data!.docs;

                          return isViewReplies
                              ? Column(
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
                                                  docs[i].data()['profilePic']),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20),
                                              child: Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
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
                                                                  .only(top: 4),
                                                          child: Text(
                                                              DateFormat.yMMMd()
                                                                  .format(docs[
                                                                          i]
                                                                      .data()[
                                                                          'datePublished']
                                                                      .toDate()),
                                                              style: TextStyle(
                                                                  fontSize: 12,
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
                                ) : InkWell(
                                  onTap: () {
                                    setState(() {
                                      isViewReplies = !isViewReplies;
                                    });
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.only(left: 52),
                                    child: Text(
                                      '---- View all ${snapshot.data!.docs.length} replies',
                                      style: TextStyle(color: Colors.grey[400]),
                                    ),
                                  ));
                          // return ListView(
                          //     children: docs.map((doc) {
                          //   final data = doc.data() as Map<String, dynamic>;
                          //   return CircleAvatar(
                          //     backgroundImage: NetworkImage(
                          //         data['profilePic']),
                          //   );
                          // }).toList());

                          // return InkWell(
                          //   onTap: () {},
                          //   child:
                          //   // Container(
                          //   //   width: double.infinity,
                          //   //   padding: EdgeInsets.only(left: 52),
                          //   //   child: Text(
                          //   //     '---- View all ${snapshot.data!.docs.length} replies',
                          //   //     style: TextStyle(color: Colors.grey[400]),
                          //   //   ),
                          //   // ),
                          //   Column(
                          //     children: [
                          //       for ()
                          //       CircleAvatar(
                          //         backgroundImage: NetworkImage(snapshot.data!.docs[0].data()['profilePic']),
                          //       ),
                          //     ],
                          //   )
                          // );
                          // var replyText = snapshot.data!.docs[0].data();
                          // print('tesss : ${replyText['text']}');
                          // return ListView.builder(
                          //   itemBuilder: (context, index) {
                          //     var replies = snapshot.data!.docs[index].data();
                          //     print('tesss : ${replies['text']}');
                          //     return Text(replies['text']);
                          //   },
                          // );

                          return Column(
                            children: [
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.only(left: 52),
                                  child: Text(
                                    '---- View all ${snapshot.data!.docs.length} replies',
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                ),
                              ),
                              ListView.builder(
                                itemBuilder: (context, index) {
                                  var replies = snapshot.data!.docs[index];
                                  return Row(
                                    children: [
                                      InkWell(
                                          child: CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(replies['profilePic']),
                                      ))
                                    ],
                                  );
                                },
                              )
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

      // replyMode
      //     ? Container(
      //       height: double.minPositive,
      //         padding: const EdgeInsets.all(8),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             Text('Replying $commentUsername'),
      //             GestureDetector(
      //                 onTap: () {
      //                   setState(() {
      //                     replyMode = false;
      //                     commentId = '';
      //                     commentUsername = '';
      //                   });
      //                 },
      //                 child: Icon(Icons.close))
      //           ],
      //         ),
      //       )
      //     : Container(),
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
                            child: Icon(Icons.close))
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
