import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:glam_chat/Models/AdMobService.dart';

// ignore: must_be_immutable
class VerifyReferralCode extends StatefulWidget {
  String id;
  VerifyReferralCode({this.id});

  @override
  _VerifyReferralCodeState createState() => _VerifyReferralCodeState();
}

class _VerifyReferralCodeState extends State<VerifyReferralCode> {

  final _formKey = GlobalKey<FormState>();
  String toVerifyReferral;
  bool isLoading = false;
  String errorMgs = "";
  final ams = AdMobService();
  InterstitialAd interstitialAd;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    interstitialAd = ams.getInterstitialAd();
    interstitialAd.load();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    interstitialAd.show(
      anchorOffset: 0.0,
      horizontalCenterOffset: 0.0,
      anchorType: AnchorType.bottom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: Colors.white
        ),
        elevation: 0,
        title: Text("Verify Referral Code",style: TextStyle(color: Colors.white),),
      ),
      body: bodyUI(context),
    );
  }

  Widget bodyUI(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.blue[100],
        ),
        margin: EdgeInsets.all(10),
        height: size.height / 2.5,
        width: size.width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Referral Code"
                    ),
                    validator: (val) =>
                    val.isEmpty ? "Enter Referral Code" : null,
                    onChanged: (value) {
                      setState(() => toVerifyReferral = value);
                    },
                  ),
                ),
                SizedBox(height: size.height / 23),
                FlatButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          isLoading = true;
                          errorMgs = "";
                        });
                        verifyReferral();
                      }
                    },
                    color: Colors.blue,
                    splashColor: Colors.white,
                    child: Text(
                      "Verify Code",
                      style: TextStyle(color: Colors.white),
                    )),
                SizedBox(height: size.height / 40),
                isLoading
                    ? CircularProgressIndicator()
                    : Container(
                  child: Text(
                    errorMgs,
                    style: TextStyle(color: Colors.redAccent),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future verifyReferral() async{
    final QuerySnapshot snapshot = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: toVerifyReferral)
        .getDocuments();
    List<DocumentSnapshot> referralUser = snapshot.documents;

    final QuerySnapshot querySnapshot = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: widget.id)
        .getDocuments();
    List<DocumentSnapshot> myself = querySnapshot.documents;

    if(myself[0]['id']!=toVerifyReferral){
      if(referralUser.length!=0){
        if(myself[0]['verify referral']=='false'){
          Firestore.instance.collection('users')
              .document(toVerifyReferral).updateData({
            'total referral': (referralUser[0]['total referral'] + 1),
          }).then((value){
            Firestore.instance.collection('users')
                .document(widget.id).updateData({
              'verify referral': 'true',
            });
            setState(() {
              isLoading = false;
              errorMgs = "";
            });
            ///Show Alert Dialog....
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Successful",
                        style: TextStyle(color: Colors.green),
                        textAlign: TextAlign.center),
                    content: FlatButton(
                      color: Colors.blue,
                      onPressed: () {
                        Navigator.of(context).pop();
                        //Navigator.push(context, MaterialPageRoute(builder: (context)=> Home(userPhone: userPhone,)));
                      },
                      splashColor: Colors.blue[300],
                      child: Text(
                        "Close",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                });
          });
        }
        else {
          setState(() {
            isLoading = false;
            errorMgs = "Verification limit expired";
          });
        }
      }
      else {
        setState(() {
          isLoading = false;
          errorMgs = "Wrong Referral Code";
        });
      }
    }
    else{
      setState(() {
        isLoading = false;
        errorMgs = "Own Referral Code doesn't excepted";
      });
    }
  }
}
