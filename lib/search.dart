import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:movies_app/admob_sevices.dart';
import 'package:movies_app/peopledetails.dart';
import 'package:movies_app/tvshowdetails.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'details.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchData extends StatefulWidget {
  const SearchData({Key key, this.tmdbwithcustomlogs}) : super(key: key);
  final TMDB tmdbwithcustomlogs;

  @override
  _SearchDataState createState() => _SearchDataState();
}

class _SearchDataState extends State<SearchData> {
  TMDB tmdbwithcustomlogs;
  List search = [];
  Map searchResult;
  bool _inputEntered = false;
  TextEditingController _controller = TextEditingController();
  ScrollController _searchScrollController = ScrollController();
  @override
  void initState() {
    creatInterstitialAd();
    tmdbwithcustomlogs = widget.tmdbwithcustomlogs;
    if (pageIndex < maxPageIndex) {
      _searchScrollController.addListener(() {
        if (_searchScrollController.position.pixels ==
            _searchScrollController.position.maxScrollExtent) {
          setState(() {
            getMoreData();
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

  int pageIndex = 2;
  int maxPageIndex = 2;

  getMoreData() async {
    Map newData = await tmdbwithcustomlogs.v3.search
        .queryMulti(_controller.text, page: pageIndex);
    List newNextData = newData['results'];
    for (int i = 0; i < newNextData.length; i++) search.add(newData[i]);

    pageIndex++;
    setState(() {});
  }

  Future getData() async {
    searchResult =
        await tmdbwithcustomlogs.v3.search.queryMulti(_controller.text);
    search = searchResult['results'];
    maxPageIndex = searchResult['total_pages'];
    print(search.length);
    return search;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          title: TextField(
            onSubmitted: (_) {
              _inputEntered = true;
              setState(() {});
            },
            controller: _controller,
            autofocus: true,
            style: GoogleFonts.oswald(color: Colors.black87),
            decoration: InputDecoration(
                hintText: 'Search for Movies, TV Shows, People',
                hintStyle: GoogleFonts.oswald(color: Colors.black45)),
          ),
          backgroundColor: Colors.white,
          actions: [
            IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                onPressed: () {
                  _inputEntered = true;
                  setState(() {});
                  //getData();
                })
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                  future: getData(),
                  builder: (builder, snapshot) {
                    if (_inputEntered == true) {
                      if (snapshot.data == null) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: StaggeredGridView.countBuilder(
                                physics: BouncingScrollPhysics(),
                                staggeredTileBuilder: (index) =>
                                    StaggeredTile.fit(1),
                                crossAxisCount: 3,
                                controller: _searchScrollController,
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                                itemCount: snapshot.data.length,
                                shrinkWrap: false,
                                itemBuilder: (builder, index) {
                                  return snapshot.data[index]['poster_path'] !=
                                          null
                                      ? InkWell(
                                          onTap: () {
                                            if (index % 4 == 0) {
                                              showInterstitialAd();
                                            }
                                            if (snapshot.data[index]
                                                    ['media_type'] ==
                                                'movie') {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MoviesDetails(
                                                            tmdbwithcustomlogs:
                                                                tmdbwithcustomlogs,
                                                            backdrop_path: snapshot
                                                                    .data[index]
                                                                [
                                                                'backdrop_path'],
                                                            id: snapshot
                                                                    .data[index]
                                                                ['id'],
                                                            poster_path: snapshot
                                                                    .data[index]
                                                                ['poster_path'],
                                                            title: snapshot
                                                                    .data[index]
                                                                ['title'],
                                                          )));
                                            }
                                            if (snapshot.data[index]
                                                    ['media_type'] ==
                                                'tv') {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          tvShowDetails(
                                                            tmdbwithcustomlogs:
                                                                tmdbwithcustomlogs,
                                                            backdrop_path: snapshot
                                                                    .data[index]
                                                                [
                                                                'backdrop_path'],
                                                            id: snapshot
                                                                    .data[index]
                                                                ['id'],
                                                            poster_path: snapshot
                                                                    .data[index]
                                                                ['poster_path'],
                                                            title: snapshot
                                                                    .data[index]
                                                                ['name'],
                                                          )));
                                            }
                                            if (snapshot.data[index]
                                                    ['media_type'] ==
                                                'person') {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          peopleDetails(
                                                            tmdbwithcustomlogs:
                                                                tmdbwithcustomlogs,
                                                            id: snapshot
                                                                    .data[index]
                                                                ['id'],
                                                            poster_path: snapshot
                                                                    .data[index]
                                                                [
                                                                'profile_path'],
                                                            title: snapshot
                                                                    .data[index]
                                                                ['name'],
                                                          )));
                                            }
                                          },
                                          child: Container(
                                            height: 190,
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    height: 150,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20)),
                                                        image: DecorationImage(
                                                            fit: BoxFit.fill,
                                                            image: NetworkImage(
                                                                'https://image.tmdb.org/t/p/w500' +
                                                                    snapshot.data[
                                                                            index]
                                                                        [
                                                                        'poster_path']))),
                                                  ),
                                                  Flexible(
                                                    child: Container(
                                                      width: 90,
                                                      child: Text(
                                                        snapshot.data[index][
                                                                    'media_type'] ==
                                                                'movie'
                                                            ? snapshot
                                                                    .data[index]
                                                                ['title']
                                                            : snapshot
                                                                    .data[index]
                                                                ['name'],
                                                        style: GoogleFonts
                                                            .notoSans(
                                                                fontSize: 16),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ))
                                      : Container();
                                }));
                      }
                    } else {
                      return Container();
                    }
                  }),
            ),
            Container(
                height: 50,
                child: AdWidget(
                  ad: AdmobService.createSearchPageBannerAd()..load(),
                )),
          ],
        ),
      ),
    );
  }
}
