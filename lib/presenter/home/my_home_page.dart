import 'dart:io';

import 'package:Shopping/domain/cases/controller.dart';
import 'package:Shopping/domain/entities/product_entity.dart';
import 'package:Shopping/domain/settings/settings.dart';
import 'package:Shopping/presenter/components/button_confirm_component.dart';
import 'package:Shopping/presenter/components/button_listen_component.dart';
import 'package:Shopping/presenter/components/product_item_component.dart';
import 'package:Shopping/tools/dialog_Ask.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const _noShowHelpKey = 'no_show_help_key';
  late InterstitialAd interstitialAd;
  late Controller _controller;
  var _products = <ProductEntity>[];
  var _client = 'client';
  var _showNotice = false;
  var _showAddProduct = true;
  
  var _loaded = false;
  var _confirmValue = false;
  var _isWait = false;
  var _value = '';
  var _totalCost = 0.0;
  var _noShowHelp = false;

  static final AdRequest request = AdRequest(
      keywords: <String>['foo', 'bar'],
      contentUrl: 'http://foo.com/bar.html',
      nonPersonalizedAds: true,
    );

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  static const int maxFailedLoadAttempts = 3;

  BannerAd? _anchoredAdaptiveAd;
  var _isBannerAdReady = false;
  late Orientation _currentOrientation;

  var _pass = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(!_pass) {
      _currentOrientation = MediaQuery.of(context).orientation;
      _loadAd();
    }
    _pass = true;
  }

  Future<void> _loadAd() async {
    await _anchoredAdaptiveAd?.dispose();
    setState(() {
      _anchoredAdaptiveAd = null;
      _isBannerAdReady = false;
    });

    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: Platform.isAndroid
          ? Settings.admodAndroidBannerKey
          : Settings.admodIOSBannerKey,
      size: size,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$ad loaded: ${ad.responseInfo}');
          setState(() {
            // When the ad is loaded, get the ad size and use it to set
            // the height of the ad container.
            _anchoredAdaptiveAd = ad as BannerAd;
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Anchored adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );
    return _anchoredAdaptiveAd!.load();
  }

   /// Gets a widget containing the ad, if one is loaded.
  ///
  /// Returns an empty container if no ad is loaded, or the orientation
  /// has changed. Also loads a new ad if the orientation changes.
  Widget _getAdWidget() {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (_currentOrientation == orientation &&
            _anchoredAdaptiveAd != null &&
            _isBannerAdReady) {
          return Container(
            color: Colors.green,
            width: _anchoredAdaptiveAd!.size.width.toDouble(),
            height: _anchoredAdaptiveAd!.size.height.toDouble(),
            child: AdWidget(ad: _anchoredAdaptiveAd!),
          );
        }
        // Reload the ad if the orientation changes.
        if (_currentOrientation != orientation) {
          _currentOrientation = orientation;
          _loadAd();
        }
        return Container();
      },
    );
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? Settings.admodAndroidInterstitialKey
            : Settings.admodIOSInterstitialKey,
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  
  void _loadData() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      _loaded = false;
    });
    var noShowHelp = prefs.getBool(_noShowHelpKey)??false;
    var products = await _controller.getProducts(_client);
    setState(() {
      _loaded = true;
      _products = products;
      _noShowHelp = noShowHelp;
      _showNotice = !_noShowHelp;
    });
    _calculeTotalCost();
  }

  void _calculeTotalCost() {
    var totalCost = 0.0;
    for (var product in _products) {
      totalCost += product.cost;
    }

    setState(() {
      _totalCost = totalCost;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = Controller();
    _loadData();
    MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: []));
    _createInterstitialAd();
  }

  String? getBannerAdUnitId() {
    if (Platform.isIOS) {
      return Settings.admodIOSBannerKey;
    } else if (Platform.isAndroid) {
      return Settings.admodAndroidBannerKey;
    }
    return null;
  }

  String? getInterstitialAdUnitId() {
    if (Platform.isIOS) {
      return Settings.admodIOSInterstitialKey;
    } else if (Platform.isAndroid) {
      return Settings.admodAndroidInterstitialKey;
    }
    return null;
  }

  
  @override
  void dispose() {
    interstitialAd.dispose();
    _anchoredAdaptiveAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[800],
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: _getAdWidget(),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Image.asset('assets/images/ic_launcher.png', width: 30, height: 30),
                  )
                ),
                if (!_loaded)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
                if (_loaded)
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _onClean, 
                            icon: const Icon(Icons.clear_all_rounded, color: Colors.white), 
                            label: Text('New list', style: Theme.of(context).textTheme.displayMedium)
                          ),
                          Text(_products.length.toString(), style: Theme.of(context).textTheme.displayMedium),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if(_totalCost <= 0.0)
                                Text('Total cost', style: Theme.of(context).textTheme.displayMedium),
                                if(_totalCost > 0.0)
                                Text(_totalCost.toString(), style: Theme.of(context).textTheme.displayMedium),
                                const SizedBox(width: 20),
                                InkWell(
                                  onTap: _onHelp,
                                  child: const Icon(Icons.help_rounded, color: Colors.white),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(thickness: 1, height: 1, color: Colors.white),
                      if(_products.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 20, bottom: 250, left: 10, right: 10),
                          itemCount: _products.length,
                          itemBuilder:(context, index) {
                            return ProductItemComponent(
                              controller: _controller, 
                              product: _products[index], 
                              showDelete: (index+1) == _products.length,
                              onEdit: _onEditProduct,
                              onCheck: _onCheckProduct, 
                              onChange: _onChangeProduct,
                              onCancel: _onCancelProduct,
                              onDelete: _onDeleteProduct,
                            );
                          },
                        ),
                      )
                    ],
                  )
                ),
              ],
            ),
            if (_loaded && _showAddProduct)
            Align(
              alignment: Alignment.bottomCenter,
              child: 
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if(_confirmValue)
                    ButtonConfirmComponent(
                      value: _value, 
                      onOk: _addProduct,
                      onCancel: _onCancel,
                    ),
                    if(!_confirmValue && !_isWait)
                    ButtonListenComponent(
                      onChange: _onListenSpeech,
                      onError: _onErrorSpeech,
                    ),
                    if(_isWait)
                    const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
            if(_showNotice)
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10, right: 10),
                          child: IconButton(
                            onPressed: _onCloseNotice, 
                            icon: const Icon(Icons.close_rounded)
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40, bottom: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Now to add a product press the microphone, speak and press the confirmation, or simply press the small keyboard at the bottom right, the microphones of the products are to add a cost, to delete swipe left.', style: TextStyle(color: Colors.grey[700], fontSize: 18)),
                          CheckboxListTile(
                            title: const Text('No show again!'),
                            value: _noShowHelp, 
                            onChanged: (value) {
                              setState(() {
                                _noShowHelp = value??false;
                              });
                            }
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_loaded && _showAddProduct)
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20)
                ),
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(2),
                child: IconButton(
                  onPressed: _onShowKeyboard, 
                  icon: const Icon(Icons.keyboard, color: Colors.white, size: 30)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onListenSpeech(String value) async {
    setState(() {
      _value = value;
      _isWait = true;
      _confirmValue = true;
      _isWait = false;
    });
  }


  void _onErrorSpeech() {
    print('Error speech');
    setState(() {
      _isWait = false;
    });
  }

  void _addProduct(String value) {
    if(value.trim().isNotEmpty) {
      var product = ProductEntity(
        name: value,
      );
      _controller.insertProduct(product);
      setState(() {
        _products = _controller.products;
        _confirmValue = false;
        _isWait = false;
      });
    }
  }

  void _onCancel() {
    setState(() {
      _value = '';
      _confirmValue = false;
      _isWait = false;
    });
  }

  void _onClean() {
    DialogAsk.show(
      context: context, 
      title: 'New list', 
      content: const Text('The current list will be deleted. Do you want to continue?'), 
      onYes: _cleanAll, 
      onNo: () async {
        _showInterstitialAd();
      }
    );
  }

  _cleanAll() async {
    _controller.cleanAll();
    setState(() {
      _products = _controller.products;
      _totalCost = 0.0;
    });
    _showInterstitialAd();
  }

  void _onCheckProduct(ProductEntity productEntity) {
  }

  void _onChangeProduct(ProductEntity productEntity) async {
    await _controller.updateProduct(productEntity);
    _calculeTotalCost();
    setState(() {
      _showAddProduct = true;
    });
  }

  void _onDeleteProduct(ProductEntity productEntity) {
    _products.remove(productEntity);
    _controller.deleteProduct(productEntity);
    _calculeTotalCost();
  }

  void _onCloseNotice() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      _showNotice = false;
    });
    prefs.setBool(_noShowHelpKey, _noShowHelp);
  }

  void _onHelp() {
    setState(() {
      _showNotice = true;
    });
  }

  void _onEditProduct(ProductEntity productEntity) {
    setState(() {
      _showAddProduct = false;
    });
  }

  void _onShowKeyboard() {
    setState(() {
      _value = '';
      _confirmValue = true;
    });
  }

  void _onCancelProduct(ProductEntity productEntity) {
    setState(() {
      _showAddProduct = true;
    });
  }
}