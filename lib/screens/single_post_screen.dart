import 'package:flutter/material.dart';
import 'package:instagram_flutter/utils/colors.dart';

class SinglePostScreen extends StatefulWidget {
  const SinglePostScreen({ Key? key }) : super(key: key);

  @override
  _SinglePostScreenState createState() => _SinglePostScreenState();
}

class _SinglePostScreenState extends State<SinglePostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        title: const Text('Post'),
        centerTitle: false,
        backgroundColor: mobileBackgroundColor,
      ),

    );
  }
}
