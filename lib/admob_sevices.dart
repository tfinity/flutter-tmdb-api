import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobService {
  static String get searchPagebannerAdUnitId =>
      'ca-app-pub-9826383179102622/7194465361';

  static initialize() {
    if (MobileAds.instance == null) {
      MobileAds.instance.initialize();
    }
  }

  static BannerAd createSearchPageBannerAd() {
    BannerAd ad = BannerAd(
        size: AdSize.banner,
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/6300978111'
            : 'ca-app-pub-9826383179102622/7194465361',
        listener: BannerAdListener(
          onAdClosed: (Ad ad) => ad.dispose(),
          onAdFailedToLoad: (Ad ad, LoadAdError error) => ad.dispose(),
        ),
        request: AdRequest());
    return ad;
  }

  static BannerAd createMoviePageBannerAd() {
    BannerAd ad = BannerAd(
        size: AdSize.banner,
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/6300978111'
            : 'ca-app-pub-9826383179102622/7194465361',
        listener: BannerAdListener(
          onAdClosed: (Ad ad) => ad.dispose(),
          onAdFailedToLoad: (Ad ad, LoadAdError error) => ad.dispose(),
        ),
        request: AdRequest());
    return ad;
  }

  static BannerAd createTvPageBannerAd() {
    BannerAd ad = BannerAd(
        size: AdSize.banner,
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/6300978111'
            : 'ca-app-pub-9826383179102622/7194465361',
        listener: BannerAdListener(
          onAdClosed: (Ad ad) => ad.dispose(),
          onAdFailedToLoad: (Ad ad, LoadAdError error) => ad.dispose(),
        ),
        request: AdRequest());
    return ad;
  }

  static BannerAd createPeoplePageBannerAd() {
    BannerAd ad = BannerAd(
        size: AdSize.banner,
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/6300978111'
            : 'ca-app-pub-9826383179102622/7194465361',
        listener: BannerAdListener(
          onAdClosed: (Ad ad) => ad.dispose(),
          onAdFailedToLoad: (Ad ad, LoadAdError error) => ad.dispose(),
        ),
        request: AdRequest());
    return ad;
  }

  static BannerAd createTrailerPageBannerAd() {
    BannerAd ad = BannerAd(
        size: AdSize.banner,
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/6300978111'
            : 'ca-app-pub-9826383179102622/7194465361',
        listener: BannerAdListener(
          onAdClosed: (Ad ad) => ad.dispose(),
          onAdFailedToLoad: (Ad ad, LoadAdError error) => ad.dispose(),
        ),
        request: AdRequest());
    return ad;
  }

  static BannerAd createMainMoviePagePageBannerAd() {
    BannerAd ad = BannerAd(
        size: AdSize.banner,
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/6300978111'
            : 'ca-app-pub-9826383179102622/7194465361',
        listener: BannerAdListener(
          onAdClosed: (Ad ad) => ad.dispose(),
          onAdFailedToLoad: (Ad ad, LoadAdError error) => ad.dispose(),
        ),
        request: AdRequest());
    return ad;
  }

  static BannerAd createMaintvPagePageBannerAd() {
    BannerAd ad = BannerAd(
        size: AdSize.banner,
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/6300978111'
            : 'ca-app-pub-9826383179102622/7194465361',
        listener: BannerAdListener(
          onAdClosed: (Ad ad) => ad.dispose(),
          onAdFailedToLoad: (Ad ad, LoadAdError error) => ad.dispose(),
        ),
        request: AdRequest());
    return ad;
  }

  InterstitialAd _interstitialad;

  int num_of_attempt_load = 0;

  void creatMainPageInterstitial() {
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
            creatMainPageInterstitial();
          }
        }));
  }

  void showMainPageInterstitial() {
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
    }, onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
      print('ad failed to show');
      ad.dispose();
      creatMainPageInterstitial();
    }, onAdShowedFullScreenContent: (_) {
      print('ad showing');
    });
    _interstitialad.show();
    //_interstitialad = null;
  }
}
