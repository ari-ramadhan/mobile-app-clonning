import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/providers/user_provider.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/models/user.dart' as model;
import 'package:provider/provider.dart';
import '../resources/firestore_methods.dart';

class FindPeoplePage extends StatefulWidget {
  final uid;
  const FindPeoplePage({Key? key, required this.uid}) : super(key: key);

  @override
  _FindPeoplePageState createState() => _FindPeoplePageState();
}

class _FindPeoplePageState extends State<FindPeoplePage> {
  bool _isLoading = false;

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
    final model.User user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text('Find Peoples'),
      ),
      body:
      // _isLoading
      //     ? const Center(
      //         child: CircularProgressIndicator(),
      //       ) :
            StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final userData = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return userData[index]['uid'] != widget.uid && userData[index]['uid'] != user.uid
                        ? ListTile(
                            title: Text(userData[index]['username']),
                            trailing: StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                // setState(() {
                                //   _isLoading = true;
                                // });
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

                                final currentUserData = snapshot.data!.data()
                                    as Map<String, dynamic>;
                                final isFollowing = currentUserData['following']
                                    .contains(userData[index]['uid']);

                                // setState(() {
                                //   _isLoading = false;
                                // });
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
                                          FirebaseAuth
                                              .instance.currentUser!.uid,
                                          userData[index]['uid']);
                                    } else {
                                      await FirestoreMethods().followUser(
                                          FirebaseAuth
                                              .instance.currentUser!.uid,
                                          userData[index]['uid']);
                                    }
                                  },
                                  child:
                                      Text(isFollowing ? 'Followed' : 'Follow'),
                                );
                              },
                            ),
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(userData[index]['photoUrl']),
                            ),
                          )
                        : Container();
                  },
                );
              },
            ),
    );
  }
}
