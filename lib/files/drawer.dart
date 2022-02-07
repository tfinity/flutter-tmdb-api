import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:movies_app/files/MainTvPage.dart';
import 'package:movies_app/files/globals.dart';
import 'package:movies_app/main.dart';
import 'package:movies_app/peopletab.dart';

class ApplicationDrawer extends StatefulWidget {
  const ApplicationDrawer({Key key, this.selectedIndex}) : super(key: key);
  final int selectedIndex;

  @override
  _ApplicationDrawerState createState() => _ApplicationDrawerState();
}

class _ApplicationDrawerState extends State<ApplicationDrawer> {
  int selectedIndex;
  @override
  void initState() {
    creatInterstitialAd();
    selectedIndex = widget.selectedIndex;
    super.initState();
  }

  InterstitialAd _interstitialad;
  int num_of_attempt_load = 0;

  void creatInterstitialAd() {
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
            creatInterstitialAd();
          }
        }));
  }

  void showInterstitialAd() {
    print('in show function');
    if (this._interstitialad == null) {
      print('inter ${this._interstitialad.hashCode}');
      print('back');
      return;
    }
    _interstitialad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
      print('Ad Closed');
      ad.dispose();
      creatInterstitialAd();
    }, onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
      print('ad failed to show');
      ad.dispose();
      creatInterstitialAd();
    }, onAdShowedFullScreenContent: (_) {
      print('ad showing');
    });
    _interstitialad.show();
    //_interstitialad = null;
  }

  Widget buildMenuItem(
      {@required String text,
      @required IconData icon,
      VoidCallback onClick,
      bool selected}) {
    return ListTile(
        leading: Icon(icon),
        title: Text(
          text,
          style: GoogleFonts.notoSans(fontSize: 17),
        ),
        onTap: onClick);
  }

  onClicked(BuildContext context, int index) {
    Navigator.of(context).pop();
    switch (index) {
      case 0:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => MyHomePage()));
        break;
      case 1:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => MainTvPage()));
        break;
      case 2:
        showInterstitialAd();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PeopleTab(
                  tmdbwithcustomlogs: globaldataobject,
                )));
        break;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        color: Colors.black,
        child: ListView(
          children: [
            Container(
              color: Colors.black87,
              height: 180,
              child: Center(
                child: Image(
                  image: AssetImage('assets/icon.png'),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            buildMenuItem(
                icon: Icons.movie,
                text: 'Movies',
                onClick: () => onClicked(context, 0)),
            SizedBox(
              height: 10,
            ),
            buildMenuItem(
                icon: Icons.tv,
                text: 'TV Shows',
                onClick: () => onClicked(context, 1)),
            SizedBox(
              height: 10,
            ),
            buildMenuItem(
                icon: Icons.people,
                text: 'People',
                onClick: () => onClicked(context, 2)),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
            ),
            Center(
                child: Container(
              child: Text(
                'Developed By: Tbyte',
                style: GoogleFonts.notoSans(),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
