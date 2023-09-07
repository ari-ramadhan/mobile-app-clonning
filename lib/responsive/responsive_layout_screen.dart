import 'package:flutter/material.dart';
import 'package:instagram_flutter/utils/dimensions.dart';

class ResponsiveLayoutScreen extends StatelessWidget {
  final Widget webScreenLayout;
  final Widget mobileScreenLayout;

const ResponsiveLayoutScreen({ Key? key, required this.webScreenLayout, required this.mobileScreenLayout }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return LayoutBuilder(
      builder: (context, contstraints) {
        if (contstraints.maxWidth >  webScreenSize){
          // web screen
          return webScreenLayout;
        }
        // mobile screen
          return mobileScreenLayout;
      },
    );
  }
}
