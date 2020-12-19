import 'dart:io';
import 'package:firebase_admob/firebase_admob.dart';

class AdMobService{

  String getAdMobAppId(){
    // if(Platform.isIOS){
    //   return 'ca-app-pub-9704708783911678~7502306685';
    // }
    if(Platform.isAndroid){
      return 'ca-app-pub-7461215501470288~9985710232';
    }
    else{return null;}
  }

  String getRewardAdId() {
    // if(Platform.isIOS){
    //   return 'ca-app-pub-9704708783911678/4601467716';
    // }
    if(Platform.isAndroid){
      //return RewardedVideoAd.testAdUnitId;
      return 'ca-app-pub-7461215501470288/4212678802';
    }
    else{return null;}
  }

  String getInterstitialAdId() {
    if(Platform.isAndroid){
      //return InterstitialAd.testAdUnitId;
      return 'ca-app-pub-7461215501470288/3481619866';
    }
    else{return null;}
  }

  static String getBannerAdId() {
    // if(Platform.isIOS){
    //   return 'ca-app-pub-9704708783911678/2506691379';
    // }
    if(Platform.isAndroid){
      //return BannerAd.testAdUnitId;
      return 'ca-app-pub-7461215501470288/4999641703';
    }
    else{return null;}
  }

  static BannerAd _homeBannerAd;
  static BannerAd _getRewardPageBannerAd(){
    return BannerAd(
      adUnitId: getBannerAdId(),
      size: AdSize.smartBanner,
    );
  }

  static void showHomeBannerAd(){
    if(_homeBannerAd==null){ _homeBannerAd = _getRewardPageBannerAd();}
    _homeBannerAd
      ..load()
      ..show(anchorType: AnchorType.bottom, /**anchorOffset: kBottomNavigationBarHeight**/);
  }

  static void hideBannerAd() async{
    await _homeBannerAd.dispose();
    _homeBannerAd = null;
  }

  InterstitialAd getInterstitialAd(){
    return InterstitialAd(
        adUnitId: getInterstitialAdId(),
        listener: (MobileAdEvent event){
          print("InterstitialAdEvent is: $event");
        }
    );
  }
}
