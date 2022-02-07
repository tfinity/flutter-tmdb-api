import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'details.dart';

class MoviesTab extends StatefulWidget {
  const MoviesTab(
      {Key key, this.tmdbwithcustomlogs, this.showIndex, this.headTitle})
      : super(key: key);
  final TMDB tmdbwithcustomlogs;
  final int showIndex;
  final String headTitle;

  @override
  _MoviesTabState createState() => _MoviesTabState();
}

class _MoviesTabState extends State<MoviesTab> {
  TMDB tmdbwithcustomlogs;
  List movies = [];
  ScrollController _movieScrollController = ScrollController();
  NativeAd _ad;
  bool _isNativeAdLoaded = false;
  int showIndex;

  @override
  void initState() {
    creatInterstitialAd();
    showIndex = widget.showIndex;
    tmdbwithcustomlogs = widget.tmdbwithcustomlogs;
    moviesData();
    if (maxMoviesIndex > movieIndex) {
      _movieScrollController.addListener(() {
        if (_movieScrollController.position.pixels ==
            _movieScrollController.position.maxScrollExtent) {
          setState(() {
            getMoreMovies();
          });
        }
      });
    }
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

  int movieIndex = 2;
  int maxMoviesIndex = 3;

  getMoreMovies() async {
    Map trendingMovies;
    switch (showIndex) {
      case 0:
        trendingMovies =
            await tmdbwithcustomlogs.v3.movies.getNowPlaying(page: movieIndex);
        break;
      case 1:
        trendingMovies =
            await tmdbwithcustomlogs.v3.movies.getPouplar(page: movieIndex);
        break;
      case 2:
        trendingMovies =
            await tmdbwithcustomlogs.v3.movies.getUpcoming(page: movieIndex);
        break;
      case 3:
        trendingMovies =
            await tmdbwithcustomlogs.v3.movies.getTopRated(page: movieIndex);
        break;
      default:
    }
    List newMovies = trendingMovies['results'];
    for (int i = 0; i < newMovies.length; i++) movies.add(newMovies[i]);
    //print(newMovies.length);
    /* for (int i = 0; i < newMovies.length; i++) {
      if (i == 13 && _isNativeAdLoaded) {
        AdWidget adWidget = AdWidget(ad: _ad);
        movieWithAds.insert(i, adWidget);
      }
      movieWithAds.add(newMovies[i]);
    } */

    movieIndex++;
    setState(() {});
  }

  //List movieWithAds = [];

  Future moviesData() async {
    Map trendingMovies;
    switch (showIndex) {
      case 0:
        trendingMovies = await tmdbwithcustomlogs.v3.movies.getNowPlaying();
        break;
      case 1:
        trendingMovies = await tmdbwithcustomlogs.v3.movies.getPouplar();
        break;
      case 2:
        trendingMovies = await tmdbwithcustomlogs.v3.movies.getUpcoming();
        break;
      case 3:
        trendingMovies = await tmdbwithcustomlogs.v3.movies.getTopRated();
        break;
      default:
    }

    movies = trendingMovies['results'];
    maxMoviesIndex = trendingMovies['total_pages'];
    /* movieWithAds = List.from(movies);
    for (int i = 0; i < movies.length; i++) {
      if (i == 13 && _isNativeAdLoaded) {
        AdWidget adWidget = AdWidget(ad: _ad);
        movieWithAds.insert(i, adWidget);
      }
    }
    print('moviewithads ${movieWithAds[1]}');
    print('movie $movies'); */
    setState(() {});
    return movies;
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
          controller: _movieScrollController,
          crossAxisCount: 3,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          itemCount: movies.length + 2,
          shrinkWrap: false,
          itemBuilder: (builder, index) {
            if (index == movies.length ||
                movies.isEmpty ||
                index == movies.length + 1) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } /* else if (index % 13 == 0 && index != 0) {
              return Container(
                height: 72,
                child: movieWithAds[index],
              );
            }  */
            else {
              return movies[index]['poster_path'] != null
                  ? InkWell(
                      onTap: () {
                        if (index % 4 == 0) {
                          showInterstitialAd();
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MoviesDetails(
                              tmdbwithcustomlogs: tmdbwithcustomlogs,
                              backdrop_path: movies[index]['backdrop_path'],
                              id: movies[index]['id'],
                              poster_path: movies[index]['poster_path'],
                              title: movies[index]['title'],
                              heroID: movies[index]['poster_path'],
                              hero: 2,
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: movies[index]['poster_path'] ?? '',
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: movies[index]['poster_path'] !=
                                              null
                                          ? NetworkImage(
                                              'https://image.tmdb.org/t/p/w500' +
                                                  movies[index]['poster_path'])
                                          : AssetImage('assets/loading.gif'),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    width: 90,
                                    child: Text(
                                      movies[index]['title'] != null
                                          ? movies[index]['title']
                                          : '',
                                      style: GoogleFonts.notoSans(fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      /* Container(
                        alignment: Alignment.bottomCenter,
                        height: 250,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image: NetworkImage(
                                    'https://image.tmdb.org/t/p/w500' +
                                        movies[index]['poster_path']))),
                        child: FractionallySizedBox(
                          widthFactor: 1,
                          child: Container(
                            // height: 10,
                            color: Colors.black54,
                            child: Text(
                              movies[index]['title'] != null
                                  ? movies[index]['title']
                                  : '',
                              style: GoogleFonts.oswald(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ), */
                      )
                  : Container();
            }
          },
          /* children: List.generate(movies.length + 2, (index) {
              print(movies.length);
              if (index == movies.length ||
                  movies.isEmpty ||
                  index == movies.length + 1) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else
                return movies[index]['poster_path'] != null
                    ? InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MoviesDetails(
                                        tmdbwithcustomlogs: tmdbwithcustomlogs,
                                        backdrop_path: movies[index]
                                            ['backdrop_path'],
                                        id: movies[index]['id'],
                                        poster_path: movies[index]['poster_path'],
                                        title: movies[index]['title'],
                                      )));
                        },
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          height: 250,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(
                                      'https://image.tmdb.org/t/p/w500' +
                                          movies[index]['poster_path']))),
                          child: FractionallySizedBox(
                            widthFactor: 1,
                            child: Container(
                              // height: 10,
                              color: Colors.black54,
                              child: Text(
                                movies[index]['title'] != null
                                    ? movies[index]['title']
                                    : '',
                                style: GoogleFonts.oswald(),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container();
            }) */
        ),
      ),
    );
  }
}
