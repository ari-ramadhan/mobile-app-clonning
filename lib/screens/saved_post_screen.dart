import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/utils/colors.dart';

class SavedPostScreen extends StatefulWidget {
  final uid;
  const SavedPostScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _SavedPostScreenState createState() => _SavedPostScreenState();
}

class _SavedPostScreenState extends State<SavedPostScreen> {
  List savedPost = [];

  void getPostSaved() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    List data = (snap.data()! as dynamic)['savedPost'];
    setState(() {
      savedPost = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Saved'),
          backgroundColor: mobileBackgroundColor,
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Menampilkan loading saat data sedang dimuat
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error.toString()}');
            }

            if (snapshot.hasData && snapshot.data!.exists) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final savedPosts =
                  (userData['savedPosts'] as List<dynamic>?) ?? [];

              if (savedPosts.isNotEmpty) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .where(FieldPath.documentId, whereIn: savedPosts)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(); // Menampilkan loading saat data sedang dimuat
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error.toString()}');
                    }

                    if (snapshot.hasData) {
                      final savedPostsData = snapshot.data!.docs;

                      // Sekarang Anda memiliki data postingan yang tersimpan dalam savedPostsData
                      // Lanjutkan ke langkah berikutnya untuk menampilkan dalam GridView.builder
                      return GridView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 5,
                                mainAxisSpacing: 5,
                                childAspectRatio: 1),
                        itemBuilder: (context, index) {
                          final post = savedPostsData[index].data()
                              as Map<String, dynamic>;

                          return InkWell(
                            onTap: () {},
                            child: Image(
                              fit: BoxFit.cover,
                              image: NetworkImage(post['postUrl']),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                          child: Text(
                        "No saved posts found.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, height: 1.7),
                      ));
                    }
                  },
                );
              } else {
                return const Center(
                    child: Text(
                  "No saved posts found.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, height: 1.7),
                ));
              }
              // Sekarang Anda memiliki daftar ID postingan yang tersimpan dalam savedPosts
              // Lanjutkan ke langkah berikutnya untuk mengambil data postingan
            } else {
              return const Center(
                  child: Text(
                "No saved posts found.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.7),
              ));
            }
          },
        ));
  }
}
