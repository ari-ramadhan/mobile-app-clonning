import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/models/user.dart';
import 'package:instagram_flutter/providers/user_provider.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/screens/like_screen.dart';
import 'package:instagram_flutter/screens/profile_screen.dart';
import 'package:instagram_flutter/utils/utils.dart';
import 'package:instagram_flutter/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentCard extends StatefulWidget {
  final postId;
  final snap;
  const CommentCard({Key? key, required this.snap, required this.postId})
      : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;

    return InkWell(
      onDoubleTap: () {
        FirestoreMethods().likeComment(widget.postId, widget.snap['commentId'],
            user.uid, widget.snap['likes']);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            InkWell(
              onTap: () =>
                  nextScreen(context, ProfileScreen(uid: widget.snap['uid'])),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(widget.snap['profilePic']),
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
                              text: widget.snap['name'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                            text: ' ${widget.snap['text']}',
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                              DateFormat.yMMMd().format(
                                  widget.snap['datePublished'].toDate()),
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[400])),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('posts')
                              .doc(widget.postId)
                              .collection('comments')
                              .doc(widget.snap['commentId'])
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
                                nextScreen(context, LikeScreen(snap: widget.postId, isCommentLike: true, commentId: widget.snap['commentId'],));
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2.3),
                                child: Text(
                                  '${userLiked.length} likes',
                                  style: TextStyle(color: Colors.grey[300]),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2.3),
                          child: InkWell(
                            onTap: () {

                            },
                            child: Text(
                              'reply',
                              style: TextStyle(color: Colors.grey[300]),
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
                      .doc(widget.postId)
                      .collection('comments')
                      .doc(widget.snap['commentId'])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      return const Text('null');
                    }

                    if (!snapshot.hasData) {
                      return const Text('null1');
                    }

                    final userLiked = snapshot.data!['likes'] as List;

                    return LikeAnimation(
                        smallLike: true,
                        isAnimating: userLiked.contains(user.uid),
                        child: IconButton(
                            onPressed: () async {
                              FirestoreMethods().likeComment(
                                  widget.postId,
                                  widget.snap['commentId'],
                                  user.uid,
                                  widget.snap['likes']);
                            },
                            icon: widget.snap['likes'].contains(user.uid)
                                ? const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 16,
                                  )
                                : const Icon(
                                    Icons.favorite_border,
                                    size: 16,
                                  )));

                    // return IconButton(
                    //     onPressed: () async {
                    //       FirestoreMethods().likeComment(
                    //           widget.postId,
                    //           widget.snap['commentId'],
                    //           user.uid,
                    //           widget.snap['likes']);
                    //     },
                    //     icon: const Icon(
                    //       Icons.favorite,
                    //       size: 16,
                    //     ));
                  }),
            )
          ],
        ),
      ),
    );
  }
}
