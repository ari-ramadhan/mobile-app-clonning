import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/screens/profile_screen.dart';
import 'package:instagram_flutter/utils/utils.dart';

class PersonCard extends StatefulWidget {
  // final Map<String, dynamic> userData;
  final snap;
  const PersonCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  _PersonCardState createState() => _PersonCardState();
}

class _PersonCardState extends State<PersonCard> {
  @override
  Widget build(BuildContext context) {
    return widget.snap['uid'] != FirebaseAuth.instance.currentUser!.uid
        ? InkWell(
          onTap: () {
            nextScreen(context, ProfileScreen(uid: widget.snap['uid']));
          },
          child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: MediaQuery.of(context).size.height * 25 / 100,
              width: MediaQuery.of(context).size.width * 35 / 100,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(width: 0.1, color: Colors.white)),
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: CircleAvatar(
                    radius: double.infinity - 30,
                    backgroundImage: NetworkImage(widget.snap['photoUrl']),
                  )),
                  const SizedBox(
                    height: 14,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.snap['username'],
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, letterSpacing: 0.3),
                        ),
                        StreamBuilder(
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

                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
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
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
        )
        : Container();
  }
}
