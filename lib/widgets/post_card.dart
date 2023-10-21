import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/models/user.dart' as model;
import 'package:instagram_flutter/providers/user_provider.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/screens/comments_screen.dart';
import 'package:instagram_flutter/screens/like_screen.dart';
import 'package:instagram_flutter/screens/profile_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/global_variable.dart';
import 'package:instagram_flutter/utils/utils.dart';
import 'package:instagram_flutter/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({Key? key, required this.snap}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  int commentLen = 0;

  @override
  void initState() {
    super.initState();
    getComments();
  }

  void getComments() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color:
                width > webScreenSize ? secondaryColor : mobileBackgroundColor),
        color: mobileBackgroundColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          //HEADER SECTION
          InkWell(
            onTap: () =>
                nextScreen(context, ProfileScreen(uid: widget.snap['uid'])),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
                  .copyWith(right: 0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(widget.snap['profImage']),
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.snap['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  )),
                  widget.snap['uid'] != FirebaseAuth.instance.currentUser!.uid
                      ? StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
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

                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return const Text('Current user does not exist.');
                            }

                            final currentUserData =
                                snapshot.data!.data() as Map<String, dynamic>;
                            final isFollowing = currentUserData['following']
                                .contains(widget.snap['uid']);

                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  side: isFollowing
                                      ? const BorderSide(
                                          width: 0.3, color: Colors.white)
                                      : null,
                                  backgroundColor:
                                      isFollowing ? Colors.black : Colors.blue),
                              onPressed: () async {
                                if (isFollowing) {
                                  await FirestoreMethods().followUser(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      widget.snap['uid']);
                                } else {
                                  await FirestoreMethods().followUser(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      widget.snap['uid']);
                                }
                              },
                              child: Text(isFollowing ? 'Followed' : 'Follow'),
                            );
                          },
                        )
                      : Container(),
                  IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => Dialog(
                                  child: ListView(
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      children: [
                                        'Delete',
                                      ]
                                          .map((e) => InkWell(
                                                onTap: () async {
                                                  FirestoreMethods().deletePost(
                                                      widget.snap['postId']);
                                                  Navigator.of(context).pop();
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 12,
                                                    horizontal: 16,
                                                  ),
                                                  child: Text(e),
                                                ),
                                              ))
                                          .toList()),
                                ));
                      },
                      icon: const Icon(Icons.more_vert))
                ],
              ),
            ),
          ),

          //IMAGE SECTION
          GestureDetector(
            onDoubleTap: () async {
              await FirestoreMethods().likePost(
                  widget.snap['postId'], user.uid, widget.snap['likes']);
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child:
                      Image.network(widget.snap['postUrl'], fit: BoxFit.cover),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimating,
                    duration: const Duration(milliseconds: 400),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                    child: const Icon(Icons.favorite,
                        color: Colors.white, size: 120),
                  ),
                )
              ],
            ),
          ),

          // LIKE COMMENT SECTION
          Row(
            children: [
              LikeAnimation(
                  isAnimating: widget.snap['likes'].contains(user.uid),
                  smallLike: true,
                  child: IconButton(
                      onPressed: () async {
                        await FirestoreMethods().likePost(widget.snap['postId'],
                            user.uid, widget.snap['likes']);
                      },
                      icon: widget.snap['likes'].contains(user.uid)
                          ? const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            )
                          : const Icon(Icons.favorite_border))),
              IconButton(
                  onPressed: () {
                    nextScreen(
                        context,
                        CommentsScreen(
                          snap: widget.snap,
                        ));
                  },
                  icon: const Icon(
                    Icons.comment_outlined,
                  )),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.send,
                  )),
              Expanded(
                  child: Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                    onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
              ))
            ],
          ),

          // DESCRIPTION AND NUMBER OF COMMENTS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(fontWeight: FontWeight.w800),
                  child: InkWell(
                    onTap: () {
                      nextScreen(
                          context,
                          LikeScreen(
                            snap: widget.snap,
                          ));
                    },
                    child: Text(
                      widget.snap['likes'].length > 0
                          ? "${widget.snap['likes'].length} likes"
                          : "no likes",
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8),
                  child: RichText(
                      text: TextSpan(
                          style: const TextStyle(color: primaryColor),
                          children: [
                        TextSpan(
                            text: widget.snap['username'],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                          text: ' ${widget.snap['description']}',
                        )
                      ])),
                ),
                InkWell(
                  onTap: () {
                    nextScreen(context, CommentsScreen(snap: widget.snap));
                  },
                  child: Container(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      commentLen > 0
                          ? 'View all $commentLen comments'
                          : 'No comment recently',
                      style:
                          const TextStyle(fontSize: 16, color: secondaryColor),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 1,
                ),

                // LATEST COMMENT SECTION
                commentLen > 0
                    ? Column(
                        children: [
                          const SizedBox(
                            height: 4,
                          ),
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('posts')
                                .doc(widget.snap['postId'])
                                .collection('comments')
                                .orderBy('datePublished', descending: true)
                                .limit(1)
                                .snapshots(),
                            builder: (context, snapshot) {
                              var snapshit = snapshot.data!.docs[0].data();

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if (snapshot.hasError) {
                                return Text(snapshot.error.toString());
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
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
                                                  text: snapshit['name'],
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(
                                                text: ' ${snapshit['text']}',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                    child: IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.favorite,
                                          size: 13,
                                        )),
                                  )
                                ],
                              );
                            },
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                        ],
                      )
                    : Container(),
                Container(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    DateFormat.yMMMd()
                        .format(widget.snap['datePublished'].toDate()),
                    style: const TextStyle(fontSize: 16, color: secondaryColor),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
