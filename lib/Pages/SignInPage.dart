import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glam_chat/Pages/SignUpPage.dart';
import 'package:glam_chat/Widgets/FormDecoration.dart';
import 'package:glam_chat/Widgets/ProgressWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomePage.dart';

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  bool isLoading = false;
  SharedPreferences preferences;

  final _formKey = GlobalKey<FormState>();
  String errorMgs="";
  String phone,password;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkAlreadyCheckedIn();
  }

  checkAlreadyCheckedIn() async{
    preferences = await SharedPreferences.getInstance();
    String id= preferences.getString('id');
    String password= preferences.getString('password');
    if(!(id==null) && !(password==null)){
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: id)),(route) => false);
    }
    //else{readDataFromLocal();}
  }



  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.lightBlueAccent, Colors.purpleAccent],
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'GlamChat',
                    style: TextStyle(
                        fontSize: 82.0,
                        color: Colors.white,
                        fontFamily: "Signatra"),
                  ),
                  TextFormField(
                    onChanged: (val){phone = val;},
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value.isEmpty ? "Enter Phone Number" : null,
                    decoration: textInputDecoration,
                  ),
                  SizedBox(
                    height: size.height / 45,
                  ),
                  TextFormField(
                    obscureText: true,
                    onChanged: (val){password = val;},
                    keyboardType: TextInputType.text,
                    validator: (value) => value.isEmpty ? "Enter Password" : null,
                    decoration: textInputDecoration.copyWith(
                        hintText: "Password", prefixIcon: Icon(Icons.security)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10,right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("New user? ",style: TextStyle(color: Colors.white,fontSize: size.width/22)),
                        InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> SignUp()));
                          },
                          splashColor: Colors.white,
                          child: Text("register account",style: TextStyle(color: Colors.greenAccent,fontSize: size.width/22),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height / 45,
                  ),
                  InkWell(
                    onTap: (){
                      if(_formKey.currentState.validate()){
                        setState(() {
                          isLoading = true;
                          errorMgs ="";
                        });
                        UserLogin();
                      }
                      else{
                        setState(() {
                          isLoading = false;
                          errorMgs ="";
                        });
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: size.width/2.5,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius:  BorderRadius.all(Radius.circular(50)),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Text("Sign In",style: TextStyle(color: Colors.white,fontSize: size.width/15),),
                    ),
                  ),
                  SizedBox(
                    height: size.height / 45,
                  ),
                  isLoading ? customLoadingBar() : Container(),
                  Container(child: Text(errorMgs,style: TextStyle(color: Colors.white),),)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future UserLogin()async{
    final QuerySnapshot resultQuery = await Firestore.instance
        .collection("users")
        .where("id", isEqualTo: phone)
        .getDocuments();
    List result = resultQuery.documents;

    if(result.length!=0){
      if(result[0]['password']==password){
        //Write data to local....
        await preferences.setString("id", phone);
        await preferences.setString("password", password);
        await preferences.setString("nickname", result[0]['nickname']);
        await preferences.setString("photoUrl", result[0]['photoUrl']);
        await preferences.setString("aboutMe", result[0]['aboutMe']);
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: phone)),(route) => false);
      }
      else{
        setState(() {
          isLoading = false;
          errorMgs = "Wrong password";
        });
      }
    }
    else{
      setState(() {
        isLoading = false;
        errorMgs = "Wrong phone number";
      });
    }
  }
}
