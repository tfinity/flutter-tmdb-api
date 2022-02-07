/* import 'package:flutter/material.dart';
import 'package:tmdb_api/tmdb_api.dart';

class MoviesDetails extends StatefulWidget {
  const MoviesDetails(
      {Key key,
      @required this.id,
      this.poster_path,
      this.backdrop_path,
      this.tmdbwithcustomlogs,
      this.title})
      : super(key: key);
  final int id;
  final String poster_path, backdrop_path;
  final TMDB tmdbwithcustomlogs;
  final String title;

  @override
  _MoviesDetailsState createState() => _MoviesDetailsState();
}

class _MoviesDetailsState extends State<MoviesDetails> {
  Map movieDetails;
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

  @override
  void initState() {
    id = widget.id;
    tmdbwithcustomlogs = widget.tmdbwithcustomlogs;
    poster_path = widget.poster_path;
    backdrop_path = widget.backdrop_path;
    title = widget.title;
    super.initState();
  }

  Future movieDataDetails() async {
    movieDetails = await tmdbwithcustomlogs.v3.movies.getDetails(id);
    return movieDetails;
  }

  Future movieCastDetails() async {
    castCredits = await tmdbwithcustomlogs.v3.movies.getCredits(id);
    cast = castCredits['cast'];
    return cast;
  }

  Future movieCrewDetails() async {
    crewCredits = await tmdbwithcustomlogs.v3.movies.getCredits(id);
    crew = crewCredits['crew'];
    return crew;
  }

  Future similarMoviesdetails() async {
    similarMovies = await tmdbwithcustomlogs.v3.movies.getSimilar(id);
    similar = similarMovies['results'];
    return similar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: ListView(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(
                              'https://image.tmdb.org/t/p/w500' +
                                  backdrop_path))),
                ),
                Container(
                  width: double.infinity,
                  height: 50,
                  color: Colors.red[100],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      height: 150,
                      width: 100,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(
                                  'https://image.tmdb.org/t/p/w500' +
                                      poster_path))),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      alignment: Alignment.topCenter,
                      width: MediaQuery.of(context).size.height * 0.25,
                      child: Text(
                        title,
                        style: TextStyle(
                            fontSize: 17,
                            decoration: TextDecoration.none,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            //Visibility(visible: dataLoading, child: LinearProgressIndicator()),
            FutureBuilder(
                future: movieDataDetails(),
                builder: (builder, snapshot) {
                  if (snapshot.data == null) {
                    dataLoading = true;
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    dataLoading = false;
                    return Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(8),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Overview',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                decoration: TextDecoration.none),
                          ),
                          Text(
                            snapshot.data['overview'],
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                decoration: TextDecoration.none),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text(
                            'Status',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                decoration: TextDecoration.none),
                          ),
                          Text(
                            snapshot.data['status'],
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                decoration: TextDecoration.none),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text(
                            'Release Date',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                decoration: TextDecoration.none),
                          ),
                          Text(
                            snapshot.data['release_date'],
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                decoration: TextDecoration.none),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text(
                            'Budget',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                decoration: TextDecoration.none),
                          ),
                          Text(
                            '\$${snapshot.data['budget']}',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                decoration: TextDecoration.none),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text(
                            'Revenue',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                decoration: TextDecoration.none),
                          ),
                          Text(
                            '\$${snapshot.data['revenue']}',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                decoration: TextDecoration.none),
                          ),
                        ],
                      ),
                    );
                  }
                }),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: Text(
                'Cast Credits',
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.white,
                    fontSize: 20),
              ),
            ),
            FutureBuilder(
                future: movieCastDetails(),
                builder: (builder, snapshot) {
                  if (snapshot.data == null) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Container(
                      height: 270,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return (snapshot.data[index]['profile_path'] !=
                                        null &&
                                    snapshot.data[index]['name'] != null &&
                                    snapshot.data[index]['character'] != null)
                                ? Column(
                                    children: [
                                      Container(
                                        height: 140,
                                        width: 90,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: NetworkImage(
                                                    'https://image.tmdb.org/t/p/w500' +
                                                        snapshot.data[index]
                                                            ['profile_path']))),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(left: 10),
                                        height: 100,
                                        width: 90,
                                        color: Colors.black45,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              snapshot.data[index]['name'],
                                              style: TextStyle(
                                                decoration: TextDecoration.none,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              snapshot.data[index]['character'],
                                              style: TextStyle(
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontSize: 12),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                : Container();
                          }),
                    );
                  }
                }),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: Text(
                'Crew Credits',
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.white,
                    fontSize: 20),
              ),
            ),
            FutureBuilder(
                future: movieCrewDetails(),
                builder: (builder, snapshot) {
                  if (snapshot.data == null) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Container(
                      height: 270,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return (snapshot.data[index]['profile_path'] !=
                                        null &&
                                    snapshot.data[index]['name'] != null &&
                                    snapshot.data[index]['job'] != null)
                                ? Column(
                                    children: [
                                      Container(
                                        height: 140,
                                        width: 90,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: NetworkImage(
                                                    'https://image.tmdb.org/t/p/w500' +
                                                        snapshot.data[index]
                                                            ['profile_path']))),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(left: 10),
                                        height: 100,
                                        width: 90,
                                        color: Colors.black45,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              snapshot.data[index]['name'],
                                              style: TextStyle(
                                                decoration: TextDecoration.none,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              snapshot.data[index]['job'],
                                              style: TextStyle(
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontSize: 12),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                : Container();
                          }),
                    );
                  }
                }),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: Text(
                'Similar Movies',
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.white,
                    fontSize: 20),
              ),
            ),
            FutureBuilder(
                future: similarMoviesdetails(),
                builder: (builder, snapshot) {
                  if (snapshot.data == null) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Container(
                      height: 270,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Container(
                                  height: 140,
                                  width: 90,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.fill,
                                          image: NetworkImage(
                                              'https://image.tmdb.org/t/p/w500' +
                                                  snapshot.data[index]
                                                      ['poster_path']))),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 10),
                                  height: 100,
                                  width: 90,
                                  color: Colors.black45,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        snapshot.data[index]['title'],
                                        style: TextStyle(
                                          decoration: TextDecoration.none,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        snapshot.data[index]['release_date'],
                                        style: TextStyle(
                                            decoration: TextDecoration.none,
                                            fontSize: 12),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            );
                          }),
                    );
                  }
                }),
          ],
        ));
  }
} */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:movies_app/peopledetails.dart';
import 'package:movies_app/trailerplay.dart';
import 'package:movies_app/video%20streaming/moviePlay.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'admob_sevices.dart';

class MoviesDetails extends StatefulWidget {
  const MoviesDetails(
      {Key key,
      @required this.id,
      this.poster_path,
      this.backdrop_path,
      this.tmdbwithcustomlogs,
      this.title,
      this.heroID,
      this.hero})
      : super(key: key);
  final int id;
  final String poster_path, backdrop_path;
  final TMDB tmdbwithcustomlogs;
  final String title;
  final String heroID;
  final int hero;

  @override
  _MoviesDetailsState createState() => _MoviesDetailsState();
}

class _MoviesDetailsState extends State<MoviesDetails> {
  Map movieDetails;
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

  Map _details;
  List _data = [];
  String trailerId = 'xxxxx';

  _getTrailerData() async {
    _details = await tmdbwithcustomlogs.v3.movies.getVideos(id);
    _data = _details['results'];
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

  Future movieDataDetails() async {
    movieDetails = await tmdbwithcustomlogs.v3.movies.getDetails(id);
    return movieDetails;
  }

  Future movieCastDetails() async {
    castCredits = await tmdbwithcustomlogs.v3.movies.getCredits(id);
    cast = castCredits['cast'];
    return cast;
  }

  Future movieCrewDetails() async {
    crewCredits = await tmdbwithcustomlogs.v3.movies.getCredits(id);
    crew = crewCredits['crew'];
    return crew;
  }

  Future similarMoviesdetails() async {
    similarMovies = await tmdbwithcustomlogs.v3.movies.getSimilar(id);
    similar = similarMovies['results'];
    return similar;
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
                  tag: widget.hero == 1 ? widget.heroID ?? '' : "",
                  child: Container(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
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
                      ],
                    ),
                  ),
                ),
                title: Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                    //imageColor != null ? imageColor.bodyTextColor : null
                  ),
                  overflow: TextOverflow.ellipsis,
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
                    // Row(
                    //   children: [],
                    // ),
                    //Visibility(visible: dataLoading, child: LinearProgressIndicator()),
                    FutureBuilder(
                        future: movieDataDetails(),
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
                              padding: EdgeInsets.only(
                                left: 8,
                                right: 8,
                                bottom: 8,
                                top: 2,
                              ),
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Hero(
                                        tag: widget.hero == 2
                                            ? widget.heroID ?? ''
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
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (builder) =>
                                                            MoviePaly(
                                                          movieID: id,
                                                          title: title,
                                                        ),
                                                      ),
                                                    );
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
                                        color: Colors.white),
                                  ),
                                  Text(
                                    snapshot.data['overview'] != null
                                        ? snapshot.data['overview']
                                        : 'null',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 18,
                                      //fontWeight: FontWeight.bold,
                                      //color: imageColor != null
                                      //    ? imageColor.bodyTextColor
                                      //    : null,
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
                                      //fontWeight: FontWeight.bold,
                                      //color: imageColor != null
                                      //    ? imageColor.bodyTextColor
                                      //    : null,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    'Release Date',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      //color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    snapshot.data['release_date'] != null
                                        ? snapshot.data['release_date']
                                        : 'null',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 18,
                                      //fontWeight: FontWeight.bold,
                                      //color: imageColor != null
                                      //    ? imageColor.bodyTextColor
                                      //    : null,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    'Budget',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      //color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    snapshot.data['budget'] != null
                                        ? '\$${snapshot.data['budget']}'
                                        : '0',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 18,
                                      //fontWeight: FontWeight.bold,
                                      //color: imageColor != null
                                      //   ? imageColor.bodyTextColor
                                      //    : null,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    'Revenue',
                                    style: GoogleFonts.notoSans(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  Text(
                                    snapshot.data['revenue'] != null
                                        ? '\$${snapshot.data['revenue']}'
                                        : '0',
                                    style: GoogleFonts.notoSans(
                                        fontSize: 18,
                                        //fontWeight: FontWeight.bold,
                                        color: imageColor != null
                                            ? imageColor.bodyTextColor
                                            : null),
                                  ),
                                ],
                              ),
                            );
                          }
                        }),
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
                          future: movieCastDetails(),
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
                                                      radius: 60,
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
                                                        Flexible(
                                                          child: Text(
                                                            snapshot.data[index]
                                                                    ['name'] ??
                                                                '',
                                                            style: GoogleFonts
                                                                .notoSans(),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 2,
                                                        ),
                                                        Flexible(
                                                          child: Text(
                                                            snapshot.data[index]
                                                                    [
                                                                    'character'] ??
                                                                '',
                                                            style: GoogleFonts
                                                                .notoSans(
                                                                    color: Colors
                                                                        .white70),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
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
                    _isNativeAdLoaded
                        ? Container(
                            height: 110,
                            child: AdWidget(
                              ad: Platform.isAndroid
                                  ? _ad
                                  : AdmobService.createMoviePageBannerAd()
                                ..load(),
                            ),
                          )
                        : Container(),
                    Visibility(
                      visible: crew.isEmpty ? false : true,
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
                      visible: crew.isEmpty ? false : true,
                      child: FutureBuilder(
                          future: movieCrewDetails(),
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
                                                      radius: 60,
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
                                                        Flexible(
                                                          child: Text(
                                                            snapshot.data[index]
                                                                    ['name'] ??
                                                                '',
                                                            style: GoogleFonts
                                                                .notoSans(),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
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
                    Visibility(
                      visible: similar.isEmpty ? false : true,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'Similar Movies',
                          style: GoogleFonts.notoSans(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: similar.isEmpty ? false : true,
                      child: FutureBuilder(
                          future: similarMoviesdetails(),
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
                                      return InkWell(
                                        onTap: () {
                                          showInterstitialAd();
                                          print(snapshot.data);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MoviesDetails(
                                                        tmdbwithcustomlogs:
                                                            tmdbwithcustomlogs,
                                                        backdrop_path: snapshot
                                                                .data[index]
                                                            ['backdrop_path'],
                                                        id: snapshot.data[index]
                                                            ['id'],
                                                        poster_path:
                                                            snapshot.data[index]
                                                                ['poster_path'],
                                                        title:
                                                            snapshot.data[index]
                                                                ['title'],
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
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                                image: DecorationImage(
                                                  fit: BoxFit.fill,
                                                  image: snapshot.data[index]
                                                              ['poster_path'] !=
                                                          null
                                                      ? NetworkImage(
                                                          'https://image.tmdb.org/t/p/w500' +
                                                              snapshot.data[
                                                                      index][
                                                                  'poster_path'])
                                                      : AssetImage(
                                                          'assets/loading.gif'),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  EdgeInsets.only(left: 10),
                                              height: 80,
                                              width: 110,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      snapshot.data[index]
                                                              ['title'] ??
                                                          '',
                                                      style: GoogleFonts
                                                          .notoSans(),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    snapshot.data[index]
                                                            ['release_date'] ??
                                                        '',
                                                    style: GoogleFonts.notoSans(
                                                        fontSize: 12),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    }),
                              );
                            }
                          }),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                        height: 50,
                        child: AdWidget(
                          ad: AdmobService.createMoviePageBannerAd()..load(),
                        )),
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
