import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
    hintText: 'Phone Number',
    fillColor: Colors.white,
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(50)),
      borderSide: BorderSide(
        color: Colors.deepPurple,
        width: 1.0,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(50)),
      borderSide: BorderSide(
        color: Colors.deepPurple,
        width: 1.0,
      ),
    ),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(50)),
        borderSide: BorderSide(
          color: Colors.redAccent,
          width: 1.0,
        )),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(50)),
      borderSide: BorderSide(
        color: Colors.redAccent,
        width: 1.0,
      ),
    ),
    prefixIcon: Icon(Icons.phone,)
);