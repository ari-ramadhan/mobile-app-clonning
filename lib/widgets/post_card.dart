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
  const PostCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  int commentLen = 0;
  QuerySnapshot<Map<String, dynamic>>? snapshotComment;
  bool isLoading = false;

  bool isEditMode = false;

  TextEditingController captionEditController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getComments();
    // fetchData();
  }

  void getComments() async {
    setState(() {
      isLoading = true;
    });
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
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    captionEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;

    return Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: width > webScreenSize
                  ? secondaryColor
                  : mobileBackgroundColor),
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
                                return const Text(
                                    'Current user does not exist.');
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
                                    backgroundColor: isFollowing
                                        ? Colors.black
                                        : Colors.blue),
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
                                child:
                                    Text(isFollowing ? 'Followed' : 'Follow'),
                              );
                            },
                          )
                        : Container(),
                    isEditMode
                        ? Container()
                        : IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                      child: FirebaseAuth
                                                  .instance.currentUser!.uid ==
                                              widget.snap['uid']
                                          ? ListView(
                                              shrinkWrap: true,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              children: [
                                                  InkWell(
                                                    onTap: () async {
                                                      Navigator.of(context)
                                                          .pop();
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            content: const Text(
                                                                "Are you sure want to delete this post?"),
                                                            title: const Text(
                                                                "Confirmation"),
                                                            actions: [
                                                              ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                      elevation:
                                                                          0,
                                                                      backgroundColor:
                                                                          Colors.grey[
                                                                              800]),
                                                                  onPressed:
                                                                      () {
                                                                    FirestoreMethods()
                                                                        .deletePost(
                                                                            widget.snap['postId']);
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Yes',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .blue),
                                                                  )),
                                                              ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                      elevation:
                                                                          0,
                                                                      backgroundColor:
                                                                          Colors.grey[
                                                                              800]),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Cancel',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red),
                                                                  )),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        vertical: 12,
                                                        horizontal: 16,
                                                      ),
                                                      child: Text('Delete'),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        isEditMode = true;
                                                        captionEditController
                                                                .text =
                                                            widget.snap[
                                                                'description'];

                                                      });
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          vertical: 12,
                                                          horizontal: 16,
                                                        ),
                                                        child: Text('Edit')),
                                                  )
                                                ])
                                          : ListView(
                                              shrinkWrap: true,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              children: [
                                                InkWell(
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 12,
                                                      horizontal: 16,
                                                    ),
                                                    child:
                                                        const Text('Nothing'),
                                                  ),
                                                )
                                              ],
                                            )));
                            },
                            icon: const Icon(Icons.more_vert))
                  ],
                ),
              ),
            ),

            //IMAGE SECTION
            GestureDetector(
              onDoubleTap: () async {
                if (isEditMode) {
                  await FirestoreMethods().likePost(
                      widget.snap['postId'], user.uid, widget.snap['likes']);
                  setState(() {
                    isLikeAnimating = true;
                  });
                } else {}
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                    width: double.infinity,
                    child: Image.network(widget.snap['postUrl'],
                        fit: BoxFit.cover),
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
            isEditMode
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: captionEditController,
                            decoration: const InputDecoration(
                                hintStyle: TextStyle(fontSize: 14),
                                hintText: 'Type your caption here..'),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                isEditMode = false;
                              });
                            },
                            icon: Icon(Icons.close, color: Colors.red,)),
                        IconButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(widget.snap['postId'])
                                  .update({
                                'description': captionEditController.text
                              }).whenComplete(() {
                                setState(() {
                                  isEditMode = false;
                                });
                              });
                            },
                            icon: Icon(Icons.done, color: Colors.blue,))
                      ],
                    ),
                  )
                : Row(
                    children: [
                      LikeAnimation(
                          isAnimating: widget.snap['likes'].contains(user.uid),
                          smallLike: true,
                          child: IconButton(
                              onPressed: () async {
                                await FirestoreMethods().likePost(
                                    widget.snap['postId'],
                                    user.uid,
                                    widget.snap['likes']);
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
                        // child: StreamBuilder<DocumentSnapshot>(
                        //   stream: FirebaseFirestore.instance
                        //       .collection('users')
                        //       .doc(user.uid)
                        //       .snapshots(),
                        //   builder: (context, snapshot) {
                        //     if (snapshot.connectionState == ConnectionState.waiting) {
                        //       return const CircularProgressIndicator(); // Menampilkan loading saat data sedang dimuat
                        //     }

                        //     if (snapshot.hasError) {
                        //       return Text('Error: ${snapshot.error.toString()}');
                        //     }

                        //     if (snapshot.hasData && snapshot.data!.exists) {
                        //       final userData =
                        //           snapshot.data!.data() as Map<String, dynamic>;
                        //       final savedPosts =
                        //           userData['savedPosts'] as List<dynamic>;

                        //       // Ganti ikon berdasarkan apakah postId ada dalam savedPosts
                        //       final isPostSaved =
                        //           savedPosts.contains(widget.snap['postId']);

                        //       return IconButton(
                        //         icon: Icon(
                        //           isPostSaved
                        //               ? Icons.bookmark
                        //               : Icons.bookmark_border,// Sesuaikan warna sesuai kebutuhan
                        //         ),
                        //         onPressed: () {
                        //           // Tambah atau hapus postId dari savedPosts saat tombol diklik
                        //           if (isPostSaved) {
                        //             savedPosts.remove(widget.snap['postId']);
                        //           } else {
                        //             savedPosts.add(widget.snap['postId']);
                        //           }

                        //           // Perbarui data pengguna di Firestore
                        //           FirebaseFirestore.instance
                        //               .collection('users')
                        //               .doc(user.uid)
                        //               .update({'savedPosts': savedPosts});
                        //         },
                        //       );
                        //     } else {
                        //       return Text('User data not found.');
                        //     }
                        //   },
                        // )
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator(); // Menampilkan loading saat data sedang dimuat
                            }

                            if (snapshot.hasError) {
                              return Text(
                                  'Error: ${snapshot.error.toString()}');
                            }

                            if (snapshot.hasData && snapshot.data!.exists) {
                              final userData =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              final savedPosts =
                                  (userData['savedPosts'] as List<dynamic>?) ??
                                      []; // Periksa apakah field savedPosts ada

                              final isPostSaved =
                                  savedPosts.contains(widget.snap['postId']);

                              return IconButton(
                                icon: Icon(
                                  isPostSaved
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  // color: isPostSaved ? Colors.blue : Colors.black,
                                ),
                                onPressed: () {
                                  // Tambah atau hapus postId dari savedPosts saat tombol diklik
                                  if (isPostSaved) {
                                    savedPosts.remove(widget.snap['postId']);
                                  } else {
                                    savedPosts.add(widget.snap['postId']);
                                  }

                                  // Perbarui data pengguna di Firestore
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.uid)
                                      .update({'savedPosts': savedPosts});
                                },
                              );
                            } else {
                              return Text('User data not found.');
                            }
                          },
                        )

                        // widget.snap['savedPost'].contains(widget.snap['postId']) ? Icon(Icons.bookmark_border) : Icon(Icons.bookmark))
                        ,
                      ))
                    ],
                  ),

            // DESCRIPTION AND NUMBER OF COMMENTS
            isEditMode
                ? Container()
                : Container(
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
                                    isCommentLike: false,
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

                        widget.snap['description'].toString().isNotEmpty
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(top: 8),
                                child: RichText(
                                    text: TextSpan(
                                        style: const TextStyle(
                                            color: primaryColor),
                                        children: [
                                      TextSpan(
                                          text: widget.snap['username'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                        text: ' ${widget.snap['description']}',
                                      )
                                    ])),
                              )
                            : Container(),
                        InkWell(
                          onTap: () {
                            nextScreen(
                                context, CommentsScreen(snap: widget.snap));
                          },
                          child: Container(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              commentLen > 0
                                  ? 'View all $commentLen comments'
                                  : 'No comment recently',
                              style: const TextStyle(color: secondaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 1,
                        ),
                        // commentLen > 0
                        //     ? Column(
                        //         children: [
                        //           const SizedBox(
                        //             height: 4,
                        //           ),
                        //           StreamBuilder(
                        //             stream: FirebaseFirestore.instance
                        //                 .collection('posts')
                        //                 .doc(widget.snap['postId'])
                        //                 .collection('comments')
                        //                 .orderBy('datePublished', descending: true)
                        //                 .limit(1)
                        //                 .snapshots(),
                        //             builder: (context, snapshot) {
                        //               var snapshit = snapshot.data!.docs[0].data();

                        //               if (snapshot.connectionState ==
                        //                   ConnectionState.waiting) {
                        //                 return const Center(child: CircularProgressIndicator());
                        //               }
                        //               if (snapshot.hasError) {
                        //                 return Text(snapshot.error.toString());
                        //               }

                        //               return Row(
                        //                 crossAxisAlignment: CrossAxisAlignment.start,
                        //                 children: [
                        //                   Expanded(
                        //                     child: Column(
                        //                       crossAxisAlignment:
                        //                           CrossAxisAlignment.start,
                        //                       mainAxisAlignment:
                        //                           MainAxisAlignment.center,
                        //                       children: [
                        //                         RichText(
                        //                           text: TextSpan(
                        //                             children: [
                        //                               TextSpan(
                        //                                   text: snapshit['name'],
                        //                                   style: const TextStyle(
                        //                                       fontWeight:
                        //                                           FontWeight.bold)),
                        //                               TextSpan(
                        //                                 text: ' ${snapshit['text']}',
                        //                               ),
                        //                             ],
                        //                           ),
                        //                         ),
                        //                       ],
                        //                     ),
                        //                   ),
                        //                   SizedBox(
                        //                     height: 20,
                        //                     child: IconButton(
                        //                         onPressed: () {},
                        //                         icon: const Icon(
                        //                           Icons.favorite,
                        //                           size: 13,
                        //                         )),
                        //                   )
                        //                 ],
                        //               );
                        //             },
                        //           ),
                        //           const SizedBox(
                        //             height: 4,
                        //           ),
                        //         ],
                        //       )
                        //     : Container(),
                        Container(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            DateFormat.yMMMd()
                                .format(widget.snap['datePublished'].toDate()),
                            style: const TextStyle(
                                fontSize: 14, color: secondaryColor),
                          ),
                        ),
                      ],
                    ),
                  )
          ],
        ));
  }
}
