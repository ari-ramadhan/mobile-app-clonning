import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/screens/profile_screen.dart';
import 'package:instagram_flutter/screens/single_post_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/global_variable.dart';
import 'package:instagram_flutter/utils/utils.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          title: TextFormField(
            onChanged: (value) {},
            onFieldSubmitted: (String _) {
              setState(() {
                isShowUsers = true;
              });
            },
            controller: searchController,
            decoration: const InputDecoration(labelText: 'Search for an user'),
          ),
        ),
        body: isShowUsers
            ? FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where('username',
                        isGreaterThanOrEqualTo: searchController.text)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => nextScreen(
                            context,
                            ProfileScreen(
                                uid: snapshot.data!.docs[index]['uid'])),
                        child: ListTile(
                          title: Text(snapshot.data!.docs[index]['username']),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                snapshot.data!.docs[index]['photoUrl']),
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            : FutureBuilder(
                future: FirebaseFirestore.instance.collection('posts').get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return StaggeredGridView.countBuilder(
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      staggeredTileBuilder: (index) => width > webScreenSize
                          ? StaggeredTile.count((index % 7 == 0) ? 1 : 1,
                              (index % 7 == 0) ? 1 : 1)
                          : StaggeredTile.count((index % 7 == 0) ? 2 : 1,
                              (index % 7 == 0) ? 2 : 1),
                      crossAxisCount: 3,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) => InkWell(
                            onTap: () {
                              nextScreen(
                                  context,
                                  SinglePostScreen(
                                    appBarTitle: 'Discover',
                                      postId: snapshot.data!.docs[index]
                                          ['postId']));
                            },
                            child: Image.network(
                              snapshot.data!.docs[index]['postUrl'],
                              fit: BoxFit.cover,
                            ),
                          ));
                },
              ));
  }
}
