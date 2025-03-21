import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xffFDB624);
const Color kBackgroundColor = Color(0xff868686);
const Color kSecondaryColor = Color(0xff333333);
const Color kTextColor = Colors.white;
const Color kLinkTextColor = Colors.blue;

const Color kDangerColor = Colors.red;
const Color kSuccessColor = Colors.green;
const Color kCaptionColor = Color.fromRGBO(166, 177, 187, 1);

double getMobileMaxWidth(BuildContext context) =>
    MediaQuery.of(context).size.width * .8;
