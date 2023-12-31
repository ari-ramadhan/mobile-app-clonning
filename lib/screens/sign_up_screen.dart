import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_flutter/resources/auth_methods.dart';
import 'package:instagram_flutter/responsive/mobile_screen_layout.dart';
import 'package:instagram_flutter/responsive/responsive_layout_screen.dart';
import 'package:instagram_flutter/responsive/web_screen_layout.dart';
import 'package:instagram_flutter/screens/login_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/utils.dart';
import 'package:instagram_flutter/widgets/text_field_input.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().signUpUser(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
        bio: _bioController.text,
        file: _image!);
    setState(() {
      _isLoading = false;
    });
    if (res != 'success') {
      showSnackBar(res, context);
    } else {
      nextScreenReplacement(
          context,
          const ResponsiveLayoutScreen(
              webScreenLayout: WebScreenLayout(),
              mobileScreenLayout: MobileScreenLayout()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
      padding: EdgeInsets.symmetric(horizontal: 32),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(child: Container(), flex: 1),
          // svg image
          SvgPicture.asset(
            'assets/ic_instagram.svg',
            color: primaryColor,
            height: 64,
          ),

          const SizedBox(
            height: 64,
          ),
          Stack(
            children: [
              _image != null
                  ? CircleAvatar(
                      radius: 64, backgroundImage: MemoryImage(_image!))
                  : const CircleAvatar(
                      radius: 64,
                      backgroundImage: NetworkImage(
                          "https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg"),
                    ),
              Positioned(
                  bottom: -10,
                  left: 80,
                  child: IconButton(
                      onPressed: selectImage, icon: Icon(Icons.add_a_photo)))
            ],
          ),
          const SizedBox(
            height: 64,
          ),
          // text field input for username
          TextFieldInput(
              hintText: "Enter your username",
              textInputType: TextInputType.text,
              textEditingController: _usernameController),
          const SizedBox(
            height: 24,
          ),
          // text field input for email
          TextFieldInput(
              hintText: "Enter your email",
              textInputType: TextInputType.emailAddress,
              textEditingController: _emailController),
          const SizedBox(
            height: 24,
          ),
          // text field input for password
          TextFieldInput(
              hintText: "Enter your password",
              textInputType: TextInputType.text,
              textEditingController: _passwordController,
              isPass: true),
          const SizedBox(
            height: 24,
          ),
          // text field input for bio
          TextFieldInput(
              hintText: "Enter your bio",
              textInputType: TextInputType.text,
              textEditingController: _bioController),
          const SizedBox(
            height: 24,
          ),
          // button login
          InkWell(
            onTap: signUpUser,
            child: Container(
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                  color: blueColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4))),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : const Text("Sign up"),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Flexible(child: Container(), flex: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text("Already have an account?"),
              ),
              GestureDetector(
                onTap: () {
                  nextScreenReplacement(context, LoginScreen());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Text(
                    " Sign In.",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          )
          // transitioning  to signing up
        ],
      ),
    )));
  }
}
