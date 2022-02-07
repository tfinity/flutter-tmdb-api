import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MoviePaly extends StatefulWidget {
  const MoviePaly(
      {Key key, this.movieID, this.isMovie = true, this.tvID, this.title})
      : super(key: key);
  final int movieID;
  final bool isMovie;
  final String tvID;
  final String title;

  @override
  _MoviePalyState createState() => _MoviePalyState();
}

class _MoviePalyState extends State<MoviePaly> {
  WebViewController _webController;
  String movieUrl = 'https://fsapi.xyz/tmdb-movie/';
  String tvUrl = 'https://fsapi.xyz/tv-tmdb/';
  String initUrl;
  @override
  void initState() {
    if (widget.isMovie)
      initUrl = movieUrl + widget.movieID.toString();
    else
      initUrl = tvUrl + widget.tvID;
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  Future<bool> _onBackPress() async {
    if (await _webController.canGoBack()) {
      await _webController.goBack();
    } else {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Strop Streaming?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('No')),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Yes')),
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WillPopScope(
      onWillPop: _onBackPress,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: GoogleFonts.notoSans(),
          ),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ),
        body: WebView(
          initialUrl: initUrl,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController controller) {
            _webController = controller;
          },
        ),
      ),
    ));
  }
}
