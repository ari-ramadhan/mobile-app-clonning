import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/screens/profile_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/utils.dart';

class FollowingListScreen extends StatefulWidget {
  final String uid;
  final bool isFollowing;
  const FollowingListScreen(
      {Key? key, required this.uid, required this.isFollowing})
      : super(key: key);

  @override
  _FollowingListScreenState createState() => _FollowingListScreenState();
}

class _FollowingListScreenState extends State<FollowingListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: widget.isFollowing ? Text('Following') : Text('Followers'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
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

          final userFollowed = snapshot
              .data![widget.isFollowing ? 'following' : 'followers'] as dynamic;

          return ListView.builder(
            itemCount: userFollowed.length,
            itemBuilder: (context, index) {
              return snapshot.hasData
                  ? FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(userFollowed[index])
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
                            backgroundImage: NetworkImage(userData['photoUrl']),
                          ),
                          title: Text(userData['username']),
                        );
                      },
                    )
                  : Center(
                      child: Text(widget.isFollowing
                          ? 'You are not following anyone currently'
                          : 'There is no followers recently'),
                    );
            },
          );
        },
      ),
    );
  }
}
