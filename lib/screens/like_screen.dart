import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/utils/colors.dart';

class LikeScreen extends StatefulWidget {
  final snap;
  const LikeScreen({Key? key, required this.snap}) : super(key: key);

  @override
  _LikeScreenState createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('Likes'),
        centerTitle: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
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
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userLiked[index])
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
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
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(userData['photoUrl']),
                    ),
                    title: Text(userData['username']),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
