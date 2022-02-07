import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movies_app/admob_sevices.dart';
import 'package:movies_app/files/MainMoviesPage.dart';
import 'package:movies_app/files/drawer.dart';
import 'package:movies_app/files/globals.dart';
import 'package:movies_app/moviestab.dart';
//import 'package:movies_app/peopledetails.dart';
import 'package:movies_app/peopletab.dart';
import 'package:movies_app/search.dart';
import 'package:movies_app/tvTab.dart';
//import 'package:movies_app/tvshowdetails.dart';
import 'package:tmdb_api/tmdb_api.dart';
//import 'details.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:palette_generator/palette_generator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
//import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AdmobService.initialize();
  MobileAds.instance.initialize();
  FirebaseApp app = await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        backgroundColor: Colors.green,
      ),
      home: MyHomePage(title: 'Movzy Movcy'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final apiKey = 'f79853684e5304bcc8de22d03b62a015';
  final readaccessToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmNzk4NTM2ODRlNTMwNGJjYzhkZTIyZDAzYjYyYTAxNSIsInN1YiI6IjYxMWNjZTlmNTE0YzRhMDA0NjRjYjhhYyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.FJaPAmdZQBrtDXocF_4EKSC5y_Gl1Byjrs84SH0Llzw';

  NativeAd _ad;
  bool _isNativeAdLoaded = false;

  @override
  void initState() {
    //configOneSignel();
    creatMainPageInterstitial();
    //AdmobService().creatMainPageInterstitial();
    TMDB tmdbwithcustomlogs = TMDB(ApiKeys(apiKey, readaccessToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));
    dataobject = tmdbwithcustomlogs;
    globaldataobject = tmdbwithcustomlogs;

    tabs = [
      MoviesTab(tmdbwithcustomlogs: dataobject),
      TvTab(tmdbwithcustomlogs: dataobject),
      PeopleTab(tmdbwithcustomlogs: dataobject),
    ];

    _ad = NativeAd(
      adUnitId: 'ca-app-pub-3940256099942544/2247696110',
      factoryId: 'listTile',
      listener: NativeAdListener(
        onAdLoaded: (_) {
          print('Native ad Loaded');
          setState(
            () {
              _isNativeAdLoaded = true;
            },
          );
        },
        onAdFailedToLoad: (ad, error) {
          //ad.dispose();
          print('NativeAd fauiled to load... $error');
        },
      ),
      request: AdRequest(),
    );

    _ad.load();

    super.initState();
  }

  /* void configOneSignel() {
    OneSignal.shared.setAppId('bcd33267-b08f-4e65-96fd-e60ec318da9d');
  } */

  InterstitialAd _interstitialad;

  int num_of_attempt_load = 0;

  void creatMainPageInterstitial() {
    print('in adload function');
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/1033173712'
            : 'ca-app-pub-9826383179102622/5881383690',
        request: AdRequest(),
        adLoadCallback:
            InterstitialAdLoadCallback(onAdLoaded: (InterstitialAd ad) {
          print('ad loaded');
          print('add ${ad.hashCode}');
          _interstitialad = ad;
          print('inter ${this._interstitialad.hashCode}');
          num_of_attempt_load = 0;
        }, onAdFailedToLoad: (LoadAdError error) {
          print('ad failed to load');
          num_of_attempt_load++;
          this._interstitialad = null;
          if (num_of_attempt_load <= 2) {
            creatMainPageInterstitial();
          }
        }));
  }

  void showMainPageInterstitial() {
    print('in show function');
    if (this._interstitialad == null) {
      print('inter ${this._interstitialad.hashCode}');
      print('back');
      return;
    }
    _interstitialad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
      print('Ad Closed');
      SystemNavigator.pop();
      ad.dispose();
    }, onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
      print('ad failed to show');
      ad.dispose();
      creatMainPageInterstitial();
    }, onAdShowedFullScreenContent: (_) {
      print('ad showing');
    });
    _interstitialad.show();
    //_interstitialad = null;
  }

  Future<bool> _backPress() {
    showMainPageInterstitial();
  }

  TMDB dataobject;

  int _nevigationIndex = 0;

  var tabs = [];
  var mainPage = [];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _backPress,
      child: Scaffold(
        drawer: ApplicationDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            'Movies',
            style: GoogleFonts.notoSans(),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.search,
                size: 30,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SearchData(
                          tmdbwithcustomlogs: dataobject,
                        )));
              },
            ),
            SizedBox(
              width: 8,
            )
          ],
        ),
        body: MainMoviesPage(
          tmdbwithcustomlogs: dataobject,
        ),
      ),
    );
  }
}
