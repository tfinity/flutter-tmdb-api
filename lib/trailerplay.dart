import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:movies_app/admob_sevices.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:tmdb_api/tmdb_api.dart';

class TrailerPlay extends StatefulWidget {
  const TrailerPlay(
      {Key key, this.id, this.tmdbwithcustomlogs, this.trailerkey})
      : super(key: key);
  final int id;
  final TMDB tmdbwithcustomlogs;
  final String trailerkey;

  @override
  _TrailerPlayState createState() => _TrailerPlayState();
}

class _TrailerPlayState extends State<TrailerPlay> {
  Map _details;
  int id;
  TMDB tmdbwithcustomlogs;
  List _data = [];
  //String trailerId;
  bool keyFound = false;
  bool noTrailer = false;

  @override
  void initState() {
    id = widget.id;
    tmdbwithcustomlogs = widget.tmdbwithcustomlogs;
    _getTrailerData();
    print('keyintrailer: ${widget.trailerkey}');
    _controller = YoutubePlayerController(
        initialVideoId: widget.trailerkey,
        params: YoutubePlayerParams(
            autoPlay: true, showControls: true, showFullscreenButton: false));

    super.initState();
  }

  YoutubePlayerController _controller;

  _getTrailerData() async {
    _details = await tmdbwithcustomlogs.v3.movies.getVideos(id);
    _data = _details['results'];
    for (int x = 0; x < _data.length; x++) {
      if (_data[x]['key'] != null) {
        // trailerId = _data[x]['key'];
        //print('id: $trailerId');
        keyFound = true;
        setState(() {});
        return;
      }
    }
    noTrailer = true;
    setState(() {});
    print(_details);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
              tooltip: 'Go Back',
              icon: Icon(
                Icons.arrow_back,
                size: 35,
              ),
              onPressed: () => Navigator.of(context).pop()),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Center(
              child: keyFound
                  ? YoutubePlayerIFrame(
                      controller: _controller,
                      aspectRatio: 16 / 9,
                    )
                  : noTrailer
                      ? Text(
                          'No Trailer Avaiable',
                          style: TextStyle(color: Colors.white),
                        )
                      : Image(image: AssetImage('assets/loading.gif')),
            )),
            Container(
                height: 50,
                child: AdWidget(
                  ad: AdmobService.createTrailerPageBannerAd()..load(),
                )),
          ],
        ),
      ),
    );
  }
}
