import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:movies_app/admob_sevices.dart';
import 'package:movies_app/details.dart';
import 'package:movies_app/moviestab.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'package:carousel_slider/carousel_slider.dart';

class MainMoviesPage extends StatefulWidget {
  const MainMoviesPage({Key key, this.tmdbwithcustomlogs}) : super(key: key);
  final TMDB tmdbwithcustomlogs;

  @override
  _MainMoviesPageState createState() => _MainMoviesPageState();
}

class _MainMoviesPageState extends State<MainMoviesPage> {
  TMDB tmdbwithcustomlogs;
  List nowShowing = [];
  List popular = [];
  List upcoming = [];
  List trending = [];
  bool _isNativeAdLoaded = false;
  NativeAd _ad;
  @override
  void initState() {
    creatInterstitialAd();
    tmdbwithcustomlogs = widget.tmdbwithcustomlogs;
    getdata();
    if (Platform.isAndroid) {
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

  List data = [];

  getdata() async {
    Map noeShowingdata = await tmdbwithcustomlogs.v3.movies.getNowPlaying();
    nowShowing = noeShowingdata['results'];
    Map populargdata = await tmdbwithcustomlogs.v3.movies.getPouplar();
    popular = populargdata['results'];
    Map upcomimgdata = await tmdbwithcustomlogs.v3.movies.getUpcoming();
    upcoming = upcomimgdata['results'];
    Map trendingdata = await tmdbwithcustomlogs.v3.movies.getTopRated();
    trending = trendingdata['results'];
    Map generData = await tmdbwithcustomlogs.v3.geners.getMovieList();
    data = generData['genres'];

    setState(() {});
  }

  List generlist = [];

  String getGeners(List gener) {
    print(gener);
    generlist.clear();

    for (int x = 0; x < data.length; x++) {
      if (gener.contains(data[x]['id'])) {
        generlist.add(data[x]['name']);
      }
    }
    print(generlist.map((item) => '$item'));
    return generlist.map((item) => '$item').toString();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
      decoration: BoxDecoration(
        color: Colors.black,
        /* gradient: LinearGradient(
          colors: [Colors.purple[800], Colors.white],
          stops: [0.8, 1],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ), */
      ),
      child: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          //Now showing
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Row(
                  children: [
                    Text(
                      'NOW SHOWING',
                      style: GoogleFonts.notoSans(fontSize: 20),
                    ),
                    Expanded(child: SizedBox()),
                    InkWell(
                      onTap: () {
                        showInterstitialAd();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MoviesTab(
                              tmdbwithcustomlogs: tmdbwithcustomlogs,
                              showIndex: 0,
                              headTitle: 'Movies: Now Showing',
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'View All',
                        style: GoogleFonts.notoSans(fontSize: 12),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                //padding: EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
                height: 260,
                child: nowShowing == null
                    ? CircularProgressIndicator()
                    : CarouselSlider.builder(
                        itemCount: nowShowing.length,
                        options: CarouselOptions(
                          scrollPhysics: BouncingScrollPhysics(),
                          enableInfiniteScroll: false,
                          disableCenter: true,
                          viewportFraction: 0.8,
                          enlargeCenterPage: true,
                        ),
                        itemBuilder: (context, item, pageViewIndex) {
                          return InkWell(
                            onTap: () {
                              showInterstitialAd();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MoviesDetails(
                                    tmdbwithcustomlogs: tmdbwithcustomlogs,
                                    backdrop_path: nowShowing[item]
                                        ['backdrop_path'],
                                    id: nowShowing[item]['id'],
                                    poster_path: nowShowing[item]
                                        ['poster_path'],
                                    title: nowShowing[item]['title'],
                                    heroID: nowShowing[item]['backdrop_path'],
                                    hero: 1,
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: nowShowing[item]['backdrop_path'] ??
                                  'invalid',
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 220,
                                      width: 330,
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          Container(
                                            foregroundDecoration: BoxDecoration(
                                                //color: Colors.black45
                                                ),
                                            alignment: Alignment.bottomCenter,
                                            height: 220,
                                            width: 330,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20)),
                                              image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: 'https://image.tmdb.org/t/p/w500' +
                                                            nowShowing[item][
                                                                'backdrop_path'] !=
                                                        null
                                                    ? NetworkImage(
                                                        'https://image.tmdb.org/t/p/w500' +
                                                            nowShowing[item][
                                                                'backdrop_path'],
                                                      )
                                                    : AssetImage(
                                                        'assets/loading.gif'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    /* Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                      getGeners(nowShowing[item]['genre_ids']),
                                      style: GoogleFonts.notoSans()),
                                ), */
                                    Container(
                                      padding: EdgeInsets.only(left: 10),
                                      width: 250,
                                      child: Text(
                                        nowShowing[item]['title'] ?? '',
                                        style: GoogleFonts.notoSans(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                /*ListView.builder(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: nowShowing.length,
                    itemBuilder: (context, item) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MoviesDetails(
                                        tmdbwithcustomlogs: tmdbwithcustomlogs,
                                        backdrop_path: nowShowing[item]
                                            ['backdrop_path'],
                                        id: nowShowing[item]['id'],
                                        poster_path: nowShowing[item]
                                            ['poster_path'],
                                        title: nowShowing[item]['title'],
                                      )));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  height: 220,
                                  width: 330,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Container(
                                          foregroundDecoration: BoxDecoration(
                                              //color: Colors.black45
                                              ),
                                          alignment: Alignment.bottomCenter,
                                          height: 220,
                                          width: 330,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20)),
                                              image: DecorationImage(
                                                  fit: BoxFit.fill,
                                                  image: NetworkImage(
                                                    'https://image.tmdb.org/t/p/w500' +
                                                        nowShowing[item]
                                                            ['backdrop_path'],
                                                  )))),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            width: 250,
                                            child: Text(
                                              nowShowing[item]['title'],
                                              style: GoogleFonts.notoSans(
                                                  fontSize: 20,
                                                  color: Colors.white),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Expanded(child: SizedBox()),
                                          Text(
                                              (nowShowing[item]['vote_average'])
                                                  .toString(),
                                              style: GoogleFonts.notoSans(
                                                  fontSize: 16)),
                                          Icon(
                                            Icons.star,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          SizedBox(width: 5),
                                        ],
                                      ),
                                    ],
                                  )),
                              /* Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                    getGeners(nowShowing[item]['genre_ids']),
                                    style: GoogleFonts.notoSans()),
                              ), */
                            ],
                          ),
                        ),
                      );
                    })*/
                ,
              ),
            ],
          ),
          //Popular
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Row(
                  children: [
                    Text(
                      'POPULAR',
                      style: GoogleFonts.notoSans(fontSize: 20),
                    ),
                    Expanded(child: SizedBox()),
                    InkWell(
                      onTap: () {
                        showInterstitialAd();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MoviesTab(
                              tmdbwithcustomlogs: tmdbwithcustomlogs,
                              showIndex: 1,
                              headTitle: 'Movies: Popular',
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'View All',
                        style: GoogleFonts.notoSans(fontSize: 12),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 245,
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: popular.length,
                    itemBuilder: (context, item) {
                      return InkWell(
                        onTap: () {
                          showInterstitialAd();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MoviesDetails(
                                tmdbwithcustomlogs: tmdbwithcustomlogs,
                                backdrop_path: popular[item]['backdrop_path'],
                                id: popular[item]['id'],
                                poster_path: popular[item]['poster_path'],
                                title: popular[item]['title'],
                                heroID: popular[item]['poster_path'],
                                hero: 2,
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: popular[item]['poster_path'] ?? '',
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    height: 210,
                                    width: 130,
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        Container(
                                          foregroundDecoration: BoxDecoration(),
                                          alignment: Alignment.bottomCenter,
                                          height: 210,
                                          width: 320,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: popular[item]
                                                          ['poster_path'] !=
                                                      null
                                                  ? NetworkImage(
                                                      'https://image.tmdb.org/t/p/w500' +
                                                          popular[item]
                                                              ['poster_path'],
                                                    )
                                                  : AssetImage(
                                                      'assets/loading.gif'),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.only(left: 10),
                                    width: 90,
                                    child: Text(
                                      popular[item]['title'] ?? '',
                                      style: GoogleFonts.notoSans(fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
          //Native ad
          _isNativeAdLoaded
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 110,
                    child: AdWidget(
                      ad: Platform.isAndroid
                          ? _ad
                          : AdmobService.createMainMoviePagePageBannerAd()
                        ..load(),
                    ),
                  ),
                )
              : Container(),
          //Upcoming
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Row(
                  children: [
                    Text(
                      'UPCOMING',
                      style: GoogleFonts.notoSans(fontSize: 20),
                    ),
                    Expanded(child: SizedBox()),
                    InkWell(
                      onTap: () {
                        showInterstitialAd();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MoviesTab(
                              tmdbwithcustomlogs: tmdbwithcustomlogs,
                              showIndex: 2,
                              headTitle: 'Movies: Upcoming',
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'View All',
                        style: GoogleFonts.notoSans(fontSize: 12),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                  height: 260,
                  child: CarouselSlider.builder(
                      itemCount: upcoming.length,
                      options: CarouselOptions(
                        scrollPhysics: BouncingScrollPhysics(),
                        enableInfiniteScroll: false,
                        disableCenter: true,
                        viewportFraction: 0.8,
                        enlargeCenterPage: true,
                      ),
                      itemBuilder: (context, item, page) {
                        return InkWell(
                          onTap: () {
                            showInterstitialAd();

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MoviesDetails(
                                          tmdbwithcustomlogs:
                                              tmdbwithcustomlogs,
                                          backdrop_path: upcoming[item]
                                              ['backdrop_path'],
                                          id: upcoming[item]['id'],
                                          poster_path: upcoming[item]
                                              ['poster_path'],
                                          title: upcoming[item]['title'],
                                          hero: 1,
                                          heroID: upcoming[item]
                                              ['backdrop_path'],
                                        )));
                          },
                          child: Hero(
                            tag: upcoming[item]['backdrop_path'] ?? '',
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      height: 210,
                                      width: 320,
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          Container(
                                            foregroundDecoration: BoxDecoration(
                                                //color: Colors.black45
                                                ),
                                            alignment: Alignment.bottomCenter,
                                            height: 210,
                                            width: 320,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20)),
                                              image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: upcoming[item]
                                                            ['backdrop_path'] !=
                                                        null
                                                    ? NetworkImage(
                                                        'https://image.tmdb.org/t/p/w500' +
                                                            upcoming[item][
                                                                'backdrop_path'],
                                                      )
                                                    : AssetImage(
                                                        'assets/loading.gif'),
                                              ),
                                            ),
                                          ),
                                          /* Row(
                                            children: [
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                width: 250,
                                                child: Text(
                                                  upcoming[item]['title'],
                                                  style: GoogleFonts.notoSans(
                                                      fontSize: 20),
                                                  overflow: TextOverflow.clip,
                                                ),
                                              ),
                                              Expanded(child: SizedBox()),
                                              Text(
                                                (upcoming[item]['vote_average'])
                                                    .toString(),
                                                style: GoogleFonts.notoSans(
                                                    fontSize: 20),
                                              ),
                                              Icon(
                                                Icons.star,
                                                color: Colors.white,
                                                size: 18,
                                              )
                                            ],
                                          ), */
                                        ],
                                      )),
                                  /* Text(
                                  getGeners(upcoming[item]['genre_ids']),
                                  style: GoogleFonts.notoSans(),
                                ), */
                                  Container(
                                    padding: EdgeInsets.only(left: 10),
                                    width: 250,
                                    child: Text(
                                      upcoming[item]['title'] ?? '',
                                      style: GoogleFonts.notoSans(fontSize: 20),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      })
                  /*ListView.builder(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: upcoming.length,
                    itemBuilder: (context, item) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MoviesDetails(
                                        tmdbwithcustomlogs: tmdbwithcustomlogs,
                                        backdrop_path: upcoming[item]
                                            ['backdrop_path'],
                                        id: upcoming[item]['id'],
                                        poster_path: upcoming[item]
                                            ['poster_path'],
                                        title: upcoming[item]['title'],
                                      )));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  height: 210,
                                  width: 320,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Container(
                                          foregroundDecoration: BoxDecoration(
                                              //color: Colors.black45
                                              ),
                                          alignment: Alignment.bottomCenter,
                                          height: 210,
                                          width: 320,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20)),
                                              image: DecorationImage(
                                                  fit: BoxFit.fill,
                                                  image: NetworkImage(
                                                    'https://image.tmdb.org/t/p/w500' +
                                                        upcoming[item]
                                                            ['backdrop_path'],
                                                  )))),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            width: 250,
                                            child: Text(
                                              upcoming[item]['title'],
                                              style: GoogleFonts.notoSans(
                                                  fontSize: 20),
                                              overflow: TextOverflow.clip,
                                            ),
                                          ),
                                          Expanded(child: SizedBox()),
                                          Text(
                                            (upcoming[item]['vote_average'])
                                                .toString(),
                                            style: GoogleFonts.notoSans(
                                                fontSize: 20),
                                          ),
                                          Icon(
                                            Icons.star,
                                            color: Colors.white,
                                            size: 18,
                                          )
                                        ],
                                      ),
                                    ],
                                  )),
                              /* Text(
                                getGeners(upcoming[item]['genre_ids']),
                                style: GoogleFonts.notoSans(),
                              ), */
                            ],
                          ),
                        ),
                      );
                    }),*/
                  ),
            ],
          ),
          //Top Rated
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Row(
                  children: [
                    Text(
                      'TOP RATED',
                      style: GoogleFonts.notoSans(fontSize: 20),
                    ),
                    Expanded(child: SizedBox()),
                    InkWell(
                      onTap: () {
                        showInterstitialAd();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MoviesTab(
                              tmdbwithcustomlogs: tmdbwithcustomlogs,
                              showIndex: 3,
                              headTitle: 'Movies: Top Rated',
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'View All',
                        style: GoogleFonts.notoSans(fontSize: 12),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 245,
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: trending.length,
                    itemBuilder: (context, item) {
                      return InkWell(
                        onTap: () {
                          showInterstitialAd();

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MoviesDetails(
                                        tmdbwithcustomlogs: tmdbwithcustomlogs,
                                        backdrop_path: trending[item]
                                            ['backdrop_path'],
                                        id: trending[item]['id'],
                                        poster_path: trending[item]
                                            ['poster_path'],
                                        title: trending[item]['title'],
                                        hero: 2,
                                        heroID: trending[item]['poster_path'],
                                      )));
                        },
                        child: Hero(
                          tag: trending[item]['poster_path'] ?? '',
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    height: 210,
                                    width: 130,
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        Container(
                                          foregroundDecoration: BoxDecoration(),
                                          alignment: Alignment.bottomCenter,
                                          height: 210,
                                          width: 320,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: trending[item]
                                                          ['poster_path'] !=
                                                      null
                                                  ? NetworkImage(
                                                      'https://image.tmdb.org/t/p/w500' +
                                                          trending[item]
                                                              ['poster_path'],
                                                    )
                                                  : AssetImage(
                                                      'assets/loading.gif'),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.only(left: 10),
                                    width: 90,
                                    child: Text(
                                      trending[item]['title'] ?? '',
                                      style: GoogleFonts.notoSans(fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                  height: 50,
                  child: AdWidget(
                    ad: AdmobService.createMainMoviePagePageBannerAd()..load(),
                  )),
            ],
          )
        ],
      ),
    ));
  }
}
