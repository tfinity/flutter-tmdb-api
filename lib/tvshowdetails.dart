import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:movies_app/admob_sevices.dart';
import 'package:movies_app/peopledetails.dart';
import 'package:movies_app/trailerplay.dart';
import 'package:movies_app/video%20streaming/moviePlay.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_generator/palette_generator.dart';

class tvShowDetails extends StatefulWidget {
  const tvShowDetails(
      {Key key,
      @required this.id,
      this.poster_path,
      this.backdrop_path,
      this.tmdbwithcustomlogs,
      this.title,
      this.heroId,
      this.hero})
      : super(key: key);
  final int id;
  final String poster_path, backdrop_path;
  final TMDB tmdbwithcustomlogs;
  final String title;
  final String heroId;
  final int hero;

  @override
  _tvShowDetailsState createState() => _tvShowDetailsState();
}

class _tvShowDetailsState extends State<tvShowDetails> {
  Map tvDetails;
  List seasons = [];
  Map castCredits;
  List cast = [];
  Map crewCredits;
  List crew = [];
  Map similarMovies;
  List similar = [];
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
        NetworkImage('https://image.tmdb.org/t/p/w500' + backdrop_path));
    imageColor = generator.lightMutedColor != null
        ? generator.lightMutedColor
        : PaletteColor(Colors.yellowAccent.shade100, 2);
    print(imageColor.color);
    setState(() {});
  }

  DatabaseReference _dbref;
  bool buttonShow = false;

  @override
  void initState() {
    _dbref = FirebaseDatabase.instance.reference();
    _dbref.onValue.listen((event) => {
          setState(() {
            event.snapshot.value["PlayButton"].toString() == "show"
                ? buttonShow = true
                : buttonShow = false;
          })
        });
    creatInterstitialAd();
    id = widget.id;
    tmdbwithcustomlogs = widget.tmdbwithcustomlogs;
    poster_path = widget.poster_path;
    backdrop_path = widget.backdrop_path;
    title = widget.title;
    colorPick();
    _getTrailerData();
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

  Map _details;
  List _data = [];
  String trailerId = 'xxxxx';

  _getTrailerData() async {
    _details = await tmdbwithcustomlogs.v3.tv.getVideos(id.toString());
    print('keyyy ${id.toString()}');
    _data = _details['results'];
    print('key data length: $_details');
    for (int x = 0; x < _data.length; x++) {
      if (_data[x]['key'] != null) {
        trailerId = _data[x]['key'];
        print('key main: $trailerId');
        setState(() {});
        return;
      }
    }
    setState(() {});
    print(_details);
  }

  Future tvDataDetails() async {
    tvDetails = await tmdbwithcustomlogs.v3.tv.getDetails(id);
    seasons = tvDetails['seasons'];
    return tvDetails;
  }

  Future tvCastDetails() async {
    castCredits = await tmdbwithcustomlogs.v3.tv.getCredits(id);
    cast = castCredits['cast'];
    return cast;
  }

  Future tvCrewDetails() async {
    crewCredits = await tmdbwithcustomlogs.v3.tv.getCredits(id);
    crew = crewCredits['crew'];
    return crew;
  }

  Future similartvdetails() async {
    similarMovies = await tmdbwithcustomlogs.v3.tv.getSimilar(id);
    similar = similarMovies['results'];
    return similar;
  }

  showEpisodes() {
    return Dialog(
      backgroundColor: Colors.black,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              height: 300,
              child: ListView.builder(
                  itemCount: seasons.length,
                  itemBuilder: (builder, season) {
                    return ExpansionTile(
                        title: Text('Season ${season + 1}'),
                        children: [
                          Container(
                            height: 200,
                            child: ListView.builder(
                                itemCount: seasons[season]['episode_count'],
                                itemBuilder: (builder, episode) {
                                  print('S$season:E$episode');
                                  return ListTile(
                                    title: Text(
                                      'S${season + 1}:E${episode + 1}',
                                      style: GoogleFonts.notoSans(),
                                    ),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (builder) => MoviePaly(
                                            tvID:
                                                '$id-${season + 1}-${episode + 1}',
                                            isMovie: false,
                                            title:
                                                '$title: S${season + 1} E${episode + 1}',
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                          ),
                        ]);
                  }),
            )
          ],
        ),
      ),
    );

    /* return Dialog(
      child: Container(
        width: 500,
        height: 400,
        child: Column(children: [
          ListView.builder(
              itemCount: seasons.length,
              itemBuilder: (builder, season) {
                return ListView.builder(
                    itemCount: seasons[season]['episode_count'],
                    itemBuilder: (builder, episode) {
                      print('S$season:E$episode');
                      return ListTile(
                        title: Text(
                          'S$season:E$episode',
                          style: GoogleFonts.notoSans(),
                        ),
                      );
                    });
              }),
        ]),
      ),
    ); */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
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
                  tag: widget.hero == 1 ? widget.heroId ?? '' : "",
                  child: Container(
                    child: Column(
                      children: [
                        backdrop_path != null
                            ? Container(
                                height: 300,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                  image: backdrop_path != null
                                      ? NetworkImage(
                                          'https://image.tmdb.org/t/p/w500' +
                                              backdrop_path)
                                      : AssetImage('assets/loading.gif'),
                                  fit: BoxFit.fill,
                                )),
                              )
                            : Center(
                                child: Image(
                                  image: AssetImage('assets/loading.gif'),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                title: Text(
                  title ?? '',
                  style: GoogleFonts.notoSans(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    //imageColor != null ? imageColor.bodyTextColor : null
                  ),
                  overflow: TextOverflow.fade,
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
                        future: tvDataDetails(),
                        builder: (builder, snapshot) {
                          if (snapshot.data == null) {
                            dataLoading = true;
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            dataLoading = false;
                            return Container(
                              //color: Colors.white,
                              padding: EdgeInsets.all(8),
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Hero(
                                        tag: widget.hero == 2
                                            ? widget.heroId ?? ''
                                            : "",
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20)),
                                              image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: snapshot.data[
                                                            "poster_path"] !=
                                                        null
                                                    ? NetworkImage(
                                                        'https://image.tmdb.org/t/p/w500' +
                                                            snapshot.data[
                                                                "poster_path"])
                                                    : AssetImage(
                                                        'assets/loading.gif'),
                                              )),
                                          //color: Colors.green,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.25,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Visibility(
                                            visible: buttonShow,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 0,
                                                  top: 0,
                                                  bottom: 0,
                                                  left: 20),
                                              child: OutlinedButton.icon(
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    primary: Colors.green,
                                                    side: BorderSide(
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    showInterstitialAd();
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return showEpisodes();
                                                        });
                                                  },
                                                  icon: Icon(Icons.play_arrow),
                                                  label: Text("Watch Now",
                                                      style: GoogleFonts
                                                          .notoSans())),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 0,
                                                top: 0,
                                                bottom: 0,
                                                left: 20),
                                            child: OutlinedButton.icon(
                                                style: OutlinedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  primary: Colors.red,
                                                  side: BorderSide(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  showInterstitialAd();
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              TrailerPlay(
                                                                tmdbwithcustomlogs:
                                                                    tmdbwithcustomlogs,
                                                                id: id,
                                                                trailerkey:
                                                                    trailerId,
                                                              )));
                                                },
                                                icon: Icon(Icons.play_arrow),
                                                label: Text("Play Trailer",
                                                    style: GoogleFonts
                                                        .notoSans())),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Overview',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      //color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    snapshot.data['overview'] != null
                                        ? snapshot.data['overview']
                                        : 'null',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    'Status',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      //color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    snapshot.data['status'] != null
                                        ? snapshot.data['status']
                                        : 'null',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    'Seasons',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      //color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    snapshot.data['seasons'] != null
                                        ? snapshot.data['seasons'].length
                                            .toString()
                                        : 'null',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    'First Air Date',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      //color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    snapshot.data['first_air_date'] != null
                                        ? snapshot.data['first_air_date']
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
                    Visibility(
                      visible: cast.length == 0 ? false : true,
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
                      visible: cast.length == 0 ? false : true,
                      child: FutureBuilder(
                          future: tvCastDetails(),
                          builder: (builder, snapshot) {
                            if (snapshot.data == null) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              return Container(
                                height: 210,
                                child: ListView.builder(
                                    physics: BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: snapshot.data.length,
                                    itemBuilder: (context, index) {
                                      return (snapshot.data[index]
                                                      ['profile_path'] !=
                                                  null &&
                                              snapshot.data[index]['name'] !=
                                                  null &&
                                              snapshot.data[index]
                                                      ['character'] !=
                                                  null)
                                          ? InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            peopleDetails(
                                                              tmdbwithcustomlogs:
                                                                  tmdbwithcustomlogs,
                                                              id: snapshot.data[
                                                                  index]['id'],
                                                              poster_path: snapshot
                                                                          .data[
                                                                      index][
                                                                  'profile_path'],
                                                              title:
                                                                  snapshot.data[
                                                                          index]
                                                                      ['name'],
                                                            )));
                                              },
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4, right: 4),
                                                    child: CircleAvatar(
                                                      radius: 65,
                                                      backgroundImage: snapshot
                                                                          .data[
                                                                      index][
                                                                  'profile_path'] !=
                                                              null
                                                          ? NetworkImage(
                                                              'https://image.tmdb.org/t/p/w500' +
                                                                  snapshot.data[
                                                                          index]
                                                                      [
                                                                      'profile_path'])
                                                          : AssetImage(
                                                              'assets/loading.gif'),
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
                                                        Text(
                                                          snapshot.data[index]
                                                                  ['name'] ??
                                                              '',
                                                          style: GoogleFonts
                                                              .notoSans(),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                          snapshot.data[index][
                                                                  'character'] ??
                                                              '',
                                                          style: GoogleFonts
                                                              .notoSans(
                                                                  color: Colors
                                                                      .white70),
                                                          overflow: TextOverflow
                                                              .ellipsis,
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
                    _isNativeAdLoaded
                        ? Container(
                            height: 110,
                            child: AdWidget(
                              ad: Platform.isAndroid
                                  ? _ad
                                  : AdmobService.createTvPageBannerAd()
                                ..load(),
                            ),
                          )
                        : Container(),
                    Visibility(
                      visible: crew.length == 0 ? false : true,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'Crew Credits',
                          style: GoogleFonts.notoSans(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: crew.length == 0 ? false : true,
                      child: FutureBuilder(
                          future: tvCrewDetails(),
                          builder: (builder, snapshot) {
                            if (snapshot.data == null) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              return Container(
                                height: 210,
                                child: ListView.builder(
                                    physics: BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: snapshot.data.length,
                                    itemBuilder: (context, index) {
                                      return (snapshot.data[index]
                                                      ['profile_path'] !=
                                                  null &&
                                              snapshot.data[index]['name'] !=
                                                  null &&
                                              snapshot.data[index]['job'] !=
                                                  null)
                                          ? InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            peopleDetails(
                                                              tmdbwithcustomlogs:
                                                                  tmdbwithcustomlogs,
                                                              id: snapshot.data[
                                                                  index]['id'],
                                                              poster_path: snapshot
                                                                          .data[
                                                                      index][
                                                                  'profile_path'],
                                                              title:
                                                                  snapshot.data[
                                                                          index]
                                                                      ['name'],
                                                            )));
                                              },
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4, right: 4),
                                                    child: CircleAvatar(
                                                      radius: 65,
                                                      backgroundImage: snapshot
                                                                          .data[
                                                                      index][
                                                                  'profile_path'] !=
                                                              null
                                                          ? NetworkImage(
                                                              'https://image.tmdb.org/t/p/w500' +
                                                                  snapshot.data[
                                                                          index]
                                                                      [
                                                                      'profile_path'])
                                                          : AssetImage(
                                                              'assets/loading.gif'),
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
                                                        Text(
                                                          snapshot.data[index]
                                                                  ['name'] ??
                                                              '',
                                                          style: GoogleFonts
                                                              .notoSans(),
                                                        ),
                                                        SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                          snapshot.data[index]
                                                                  ['job'] ??
                                                              '',
                                                          style: GoogleFonts
                                                              .notoSans(
                                                                  color: Colors
                                                                      .white70),
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
                    Visibility(
                      visible: similar.length == 0 ? false : true,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'Similar TV Shows',
                          style: GoogleFonts.notoSans(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: similar.length == 0 ? false : true,
                      child: FutureBuilder(
                          future: similartvdetails(),
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
                                                      ['first_air_date'] !=
                                                  null)
                                          ? InkWell(
                                              onTap: () {
                                                showInterstitialAd();
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
                                                              id: snapshot.data[
                                                                  index]['id'],
                                                              poster_path: snapshot
                                                                          .data[
                                                                      index][
                                                                  'poster_path'],
                                                              title:
                                                                  snapshot.data[
                                                                          index]
                                                                      ['name'],
                                                            )));
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
                                                                        index][
                                                                    'poster_path'] !=
                                                                null
                                                            ? NetworkImage(
                                                                'https://image.tmdb.org/t/p/w500' +
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
                                                            snapshot.data[index]
                                                                    ['name'] ??
                                                                '',
                                                            style: GoogleFonts
                                                                .notoSans(),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          snapshot.data[index][
                                                                  'first_air_date'] ??
                                                              '',
                                                          style: TextStyle(
                                                              decoration:
                                                                  TextDecoration
                                                                      .none,
                                                              fontSize: 12),
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
                    Container(
                        height: 50,
                        child: AdWidget(
                          ad: AdmobService.createTvPageBannerAd()..load(),
                        )),
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
