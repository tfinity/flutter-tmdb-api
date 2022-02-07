import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:movies_app/tvshowdetails.dart';
import 'package:tmdb_api/tmdb_api.dart';

class TvTab extends StatefulWidget {
  const TvTab(
      {Key key, this.tmdbwithcustomlogs, this.showIndex, this.headTitle})
      : super(key: key);
  final TMDB tmdbwithcustomlogs;
  final int showIndex;
  final String headTitle;

  @override
  _TvTabState createState() => _TvTabState();
}

class _TvTabState extends State<TvTab> {
  TMDB tmdbwithcustomlogs;
  int showIndex = 0;
  List Tv = [];
  ScrollController _tvScrollController = ScrollController();
  @override
  void initState() {
    creatInterstitialAd();
    tmdbwithcustomlogs = widget.tmdbwithcustomlogs;
    showIndex = widget.showIndex;
    tvShowData();
    if (maxTvIndex > tvIndex) {
      _tvScrollController.addListener(() {
        if (_tvScrollController.position.pixels ==
            _tvScrollController.position.maxScrollExtent) {
          setState(() {
            getMoreTv();
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

  int tvIndex = 2;
  int maxTvIndex = 3;

  getMoreTv() async {
    Map trendingTv;
    switch (showIndex) {
      case 0:
        trendingTv = await tmdbwithcustomlogs.v3.tv.getOnTheAir(page: tvIndex);
        break;
      case 1:
        trendingTv = await tmdbwithcustomlogs.v3.tv.getPouplar(page: tvIndex);
        break;
      case 2:
        trendingTv =
            await tmdbwithcustomlogs.v3.tv.getAiringToday(page: tvIndex);
        break;
      case 3:
        trendingTv = await tmdbwithcustomlogs.v3.tv.getTopRated(page: tvIndex);
        break;
      default:
    }
    List newTv = trendingTv['results'];
    maxTvIndex = trendingTv['total_pages'];
    //print(newMovies.length);
    for (int i = 0; i < newTv.length; i++) {
      Tv.add(newTv[i]);
    }
    tvIndex++;
    setState(() {});
  }

  tvShowData() async {
    Map trendingTv;
    switch (showIndex) {
      case 0:
        trendingTv = await tmdbwithcustomlogs.v3.tv.getOnTheAir();
        break;
      case 1:
        trendingTv = await tmdbwithcustomlogs.v3.tv.getPouplar();
        break;
      case 2:
        trendingTv = await tmdbwithcustomlogs.v3.tv.getAiringToday();
        break;
      case 3:
        trendingTv = await tmdbwithcustomlogs.v3.tv.getTopRated();
        break;
      default:
    }
    Tv = trendingTv['results'];
    setState(() {});
    return Tv;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.headTitle,
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
              controller: _tvScrollController,
              crossAxisCount: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              itemCount: Tv.length + 2,
              shrinkWrap: false,
              itemBuilder: (builder, index) {
                if (index == Tv.length ||
                    Tv.isEmpty ||
                    index == Tv.length + 1) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else
                  return Tv[index]['poster_path'] != null
                      ? InkWell(
                          onTap: () {
                            if (index % 4 == 0) {
                              showInterstitialAd();
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => tvShowDetails(
                                  tmdbwithcustomlogs: tmdbwithcustomlogs,
                                  backdrop_path: Tv[index]['backdrop_path'],
                                  id: Tv[index]['id'],
                                  poster_path: Tv[index]['poster_path'],
                                  title: Tv[index]['name'],
                                  hero: 2,
                                ),
                              ),
                            );
                          },
                          child: Hero(
                            tag: Tv[index]['poster_path'] ?? '',
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
                                          image: Tv[index]['poster_path'] !=
                                                  null
                                              ? NetworkImage(
                                                  'https://image.tmdb.org/t/p/w500' +
                                                      Tv[index]['poster_path'])
                                              : AssetImage(
                                                  'assets/loading.gif'),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        width: 90,
                                        child: Text(
                                          Tv[index]['name'] != null
                                              ? Tv[index]['name']
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
