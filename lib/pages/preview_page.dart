import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';

class PreviewPage extends StatelessWidget {
  final String path;

  PreviewPage({Key key, this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.w),
        child: AppBar(
          brightness: Brightness.light,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 1,
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text(
            'Preview',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 16.w,
            ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        color: Colors.white,
        child: SafeArea(
          child: Container(
              width: double.infinity,
              height: double.infinity,
              child: PhotoView(
                imageProvider: FileImage(File(path)),
              )
          ),
        ),
      ),
    );
  }
}

