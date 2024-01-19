import 'package:flutter/material.dart';
import 'package:qr_generator/data/data_shared_preferences.dart';

typedef SaveSettingsCallback = void Function(int timeAutoReset, String preFix, String subFix, double sizeBox);

class SettingScreen extends StatefulWidget {
  final SaveSettingsCallback onSave;
  final int timeAutoReset;
  final double sizeQR;
  final String preFix;
  final String subFix;
  const SettingScreen({required this.onSave, required this.timeAutoReset, required this.preFix, required this.subFix, required this.sizeQR, super.key,});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final DataManager _dataManager = DataManager();
  late String inputTimeAutoReset;
  late String inputPreFix;
  late String inputSubFix;
  late String inputSizeQr;
  late TextEditingController controllerTimeAutoReset;
  late TextEditingController controllerPreFix;
  late TextEditingController controllerSubFix;
  late TextEditingController controllerSizeQr;

  @override
  void initState() {
    super.initState();
    controllerTimeAutoReset = TextEditingController(text: widget.timeAutoReset.toString());
    controllerPreFix = TextEditingController(text: widget.preFix);
    controllerSubFix = TextEditingController(text: widget.subFix);
    controllerSizeQr = TextEditingController(text: widget.sizeQR.toString());
  }

  _buildSettingTime() {
    return TextField(
      controller: controllerTimeAutoReset,
      decoration: const InputDecoration(labelText: 'Time to reload ( 0 - 3600 seconds)'),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          inputTimeAutoReset = value;
        });
      },
    );
  }

  _buildPrefix() {
    return TextField(
      controller: controllerPreFix,
      decoration: const InputDecoration(labelText: 'PreFix'),
      keyboardType: TextInputType.text,
      onChanged: (value) {
        setState(() {
          inputPreFix = value;
        });
      },
    );
  }

  _buildSubfix() {
    return TextField(
      controller: controllerSubFix,
      decoration: const InputDecoration(labelText: 'SubFix'),
      keyboardType: TextInputType.text,
      onChanged: (value) {
        setState(() {
          inputSubFix = value;
        });
      },
    );
  }

  _buildQrSize(){
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    double min = screenWidth * 0.2;
    double max = screenWidth * 0.86;
    return TextField(
      controller: controllerSizeQr,
      decoration: InputDecoration(labelText: "Qr Size (${min.round()} - ${max.round()} dp)"),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          inputSizeQr = value;
        });
      },
    );
  }

  void onSaveButtonClick() async {
    int updatedTimeAutoReset = int.parse(controllerTimeAutoReset.text);
    String updatedPreFix = controllerPreFix.text;
    String updatedSubFix = controllerSubFix.text;
    double updatedSizeQr = double.parse(controllerSizeQr.text);

    bool checkValTime = validateTimeSecWait(updatedTimeAutoReset);
    bool checkValQR = validateQRSize(updatedSizeQr);

    //validate
    if(checkValQR && checkValTime){
      String resultSaving = await _dataManager.isWrote(updatedTimeAutoReset, updatedPreFix, updatedSubFix, updatedSizeQr);
      if(resultSaving == "true"){
        widget.onSave(updatedTimeAutoReset, updatedPreFix, updatedSubFix, updatedSizeQr);
        showCustomSnackBar("Data saved successfully!", true);
      }else {
        showCustomSnackBar("Error saving data: $resultSaving", false);
      }
    }else{
      if(!checkValTime) showCustomSnackBar("Time to reload value must be 0 to 3600", false);
      if(!checkValQR) {
        final double screenWidth = MediaQuery.of(context).size.width;
        double min = screenWidth * 0.2;
        double max = screenWidth * 0.86;
        showCustomSnackBar("Qr size value must be ${min.round()} to ${max.round()}", false);
      }
    }
  }

  void showCustomSnackBar(String message, bool success) {
    if (ScaffoldMessenger.of(context).mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
    }
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: success ? Colors.green : Colors.red,
      //elevation: 1000,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20)
        ),
      ),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  bool validateTimeSecWait(int timeSecWait){
    if( timeSecWait < 0 ||  timeSecWait > 3600 || controllerTimeAutoReset.text.isEmpty) return false;
    return true;
  }
  bool validateQRSize(double qrSize){
    // final Size screenSize = MediaQuery.of(context).size;
    // final double screenWidth = screenSize.width;
    final double screenWidth = MediaQuery.of(context).size.width;
    double min = screenWidth * 0.2;
    double max = screenWidth * 0.86;
    if( qrSize < min.round() || qrSize > max.round() || controllerSizeQr.text.isEmpty) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Setting",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[300],
      ),
      body: Container(
        color: Colors.blue[300],
        padding: const EdgeInsets.only(top: 15),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(45), topRight: Radius.circular(45),),
              color: Colors.blue[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildSettingTime(),
                const Text("Set 0 to turn of auto update QR",),
                _buildPrefix(),
                _buildSubfix(),
                _buildQrSize(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onSaveButtonClick,
        label: const Text('Save'),
        icon: const Icon(Icons.save),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
