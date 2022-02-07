import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:movies_app/admob_sevices.dart';
import 'package:movies_app/files/globals.dart';
import 'package:movies_app/search.dart';
import 'package:movies_app/tvTab.dart';
import 'package:movies_app/tvshowdetails.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'drawer.dart';

class MainTvPage extends StatefulWidget {
  const MainTvPage({Key key}) : super(key: key);

  @override
  _MainTvPageState createState() => _MainTvPageState();
}

class _MainTvPageState extends State<MainTvPage> {
  TMDB tmdbwithcustomlogs;
  List onAir = [];
  List popular = [];
  List airingToday = [];
  List trending = [];
  bool _isNativeAdLoaded = false;
  NativeAd _ad;
  @override
  void initState() {
    creatInterstitialAd();
    tmdbwithcustomlogs = globaldataobject;
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
    Map onAirdata = await tmdbwithcustomlogs.v3.tv.getOnTheAir();
    onAir = onAirdata['results'];
    Map populargdata = await tmdbwithcustomlogs.v3.tv.getPouplar();
    popular = populargdata['results'];
    Map airingTodaydata = await tmdbwithcustomlogs.v3.tv.getAiringToday();
    airingToday = airingTodaydata['results'];
    Map trendingdata = await tmdbwithcustomlogs.v3.tv.getTopRated();
    trending = trendingdata['results'];
    Map generData = await tmdbwithcustomlogs.v3.geners.getTvlist();
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
    return Scaffold(
      drawer: ApplicationDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Tv Shows',
          style: GoogleFonts.notoSans(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              size: 35,
            ),
            onPressed: () {
              showInterstitialAd();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SearchData(
                        tmdbwithcustomlogs: tmdbwithcustomlogs,
                      )));
            },
          ),
          SizedBox(
            width: 8,
          )
        ],
      ),
      body: Material(
          color: Colors.black,
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: [
              //On air today
              Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 10, right: 10),
                    child: Row(
                      children: [
                        Text(
                          'ON AIR TODAY',
                          style: GoogleFonts.notoSans(fontSize: 20),
                        ),
                        Expanded(child: SizedBox()),
                        InkWell(
                          onTap: () {
                            showInterstitialAd();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => TvTab(
                                      tmdbwithcustomlogs: tmdbwithcustomlogs,
                                      showIndex: 0,
                                      headTitle: 'TV: On Air Today',
                                    )));
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
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                    ),
                    height: 260,
                    child: CarouselSlider.builder(
                      itemCount: onAir.isEmpty ? 0 : onAir.length,
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
                                builder: (context) => tvShowDetails(
                                  tmdbwithcustomlogs: tmdbwithcustomlogs,
                                  backdrop_path: onAir[item]['backdrop_path'],
                                  id: onAir[item]['id'],
                                  poster_path: onAir[item]['poster_path'],
                                  title: onAir[item]['name'],
                                  hero: 1,
                                  heroId: onAir[item]['backdrop_path'],
                                ),
                              ),
                            );
                          },
                          child: Hero(
                            tag: onAir[item]['backdrop_path'] ?? 'invalid',
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      height: 220,
                                      width: 320,
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          Container(
                                            foregroundDecoration: BoxDecoration(
                                                //color: Colors.black45
                                                ),
                                            alignment: Alignment.bottomCenter,
                                            height: 220,
                                            width: 320,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20)),
                                              image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: onAir[item]
                                                            ['backdrop_path'] !=
                                                        null
                                                    ? NetworkImage(
                                                        'https://image.tmdb.org/t/p/w500' +
                                                            onAir[item][
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
                                          Text(
                                            onAir[item]['name'],
                                            style: GoogleFonts.notoSans(
                                                fontSize: 16,
                                                color: Colors.white),
                                            overflow: TextOverflow.clip,
                                          ),
                                          Expanded(child: SizedBox()),
                                          Text(
                                            (onAir[item]['vote_average'])
                                                .toString(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Acumin',
                                                fontSize: 16),
                                          ),
                                          Icon(
                                            Icons.star,
                                            color: Colors.white,
                                            size: 16,
                                          )
                                        ],
                                      ), */
                                        ],
                                      )),
                                  //Text(getGeners(onAir[item]['genre_ids'])),
                                  Container(
                                    padding: EdgeInsets.only(left: 10),
                                    width: 250,
                                    child: Text(
                                      onAir[item]['name'] ?? '',
                                      style: GoogleFonts.notoSans(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    /*ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: onAir.isEmpty ? 0 : onAir.length,
                        itemBuilder: (context, item) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => tvShowDetails(
                                            tmdbwithcustomlogs:
                                                tmdbwithcustomlogs,
                                            backdrop_path: onAir[item]
                                                ['backdrop_path'],
                                            id: onAir[item]['id'],
                                            poster_path: onAir[item]
                                                ['poster_path'],
                                            title: onAir[item]['name'],
                                          )));
                            },
                            child: Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      height: 200,
                                      width: 320,
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          Container(
                                            foregroundDecoration: BoxDecoration(
                                                color: Colors.black45),
                                            alignment: Alignment.bottomCenter,
                                            height: 200,
                                            width: 320,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: onAir[item]
                                                            ['backdrop_path'] !=
                                                        null
                                                    ? NetworkImage(
                                                        'https://image.tmdb.org/t/p/w500' +
                                                            onAir[item][
                                                                'backdrop_path'],
                                                      )
                                                    : AssetImage(
                                                        'assets/loading.gif'),
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                onAir[item]['name'],
                                                style: GoogleFonts.notoSans(
                                                    fontSize: 16,
                                                    color: Colors.white),
                                                overflow: TextOverflow.clip,
                                              ),
                                              Expanded(child: SizedBox()),
                                              Text(
                                                (onAir[item]['vote_average'])
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Acumin',
                                                    fontSize: 16),
                                              ),
                                              Icon(
                                                Icons.star,
                                                color: Colors.white,
                                                size: 16,
                                              )
                                            ],
                                          ),
                                        ],
                                      )),
                                  Text(getGeners(onAir[item]['genre_ids'])),
                                ],
                              ),
                            ),
                          );
                        }),*/
                  ),
                ],
              ),
              //Popular
              Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 10, right: 10),
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
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => TvTab(
                                      tmdbwithcustomlogs: tmdbwithcustomlogs,
                                      showIndex: 1,
                                      headTitle: 'TV: Popular',
                                    )));
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
                        itemCount: popular.isEmpty ? 0 : popular.length,
                        itemBuilder: (context, item) {
                          return InkWell(
                            onTap: () {
                              showInterstitialAd();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => tvShowDetails(
                                    tmdbwithcustomlogs: tmdbwithcustomlogs,
                                    backdrop_path: popular[item]
                                        ['backdrop_path'],
                                    id: popular[item]['id'],
                                    poster_path: popular[item]['poster_path'],
                                    title: popular[item]['name'],
                                    hero: 2,
                                    heroId: popular[item]['poster_path'],
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: popular[item]['poster_path'] ?? 'invalid',
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
                                              foregroundDecoration:
                                                  BoxDecoration(),
                                              alignment: Alignment.bottomCenter,
                                              height: 210,
                                              width: 130,
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
                                                              popular[item][
                                                                  'poster_path'],
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
                                          popular[item]['name'] ?? '',
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
                          );
                        }),
                  ),
                ],
              ),
              //Native ad
              _isNativeAdLoaded
                  ? Container(
                      height: 110,
                      child: AdWidget(
                        ad: Platform.isAndroid
                            ? _ad
                            : AdmobService.createMaintvPagePageBannerAd()
                          ..load(),
                      ),
                    )
                  : Container(),
              //airing today
              Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 10, right: 10),
                    child: Row(
                      children: [
                        Text(
                          'AIRING TODAY',
                          style: GoogleFonts.notoSans(fontSize: 20),
                        ),
                        Expanded(child: SizedBox()),
                        InkWell(
                          onTap: () {
                            showInterstitialAd();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => TvTab(
                                      tmdbwithcustomlogs: tmdbwithcustomlogs,
                                      showIndex: 2,
                                      headTitle: 'TV: Airing Today',
                                    )));
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
                        itemCount: airingToday.isEmpty ? 0 : airingToday.length,
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
                                  builder: (context) => tvShowDetails(
                                    tmdbwithcustomlogs: tmdbwithcustomlogs,
                                    backdrop_path: airingToday[item]
                                        ['backdrop_path'],
                                    id: airingToday[item]['id'],
                                    poster_path: airingToday[item]
                                        ['poster_path'],
                                    title: airingToday[item]['name'],
                                    hero: 1,
                                    heroId: airingToday[item]['backdrop_path'],
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: airingToday[item]['backdrop_path'] ??
                                  'invalid',
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
                                              foregroundDecoration:
                                                  BoxDecoration(
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
                                                  image: airingToday[item][
                                                              'backdrop_path'] !=
                                                          null
                                                      ? NetworkImage(
                                                          'https://image.tmdb.org/t/p/w500' +
                                                              airingToday[item][
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
                                                airingToday[item]['name'],
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Acumin',
                                                    fontSize: 16),
                                                overflow: TextOverflow.clip,
                                              ),
                                            ),
                                            Expanded(child: SizedBox()),
                                            Text(
                                              (airingToday[item]['vote_average'])
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Acumin',
                                                  fontSize: 16),
                                            ),
                                            Icon(
                                              Icons.star,
                                              color: Colors.white,
                                              size: 16,
                                            )
                                          ],
                                        ), */
                                          ],
                                        )),
                                    //Text(getGeners(airingToday[item]['genre_ids'])),
                                    Container(
                                      padding: EdgeInsets.only(left: 10),
                                      width: 250,
                                      child: Text(
                                        airingToday[item]['name'] ?? '',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Acumin',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
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
                    scrollDirection: Axis.horizontal,
                    itemCount: airingToday.isEmpty ? 0 : airingToday.length,
                    itemBuilder: (context, item) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => tvShowDetails(
                                        tmdbwithcustomlogs: tmdbwithcustomlogs,
                                        backdrop_path: airingToday[item]
                                            ['backdrop_path'],
                                        id: airingToday[item]['id'],
                                        poster_path: airingToday[item]
                                            ['poster_path'],
                                        title: airingToday[item]['name'],
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
                                                        airingToday[item]
                                                            ['backdrop_path'],
                                                  )))),
                                      /* Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            width: 250,
                                            child: Text(
                                              airingToday[item]['name'],
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Acumin',
                                                  fontSize: 16),
                                              overflow: TextOverflow.clip,
                                            ),
                                          ),
                                          Expanded(child: SizedBox()),
                                          Text(
                                            (airingToday[item]['vote_average'])
                                                .toString(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Acumin',
                                                fontSize: 16),
                                          ),
                                          Icon(
                                            Icons.star,
                                            color: Colors.white,
                                            size: 16,
                                          )
                                        ],
                                      ), */
                                    ],
                                  )),
                              //Text(getGeners(airingToday[item]['genre_ids'])),
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                width: 250,
                                child: Text(
                                  airingToday[item]['name'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Acumin',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
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
                    padding:
                        const EdgeInsets.only(top: 10, left: 10, right: 10),
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
                                builder: (context) => TvTab(
                                  tmdbwithcustomlogs: tmdbwithcustomlogs,
                                  showIndex: 3,
                                  headTitle: 'TV: Top Rated',
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
                        itemCount: trending.isEmpty ? 0 : trending.length,
                        itemBuilder: (context, item) {
                          return InkWell(
                            onTap: () {
                              showInterstitialAd();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => tvShowDetails(
                                    tmdbwithcustomlogs: tmdbwithcustomlogs,
                                    backdrop_path: trending[item]
                                        ['backdrop_path'],
                                    id: trending[item]['id'],
                                    poster_path: trending[item]['poster_path'],
                                    title: trending[item]['name'],
                                    hero: 2,
                                    heroId: trending[item]['poster_path'],
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: trending[item]['poster_path'] ?? 'invalid',
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
                                              foregroundDecoration:
                                                  BoxDecoration(),
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
                                                              trending[item][
                                                                  'poster_path'],
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
                                          trending[item]['name'],
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
                          );
                        }),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      height: 50,
                      child: AdWidget(
                        ad: AdmobService.createMaintvPagePageBannerAd()..load(),
                      )),
                ],
              )
            ],
          )),
    );
  }
}
