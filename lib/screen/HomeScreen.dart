import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_generator/data/data_shared_preferences.dart';
import 'package:qr_generator/model/QRData_model.dart';
import 'package:qr_generator/screen/Setting_Screen.dart';
import '../model/QR_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAutoUpdateQR = true;
  late String _preFix = "VFast";
  late String _subFix = "TimeKeeping";
  late QRData_model _qrData = QRData_model(_preFix, DateTime.now().toString(), _subFix);
  late int _timeSecWait = 10;
  late Timer _timeCount;                                                                    // For run update QR after timeSecWait seconds
  late QR_Model _qr = QR_Model(decodeBase64(_qrData.toString()), QrVersions.auto, 200);     // config qr image
  late int _secondsRemaining = _timeSecWait;                                                // use for showing time countDown\
  final DataManager _dataManager = DataManager();

  @override
  void initState(){
    super.initState();
    loadData();
    autoReload();
  }

  void loadData() async {
    try {
      _timeSecWait = await _dataManager.getTimeSecWait();
      _preFix = await _dataManager.getPreFix();
      _subFix = await _dataManager.getSubFix();
      _qrData = QRData_model(_preFix,DateTime.now().toString(),_subFix);
      _qr = QR_Model( decodeBase64(_qrData.toString()), QrVersions.auto, await _dataManager.getQRSize());
      _secondsRemaining = _timeSecWait;
    } catch (e) {
      print("Error: ${e.toString()}");
    }
  }

  void toggleState() {
    setState(() {
      _isAutoUpdateQR = !_isAutoUpdateQR;
    });
    if (_isAutoUpdateQR) {
      loadData();
      autoReload();
    } else{
      stopReload();
    }
  }

  //Run updateQR
  void autoReload (){
    _timeCount = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsRemaining--;
        if (_secondsRemaining <= 0) {
          updateQR();
          _secondsRemaining = _timeSecWait;
        }
      });
    });
  }

  void stopReload(){
    setState(() {
      _timeSecWait = 0;
    });
    if(_timeCount.isActive) {
      _timeCount.cancel();
      _secondsRemaining = _timeSecWait;
    }
  }

  //Update QR
  void updateQR(){
    setState(() {
      _qrData = QRData_model(_preFix,DateTime.now().toString(),_subFix);
      _qr.data = decodeBase64(_qrData.toString());
    });
  }

  //decode String
  String decodeBase64(String str){
    var bytes = utf8.encode(str);
    var base64Str = base64.encode(bytes);
    return base64Str;
  }
  @override
  void dispose() {
    _timeCount.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "QR Generator",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blue[300],
        actions: [
          IconButton(
            onPressed:(){
              Navigator.push(
                context,
                //navigate animation slide up
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => SettingScreen(
                      preFix: _preFix,
                      subFix: _subFix,
                      sizeQR: _qr.size,
                      timeAutoReset: _timeSecWait,
                      onSave:  (int updatedTimeAutoReset, String updatedPreFix, String updatedSubFix , double updatedSizeQr){
                        setState(() {
                          stopReload();
                          _timeSecWait = updatedTimeAutoReset;
                          _preFix = updatedPreFix;
                          _subFix = updatedSubFix;
                          _qr.size = updatedSizeQr;

                          if(updatedTimeAutoReset != 0) {
                            _isAutoUpdateQR = true;
                            autoReload();
                          }
                          else {
                            _isAutoUpdateQR = false;
                            stopReload();
                          }
                        });
                      },
                  ),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOutQuart;
                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);
                    return SlideTransition(position: offsetAnimation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 750),
                  reverseTransitionDuration: const Duration(milliseconds: 750),
                ),
              );
            },
            icon: const Icon(Icons.settings),
            tooltip: "Setting",
          ),
        ],
      ),
      body: Container(
        color: Colors.blue[300],
        child: Container(
          margin: EdgeInsets.symmetric(vertical: screenHeight * 0.07, horizontal: screenWidth * 0.07),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(45), topRight: Radius.circular(45),
              bottomLeft: Radius.circular(45), bottomRight: Radius.circular(45),
            ),
            color: Colors.blue[100],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _timeSecWait == 0 ? "Auto update QR turn off" : "Time Remaining : $_secondsRemaining",
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20,),
                QrImageView(
                  data: _qr.data,
                  version: _qr.version,
                  size: _qr.size,
                ),
                const SizedBox(height: 10,),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: Text(_qr.data,)
                ),
                const SizedBox(height: 50,),
                ElevatedButton(
                  onPressed: () => toggleState(),
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(80, 80),
                    elevation: 10,
                    backgroundColor: _isAutoUpdateQR ? Colors.red[800] : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _isAutoUpdateQR ? "Stop" : "Start",
                    style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
