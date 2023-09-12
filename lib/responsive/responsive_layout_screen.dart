import 'package:flutter/material.dart';
import 'package:instagram_flutter/providers/user_provider.dart';
import 'package:instagram_flutter/utils/global_variable.dart';
import 'package:provider/provider.dart';

class ResponsiveLayoutScreen extends StatefulWidget {
  final Widget webScreenLayout;
  final Widget mobileScreenLayout;

const ResponsiveLayoutScreen({ Key? key, required this.webScreenLayout, required this.mobileScreenLayout }) : super(key: key);

  @override
  State<ResponsiveLayoutScreen> createState() => _ResponsiveLayoutScreenState();
}

class _ResponsiveLayoutScreenState extends State<ResponsiveLayoutScreen> {

  @override
  void initState() {
    super.initState();
    addData();
  }

  addData () async {
    UserProvider _userProvider = Provider.of(context, listen: false);
    await _userProvider.refreshUser();
  }

  @override
  Widget build(BuildContext context){
    return LayoutBuilder(
      builder: (context, contstraints) {
        if (contstraints.maxWidth >  webScreenSize){
          // web screen
          return widget.webScreenLayout;
        }
        // mobile screen
          return widget.mobileScreenLayout;
      },
    );
  }
}
