import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glam_chat/Models/AdMobService.dart';
import 'package:glam_chat/Pages/MyReferralCodePage.dart';
import 'package:glam_chat/Pages/VerifyReferralCodePage.dart';
import 'package:glam_chat/Widgets/ProgressWidget.dart';
import 'package:glam_chat/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.lightBlue,
        title: Text(
          "Account Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SettingsScreen(),
    );
  }
}





class SettingsScreen extends StatefulWidget {
  @override
  State createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  TextEditingController nicknameEditingController = TextEditingController();
  TextEditingController aboutMeEditingController = TextEditingController();

  SharedPreferences preferences;

  String id = "";
  String nickname = "";
  String aboutMe = "";
  String photoUrl = "";
  List user=[];
  final ams = AdMobService();
  InterstitialAd interstitialAd;

  File imageFileAvatar;
  bool isLoading = true;
  final FocusNode nickNameFocusNode = FocusNode();
  final FocusNode aboutMeFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    interstitialAd = ams.getInterstitialAd();
    interstitialAd.load();
    AdMobService.showHomeBannerAd();
    readDataFromLocal();

  }

  @override
  void dispose() {
    super.dispose();
    interstitialAd.show(
      anchorOffset: 0.0,
      horizontalCenterOffset: 0.0,
      anchorType: AnchorType.bottom,
    );
    AdMobService.hideBannerAd();
  }



  Future readDataFromLocal() async {
    preferences = await SharedPreferences.getInstance();

    id = preferences.getString('id');
    nickname = preferences.getString('nickname');
    aboutMe = preferences.getString('aboutMe');
    photoUrl = preferences.getString('photoUrl');

    nicknameEditingController = TextEditingController(text: nickname);
    aboutMeEditingController = TextEditingController(text: aboutMe);
    getUserInfo();
  }

  Future getUserInfo() async{
    final QuerySnapshot snapshot = await Firestore.instance
        .collection('users').where('id', isEqualTo: id).getDocuments();
    setState(() {
      isLoading = false;
      user=snapshot.documents;
    });
  }

  Future getImageFromGallery() async {
    File newImageFile =
        await ImagePicker.pickImage(source: ImageSource.gallery);
    if (newImageFile != null) {
      setState(() {
        this.imageFileAvatar = newImageFile;
        isLoading = true;
      });
    }
    uploadImageToFirestoreAndStorage();
  }

  Future uploadImageToFirestoreAndStorage() async {
    String mFileName = id;
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(mFileName);
    StorageUploadTask storageUploadTask =
        storageReference.putFile(imageFileAvatar);
    StorageTaskSnapshot storageTaskSnapshot;

    storageUploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;

        storageTaskSnapshot.ref.getDownloadURL().then((newImageDownloadUrl) {
          photoUrl = newImageDownloadUrl;
          Firestore.instance.collection("users").document(id).updateData({
            "photoUrl": photoUrl,
          }).then((data) async {
            await preferences.setString("photoUrl", photoUrl);
            setState(() => isLoading = false);
            Fluttertoast.showToast(msg: "Updated Successfully");
          });
        }, onError: (errorMgs) {
          setState(() => isLoading = false);
          Fluttertoast.showToast(msg: "Error getting download url");
        });
      }
    }, onError: (errorMgs) {
      setState(() => isLoading = false);
      Fluttertoast.showToast(msg: errorMgs.toString());
    });
  }

  void updateData() {
    nickNameFocusNode.unfocus();
    aboutMeFocusNode.unfocus();
    setState(() {
      isLoading = false;
    });

    Firestore.instance.collection("users").document(id).updateData({
      "photoUrl": photoUrl,
      "nickname": nickname,
      "aboutMe": aboutMe
    }).then((data) async {
      await preferences.setString("photoUrl", photoUrl);
      await preferences.setString("nickname", nickname);
      await preferences.setString("aboutMe", aboutMe);

      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Updated Successfully");
    });
  }

  @override
  Widget build(BuildContext context) {
    getUserInfo();
    return isLoading? Center(child: CircularProgressIndicator(),) :Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                //Profile Image...
                Container(
                  child: Center(
                    child: Stack(
                      children: [
                        (imageFileAvatar == null)
                            ? (photoUrl !="") //first ternary
                            ? Material(
                          //second ternary
                          //display already existing - old image file...
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor:
                                AlwaysStoppedAnimation<Color>(
                                    Colors.lightBlueAccent),
                              ),
                              width: 200.0,
                              height: 200.0,
                              padding: EdgeInsets.all(20.0),
                            ),
                            imageUrl: photoUrl,
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius:
                          BorderRadius.all(Radius.circular(125.0)),
                          clipBehavior: Clip.hardEdge,
                        )
                            : Icon(
                          Icons.account_circle,
                          size: 200.0,
                          color: Colors.grey,
                        ) //second ternary
                            : Material(
                          //first ternary
                          //display the new updated image here...
                          child: Image.file(
                            imageFileAvatar,
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius:
                          BorderRadius.all(Radius.circular(125.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        IconButton(
                          icon: Icon(Icons.camera_alt,
                              size: 100.0,
                              color: Colors.white54.withOpacity(0.3)),
                          onPressed: getImageFromGallery,
                          padding: EdgeInsets.all(0.0),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.grey,
                          iconSize: 200.0,
                        ),
                      ],
                    ),
                  ),
                  width: double.infinity,
                  margin: EdgeInsets.all(20.0),
                ),

                //Input Fields....
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(1.0),
                      child: isLoading ? circularProgress() : Container(),
                    ),

                    //Username....
                    Container(
                      child: Text(
                        "Profile Name: ",
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlueAccent),
                      ),
                      margin: EdgeInsets.only(left: 30.0, bottom: 5.0, top: 10.0),
                    ),

                    Container(
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(primaryColor: Colors.lightBlueAccent),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "e.g Sujit Kumar Sarkar",
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          controller: nicknameEditingController,
                          onChanged: (value) {
                            nickname = value;
                          },
                          focusNode: nickNameFocusNode,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),

                    //AboutMe - User Bio....
                    Container(
                      child: Text(
                        "About Me: ",
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlueAccent),
                      ),
                      margin: EdgeInsets.only(left: 30.0, bottom: 5.0, top: 30.0),
                    ),

                    Container(
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(primaryColor: Colors.lightBlueAccent),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Biography",
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          controller: aboutMeEditingController,
                          onChanged: (val) {
                            aboutMe = val;
                          },
                          focusNode: aboutMeFocusNode,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                SizedBox(height: 20,),
                Container(
                  child: Text(
                    "Total Shared: ${user[0]['total referral']}",
                    style: TextStyle(
                      fontSize: 18,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w900,
                        color: Colors.blue),
                  ),
                ),
                SizedBox(height: 30,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Update Button....
                    FlatButton(
                      child: Text(
                        "Update",
                        style: TextStyle(fontSize: 16.0),
                      ),
                      onPressed: updateData,
                      color: Colors.lightBlueAccent,
                      splashColor: Colors.white,
                      textColor: Colors.white,
                    ),
                    //Logout Button....
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: FlatButton(
                        color: Colors.red,
                        splashColor: Colors.white,
                        textColor: Colors.white,
                        onPressed: logoutUser,
                        child: Text(
                          "Logout",
                          style: TextStyle(color: Colors.white, fontSize: 14.0),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //My Referral Code....
                    FlatButton(
                      child: Text(
                        "My Referral",
                        style: TextStyle(fontSize: 16.0),
                      ),
                      onPressed:(){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>
                            MyReferralCode(referralCode: id,)));
                      },
                      color: Colors.lightBlueAccent,
                      splashColor: Colors.white,
                      textColor: Colors.white,
                    ),

                    //Verify Referral Code....
                    user[0]['verify referral']=='false'? Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: FlatButton(
                        color: Colors.green,
                        splashColor: Colors.white,
                        textColor: Colors.white,
                        onPressed:(){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>
                              VerifyReferralCode(id: id,)));
                        },
                        child: Text(
                          "Verify Referral",
                          style: TextStyle(color: Colors.white, fontSize: 14.0),
                        ),
                      ),
                    ):Container(),
                  ],
                ),
                SizedBox(height: 70,),
              ],
            ),
          ),
        ],

    );

  }

  Future<Null> logoutUser() async {
    preferences =await SharedPreferences.getInstance();
    preferences.clear();
    aboutMeEditingController.clear();
    nicknameEditingController.clear();

    this.setState(() {
      isLoading = false;
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);
  }
}
