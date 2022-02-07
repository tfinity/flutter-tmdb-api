import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:movies_app/admob_sevices.dart';
import 'package:movies_app/tvshowdetails.dart';
import 'package:movies_app/details.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_generator/palette_generator.dart';

class peopleDetails extends StatefulWidget {
  const peopleDetails(
      {Key key,
      @required this.id,
      this.poster_path,
      this.backdrop_path,
      this.tmdbwithcustomlogs,
      this.title,
      this.heroId})
      : super(key: key);
  final int id;
  final String poster_path, backdrop_path;
  final TMDB tmdbwithcustomlogs;
  final String title;
  final String heroId;

  @override
  _peopleDetailsState createState() => _peopleDetailsState();
}

class _peopleDetailsState extends State<peopleDetails> {
  Map peopleDetail;
  Map castCredits;
  List cast = [];

  int id;
  TMDB tmdbwithcustomlogs;
  String poster_path, backdrop_path;
  String title;
  bool dataLoading = true;

  PaletteColor imageColor;

  NativeAd _ad;
  bool _isNativeAdLoaded = false;

  colorPick() async {
    PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
        NetworkImage('https://image.tmdb.org/t/p/w500' + poster_path));
    imageColor = generator.lightMutedColor != null
        ? generator.lightMutedColor
        : PaletteColor(Colors.yellowAccent.shade100, 2);
    print(imageColor.color);
    setState(() {});
  }

  @override
  void initState() {
    creatInterstitialAd();
    id = widget.id;
    tmdbwithcustomlogs = widget.tmdbwithcustomlogs;
    poster_path = widget.poster_path;
    title = widget.title;
    colorPick();
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

  Future peopleDataDetails() async {
    peopleDetail = await tmdbwithcustomlogs.v3.people.getDetails(id);
    return peopleDetail;
  }

  Future peopleCastDetails() async {
    castCredits = await tmdbwithcustomlogs.v3.people.getCombinedCredits(id);
    cast = castCredits['cast'];
    return cast;
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors
              .black, //imageColor != null ? imageColor.color : Colors.black,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      showInterstitialAd();
                      Navigator.of(context).pop();
                    }),
                backgroundColor: Colors.black,
                //imageColor != null ? imageColor.color : Colors.black87,
                pinned: true,
                expandedHeight: 310,
                //leading: Icon(Icons.arrow_back),
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'widget.heroId',
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                            height: 300,
                            child: Image.network(
                              'https://image.tmdb.org/t/p/w500' + poster_path,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  title: Text(
                    title,
                    style: GoogleFonts.notoSans(
                        fontWeight: FontWeight.bold, color: Colors.white
                        //imageColor != null ? imageColor.bodyTextColor : null
                        ),
                    overflow: TextOverflow.visible,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    //physics: NeverScrollableScrollPhysics(),
                    children: [
                      //Visibility(visible: dataLoading, child: LinearProgressIndicator()),
                      FutureBuilder(
                          future: peopleDataDetails(),
                          builder: (builder, snapshot) {
                            if (snapshot.data == null) {
                              dataLoading = true;
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              dataLoading = false;
                              return Container(
                                color: Colors.black,
                                padding: EdgeInsets.all(8),
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bio',
                                      style: GoogleFonts.notoSans(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        //color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      snapshot.data['biography'] != null
                                          ? snapshot.data['biography']
                                          : 'null',
                                      style: GoogleFonts.notoSans(
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      'Birthplace',
                                      style: GoogleFonts.notoSans(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        //color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      snapshot.data['place_of_birth'] != null
                                          ? snapshot.data['place_of_birth']
                                          : 'null',
                                      style: GoogleFonts.notoSans(
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      'Born',
                                      style: GoogleFonts.notoSans(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        //color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      snapshot.data['birthday'] != null
                                          ? snapshot.data['birthday']
                                          : 'null',
                                      style: GoogleFonts.notoSans(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }),
                      _isNativeAdLoaded
                          ? Container(
                              height: 110,
                              child: AdWidget(
                                ad: Platform.isAndroid
                                    ? _ad
                                    : AdmobService.createPeoplePageBannerAd()
                                  ..load(),
                              ),
                            )
                          : Container(),
                      Visibility(
                        visible: cast.isEmpty ? false : true,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Cast Credits',
                            style: GoogleFonts.notoSans(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: cast.isEmpty ? false : true,
                        child: FutureBuilder(
                            future: peopleCastDetails(),
                            builder: (builder, snapshot) {
                              if (snapshot.data == null) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                return Container(
                                  height: 270,
                                  child: ListView.builder(
                                      physics: BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: snapshot.data.length,
                                      itemBuilder: (context, index) {
                                        return (snapshot.data[index]
                                                        ['poster_path'] !=
                                                    null &&
                                                snapshot.data[index]['name'] !=
                                                    null &&
                                                snapshot.data[index]
                                                        ['character'] !=
                                                    null &&
                                                snapshot.data[index]
                                                        ['first_air_date'] !=
                                                    null)
                                            ? InkWell(
                                                onTap: () {
                                                  showInterstitialAd();
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
                                                                  backdrop_path:
                                                                      snapshot.data[
                                                                              index]
                                                                          [
                                                                          'backdrop_path'],
                                                                  id: snapshot
                                                                          .data[
                                                                      index]['id'],
                                                                  poster_path: snapshot
                                                                              .data[
                                                                          index]
                                                                      [
                                                                      'poster_path'],
                                                                  title: snapshot
                                                                              .data[
                                                                          index]
                                                                      ['name'],
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
                                                                  backdrop_path:
                                                                      snapshot.data[
                                                                              index]
                                                                          [
                                                                          'backdrop_path'],
                                                                  id: snapshot
                                                                          .data[
                                                                      index]['id'],
                                                                  poster_path: snapshot
                                                                              .data[
                                                                          index]
                                                                      [
                                                                      'poster_path'],
                                                                  title: snapshot
                                                                              .data[
                                                                          index]
                                                                      ['name'],
                                                                )));
                                                  }
                                                },
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          left: 5, right: 5),
                                                      height: 180,
                                                      width: 120,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                        image: DecorationImage(
                                                          fit: BoxFit.fill,
                                                          image: snapshot.data[
                                                                          index]
                                                                      [
                                                                      'poster_path'] !=
                                                                  null
                                                              ? NetworkImage('https://image.tmdb.org/t/p/w500' +
                                                                  snapshot.data[
                                                                          index]
                                                                      [
                                                                      'poster_path'])
                                                              : AssetImage(
                                                                  'assets/loading.gif'),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          left: 10),
                                                      height: 80,
                                                      width: 110,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Flexible(
                                                            child: Text(
                                                                snapshot.data[
                                                                            index]
                                                                        [
                                                                        'name'] ??
                                                                    '',
                                                                style: GoogleFonts
                                                                    .notoSans()),
                                                          ),
                                                          SizedBox(
                                                            height: 2,
                                                          ),
                                                          Flexible(
                                                            child: Text(
                                                              snapshot.data[
                                                                          index]
                                                                      [
                                                                      'character'] ??
                                                                  '',
                                                              style: GoogleFonts
                                                                  .notoSans(
                                                                      color: Colors
                                                                          .white70),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 2,
                                                          ),
                                                          Flexible(
                                                            child: Text(
                                                              snapshot.data[
                                                                          index]
                                                                      [
                                                                      'first_air_date'] ??
                                                                  '',
                                                              style: GoogleFonts
                                                                  .notoSans(
                                                                      color: Colors
                                                                          .white70),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            : Container();
                                      }),
                                );
                              }
                            }),
                      ),
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}
