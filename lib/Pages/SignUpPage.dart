import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glam_chat/Pages/SignInPage.dart';
import 'package:glam_chat/Widgets/FormDecoration.dart';
import 'package:glam_chat/Widgets/ProgressWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  SharedPreferences preferences;
  bool isLoading = false;
  String errorMgs="";

  final _formKey = GlobalKey<FormState>();
  String phone,name,password;

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
                    onChanged: (val){name = val;},
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) =>
                    value.isEmpty ? "Enter Your Name" : null,
                    decoration: textInputDecoration.copyWith(hintText: "Your Name",prefixIcon: Icon(Icons.person)),
                  ),
                  SizedBox(
                    height: size.height / 45,
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
                        Text("Already have an account? ",style: TextStyle(color: Colors.white,fontSize: size.width/22)),
                        InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> LogIn()));
                          },
                          splashColor: Colors.white,
                          child: Text("sign in",style: TextStyle(color: Colors.greenAccent,fontSize: size.width/22),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height / 45,
                  ),
                  InkWell(
                    onTap: () async{
                      if(_formKey.currentState.validate()){
                        setState((){ isLoading=true; errorMgs ="";});
                        final QuerySnapshot resultQuery = await Firestore.instance
                            .collection("users")
                            .where("id", isEqualTo: phone)
                            .getDocuments();
                        final List<DocumentSnapshot> documentSnapshots = resultQuery.documents;
                        if(documentSnapshots.length==0){
                          setState(() {
                            isLoading = true;
                            errorMgs="";
                          });
                          UserSignUp();
                        }
                        else{
                          setState(() {
                            isLoading = false;
                            errorMgs="Phone number already exist";
                          });
                        }
                      }
                    },
                    splashColor: Colors.white,
                    child: Container(
                      alignment: Alignment.center,
                      width: size.width/2.5,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius:  BorderRadius.all(Radius.circular(50)),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Text("Register",style: TextStyle(color: Colors.white,fontSize: size.width/15),),
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

  Future UserSignUp() async{
    preferences = await SharedPreferences.getInstance();

    Firestore.instance
        .collection("users")
        .document(phone)
        .setData({
      "nickname": name,
      "photoUrl": "",
      "id": phone,
      "password": password,
      "aboutMe": "I am a proud user of GlamChat",
      "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
      "chattingWith": null,
      'verify referral': 'false',
      'total referral': 0,
    }).then((value) async{
      //Write data to local....
      await preferences.setString("id", phone);
      await preferences.setString("password", password);
      await preferences.setString("nickname", name);
      await preferences.setString("photoUrl", "");
      await preferences.setString("aboutMe", "I am a proud user of GlamChat");
    }).then((value) {
      Fluttertoast.showToast(msg: "Register Successful");
      Navigator.push(context, MaterialPageRoute(builder: (context)=> LogIn()));
    });
  }
}
