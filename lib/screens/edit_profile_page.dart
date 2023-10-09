import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_flutter/main.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/screens/profile_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/utils.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  var userData = {};
  bool _isLoading = false;
  TextEditingController usernameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  Uint8List? _file;

  getData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      setState(() {
        userData = userSnap.data()!;
        usernameController.text = userData['username'];
        bioController.text = userData['bio'];
      });
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  void postImage() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    setState(() {
      _isLoading = true;
    });
    try {
      String res = await FirestoreMethods().changeProfilePict(uid, _file!);
      if (res == "success") {
        setState(() {
          _isLoading = false;
        });
        showSnackBar('Posted Succesfully', context);
        clearImage();
      } else {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(res, context);
      }
    } catch (e) {
      print(e.toString());
      showSnackBar(e.toString(), context);
    }
  }

  _selectImage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Change Profile Picture'),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: Text('Cancel',
                    style: TextStyle(color: Colors.red.shade300)),
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
    usernameController.dispose();
    bioController.dispose();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: mobileBackgroundColor,
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () async {
                  FirestoreMethods().updateUserProfile(userData['uid'],
                      usernameController.text, bioController.text);
                  nextScreenReplacement(
                      context, ProfileScreen(uid: userData['uid']));
                },
                icon: const Icon(
                  Icons.check,
                  color: Colors.blue,
                ))
          ],
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close)),
          backgroundColor: mobileBackgroundColor,
          title: const Text('Edit Profile'),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        _selectImage(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _file == null
                                ? CircleAvatar(
                                    radius: 45,
                                    backgroundColor: Colors.grey,
                                    backgroundImage:
                                        NetworkImage(userData['photoUrl']),
                                  )
                                : CircleAvatar(
                                  radius: 45,
                                  backgroundImage: MemoryImage(_file!),
                                ),
                            const SizedBox(
                              height: 18,
                            ),
                            _file == null ?
                            const Text(
                                  'Edit Photo',
                                  style: TextStyle(color: Colors.blue),
                                ):
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Edit Photo',
                                  style: TextStyle(color: Colors.blue),
                                ),
                                const SizedBox(width: 10,),
                                ElevatedButton(onPressed: (){
                                  postImage();
                                  nextScreen(context, MyApp());
                                }, child: const Text('Change'))

                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                          labelText: 'Username',
                          labelStyle: TextStyle(color: Colors.white)),
                    ),
                    TextFormField(
                      controller: bioController,
                      decoration: const InputDecoration(
                          labelText: 'Bio',
                          labelStyle: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ));
  }
}
