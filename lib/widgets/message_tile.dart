import 'package:flutter/material.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sendByMe;

  const MessageTile(
      {Key? key,
      required this.message,
      required this.sender,
      required this.sendByMe})
      : super(key: key);

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: widget.sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: widget.sendByMe ? 0 : 24,
          right: widget.sendByMe ? 24 : 0),
      child: Container(
        margin: widget.sendByMe
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(right: 30),
        padding:
            const EdgeInsets.only(top: 13, bottom: 13, right: 16, left: 16),
        decoration: BoxDecoration(
            color: widget.sendByMe
                ? Theme.of(context).primaryColor
                : Colors.grey[700],
            borderRadius: widget.sendByMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.message,
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
