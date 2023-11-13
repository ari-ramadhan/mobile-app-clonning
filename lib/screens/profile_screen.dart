import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/resources/auth_methods.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/screens/edit_profile_page.dart';
import 'package:instagram_flutter/screens/find_people_page.dart';
import 'package:instagram_flutter/screens/following_list_screen.dart';
import 'package:instagram_flutter/screens/login_screen.dart';
import 'package:instagram_flutter/screens/saved_post_screen.dart';
import 'package:instagram_flutter/screens/single_post_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/utils.dart';
import 'package:instagram_flutter/widgets/follow_button.dart';
import 'package:instagram_flutter/widgets/my_flutter_app_icons.dart';
import 'package:instagram_flutter/widgets/person_card.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;
  bool showFindPeople = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      // get post length
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      following = userSnap.data()!['following'].length;
      followers = userSnap.data()!['followers'].length;
      postLen = postSnap.docs.length;
      setState(() {
        userData = userSnap.data()!;
      });
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(userData['username']),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20))),
                              height: 200,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    child: Padding(
                                      padding: EdgeInsets.all(13.0),
                                      child: Text(
                                        'Menu',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    leading:
                                        const Icon(Icons.bookmarks_outlined),
                                    title: const Text('Saved'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      nextScreen(context,
                                          SavedPostScreen(uid: widget.uid));
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.logout),
                                    title: const Text('Sign Out'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: const Text(
                                                "Are you sure want to sign out?"),
                                            title: const Text("Confirmation"),
                                            actions: [
                                              ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          elevation: 0,
                                                          backgroundColor:
                                                              Colors.grey[800]),
                                                  onPressed: () {
                                                    AuthMethods().signOut();
                                                    nextScreenReplacement(
                                                        context,
                                                        const LoginScreen());
                                                  },
                                                  child: const Text(
                                                    'Yes',
                                                    style: TextStyle(
                                                        color: Colors.blue),
                                                  )),
                                              ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          elevation: 0,
                                                          backgroundColor:
                                                              Colors.grey[800]),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  )),
                                            ],
                                          );
                                        },
                                      ); //
                                    },
                                  ),
                                ],
                              ));
                        },
                      );
                    },
                    child: const Icon(
                      (MyFlutterApp.align_justify),
                    ),
                  ),
                ],
              ),
              centerTitle: false,
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0 * 2),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(userData['photoUrl']),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(widget.uid)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator(); // Loading spinner saat data dimuat.
                                    }

                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }

                                    if (!snapshot.hasData) {
                                      return Text(
                                          'Tidak ada data.'); // Tampilkan pesan jika tidak ada data.
                                    }

                                    var userData = snapshot.data!.data()
                                        as Map<String, dynamic>;
                                    var followersCount =
                                        userData['followers']?.length ?? 0;
                                    var followingCount =
                                        userData['following']?.length ?? 0;
                                    return Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        buildStatColumn(postLen, "posts"),
                                        InkWell(
                                          onTap: () {
                                            nextScreen(
                                                context,
                                                FollowingListScreen(
                                                  isFollowing: false,
                                                  uid: widget.uid,
                                                ));
                                          },
                                          child: buildStatColumn(
                                              followersCount, "followers"),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            nextScreen(
                                                context,
                                                FollowingListScreen(
                                                  isFollowing: true,
                                                  uid: widget.uid,
                                                ));
                                          },
                                          child: buildStatColumn(
                                              followingCount, "following"),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                // Row(
                                //   mainAxisSize: MainAxisSize.max,
                                //   mainAxisAlignment:
                                //       MainAxisAlignment.spaceEvenly,
                                //   children: [
                                //     buildStatColumn(postLen, "posts"),
                                //     buildStatColumn(followers, "followers"),
                                //     buildStatColumn(following, "following"),
                                //   ],
                                // ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    FirebaseAuth.instance.currentUser!.uid ==
                                            widget.uid
                                        ? Row(children: [
                                            FollowButton(
                                              width: 210,
                                              text: 'Edit Profile',
                                              backgroundColor:
                                                  mobileBackgroundColor,
                                              textColor: primaryColor,
                                              borderColor: Colors.grey,
                                              function: () async {
                                                nextScreen(context,
                                                    const EditProfilePage());
                                              },
                                            ),
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  showFindPeople =
                                                      !showFindPeople;
                                                });
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      color:
                                                          mobileBackgroundColor,
                                                      border: Border.all(
                                                          color: Colors.grey),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: showFindPeople
                                                      ? const Icon(
                                                          Icons.person_add,
                                                          size: 16)
                                                      : const Icon(
                                                          Icons
                                                              .person_add_outlined,
                                                          size: 16)),
                                            )
                                          ])
                                        : isFollowing
                                            ? Row(
                                                children: [
                                                  FollowButton(
                                                    width: 210,
                                                    text: 'Unfollow',
                                                    backgroundColor:
                                                        Colors.white,
                                                    textColor: Colors.black,
                                                    borderColor: Colors.grey,
                                                    function: () async {
                                                      await FirestoreMethods()
                                                          .followUser(
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid,
                                                              userData['uid']);

                                                      setState(() {
                                                        isFollowing = false;
                                                        followers--;
                                                      });
                                                    },
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        showFindPeople =
                                                            !showFindPeople;
                                                      });
                                                    },
                                                    child: Container(
                                                        decoration: BoxDecoration(
                                                            color:
                                                                mobileBackgroundColor,
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                        padding:
                                                            const EdgeInsets.all(
                                                                4.0),
                                                        child: showFindPeople
                                                            ? const Icon(
                                                                Icons
                                                                    .person_add,
                                                                size: 16)
                                                            : const Icon(
                                                                Icons.person_add_outlined,
                                                                size: 16)),
                                                  )
                                                ],
                                              )
                                            : FollowButton(
                                                width: 210,
                                                text: 'Follow',
                                                backgroundColor: Colors.blue,
                                                textColor: Colors.white,
                                                borderColor: Colors.blue,
                                                function: () async {
                                                  await FirestoreMethods()
                                                      .followUser(
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid,
                                                          userData['uid']);
                                                  setState(() {
                                                    isFollowing = true;
                                                    followers++;
                                                  });
                                                },
                                              )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          userData['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          userData['bio'],
                        ),
                      )
                    ],
                  ),
                ),
                showFindPeople
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Find peoples',
                                  style: TextStyle(
                                      letterSpacing: 0.3, fontSize: 15),
                                ),
                                InkWell(
                                  onTap: () => nextScreen(
                                      context,
                                      FindPeoplePage(
                                        uid: widget.uid,
                                      )),
                                  child: const Text(
                                    'Show all',
                                    style: TextStyle(
                                        letterSpacing: 0.3,
                                        fontSize: 15,
                                        color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SingleChildScrollView(
                              padding: const EdgeInsets.all(1.6),
                              scrollDirection: Axis.horizontal,
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Text(
                                          'Error: ${snapshot.error.toString()}'),
                                    );
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return const Text(
                                        'Tidak ada data pengguna.');
                                  }

                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: snapshot.data!.docs.map((doc) {
                                      final userData =
                                          doc.data() as Map<String, dynamic>;
                                      return PersonCard(
                                        profileUid: widget.uid,
                                        snap: userData,
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      )
                    : Container(),
                const Divider(),
                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .where('uid', isEqualTo: widget.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return snapshot.data!.docs.length > 0
                        ? GridView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.docs.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 5,
                                    mainAxisSpacing: 5,
                                    childAspectRatio: 1),
                            itemBuilder: (context, index) {
                              DocumentSnapshot snap =
                                  snapshot.data!.docs[index];

                              return InkWell(
                                onTap: () {
                                  nextScreen(context, SinglePostScreen(postId: snap['postId'],));
                                },
                                child: Container(
                                  child: Image(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(snap['postUrl']),
                                  ),
                                ),
                              );
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 70),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                SizedBox(
                                  height: 100,
                                ),
                                Text(
                                  'Profile',
                                  style: TextStyle(fontSize: 27),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "When you share photos and videos, both will appear on you're profile",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey, height: 1.7),
                                )
                              ],
                            ),
                          );
                  },
                )
              ],
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          label,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w400, color: Colors.grey),
        )
      ],
    );
  }
}

class BottomSheetExample extends StatelessWidget {
  const BottomSheetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: const Text('showModalBottomSheet'),
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: 200,
                color: Colors.amber,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text('Modal BottomSheet'),
                      ElevatedButton(
                        child: const Text('Close BottomSheet'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
