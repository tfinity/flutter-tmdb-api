import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:movies_app/peopledetails.dart';
import 'package:movies_app/tvshowdetails.dart';
import 'package:tmdb_api/tmdb_api.dart';

class PeopleTab extends StatefulWidget {
  const PeopleTab({Key key, this.tmdbwithcustomlogs, this.headTitle})
      : super(key: key);
  final TMDB tmdbwithcustomlogs;
  final String headTitle;

  @override
  _PeopleTabState createState() => _PeopleTabState();
}

class _PeopleTabState extends State<PeopleTab> {
  TMDB tmdbwithcustomlogs;
  List people = [];
  ScrollController _peopleScrollController = ScrollController();
  @override
  void initState() {
    creatInterstitialAd();
    tmdbwithcustomlogs = widget.tmdbwithcustomlogs;
    PeopleData();
    if (maxPeopleIndex > peopleIndex) {
      _peopleScrollController.addListener(() {
        if (_peopleScrollController.position.pixels ==
            _peopleScrollController.position.maxScrollExtent) {
          setState(() {
            getMorePeople();
          });
        }
      });
    }
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

  int peopleIndex = 2;
  int maxPeopleIndex = 3;

  getMorePeople() async {
    Map peopleMap =
        await tmdbwithcustomlogs.v3.people.getPopular(page: peopleIndex);
    List newPeople = peopleMap['results'];
    //print(newMovies.length);
    for (int i = 0; i < newPeople.length; i++) {
      people.add(newPeople[i]);
    }
    peopleIndex++;
    setState(() {});
  }

  PeopleData() async {
    Map peopleMap = await tmdbwithcustomlogs.v3.people.getPopular();
    people = peopleMap['results'];
    maxPeopleIndex = peopleMap['total_pages'];
    setState(() {});
    return people;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "People",
          style: GoogleFonts.notoSans(),
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      backgroundColor: Colors.black,
      body: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: StaggeredGridView.countBuilder(
              physics: BouncingScrollPhysics(),
              staggeredTileBuilder: (index) => StaggeredTile.fit(1),
              controller: _peopleScrollController,
              crossAxisCount: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              itemCount: people.length + 2,
              shrinkWrap: false,
              itemBuilder: (builder, index) {
                if (index == people.length ||
                    people.isEmpty ||
                    index == people.length + 1) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else
                  return people[index]['profile_path'] != null
                      ? InkWell(
                          onTap: () {
                            if (index % 4 == 0) {
                              showInterstitialAd();
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => peopleDetails(
                                  tmdbwithcustomlogs: tmdbwithcustomlogs,
                                  id: people[index]['id'],
                                  poster_path: people[index]['profile_path'],
                                  title: people[index]['name'],
                                  heroId: people[index]['profile_path'],
                                ),
                              ),
                            );
                          },
                          child: Hero(
                            tag: people[index]['profile_path'],
                            child: Container(
                              height: 190,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        image: DecorationImage(
                                          fit: BoxFit.fill,
                                          image: people[index]
                                                      ['profile_path'] !=
                                                  null
                                              ? NetworkImage(
                                                  'https://image.tmdb.org/t/p/w500' +
                                                      people[index]
                                                          ['profile_path'])
                                              : AssetImage(
                                                  'assets/loading.gif'),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        width: 90,
                                        child: Text(
                                          people[index]['name'] != null
                                              ? people[index]['name']
                                              : '',
                                          style: GoogleFonts.notoSans(
                                              fontSize: 16),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ))
                      : Container();
              })),
    );
  }
}
