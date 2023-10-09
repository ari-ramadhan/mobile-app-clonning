import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/models/user.dart';
import 'package:instagram_flutter/providers/user_provider.dart';
import 'package:instagram_flutter/screens/profile_screen.dart';
import 'package:instagram_flutter/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentCard extends StatefulWidget {
  final snap;
  const CommentCard({Key? key,required this.snap}) : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  Widget build(BuildContext context) {


    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          InkWell(
            onTap: () => nextScreen(context, ProfileScreen(uid: widget.snap['uid'])),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                  widget.snap['profilePic']),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.snap['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold
                          )
                        ),
                        TextSpan(
                          text: ' ${widget.snap['text']}',
                        ),
                      ],
                    ),
                  ),
                  Padding(padding: const EdgeInsets.only(top: 4), child: Text(DateFormat.yMMMd().format(widget.snap['datePublished'].toDate()), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),)
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8).copyWith(bottom: 0),
            child: IconButton(onPressed: () {}, icon: const Icon(Icons.favorite, size: 16,)),
          )
        ],
      ),
    );
  }
}
