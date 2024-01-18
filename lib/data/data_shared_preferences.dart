import 'package:shared_preferences/shared_preferences.dart';

class DataManager {
  void writing (int timeSecWait, String preFix, String subFix, double qrSize) async{
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('timeSecWait', timeSecWait);
      await prefs.setString('preFix', preFix);
      await prefs.setString('subFix', subFix);
      await prefs.setDouble('qrSize', qrSize);
    } catch (e) {
      print("Error: ${e.toString()}");
    }
  }

  ///Return "true" if it save successful
  ///Return exception if it false
  Future<String> isWrote (int timeSecWait, String preFix, String subFix, double qrSize) async{
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('timeSecWait', timeSecWait);
      await prefs.setString('preFix', preFix);
      await prefs.setString('subFix', subFix);
      await prefs.setDouble('qrSize', qrSize);
      return "true";
    } catch (e) {
      print("Error: ${e.toString()}");
      return e.toString();
    }
  }

  Future<int> getTimeSecWait () async{
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey("timeSecWait")) prefs.setInt('timeSecWait', 10);
      return prefs.getInt("timeSecWait")!;
    } catch(e){
      print("Error: ${e.toString()}");
      return 0;
    }
  }

  Future<String> getPreFix () async{
    try{
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if(!prefs.containsKey("preFix")) prefs.setString('preFix', "VFast");
      return prefs.getString("preFix")!;
    } catch(e){
      print("Error: ${e.toString()}");
      return "";
    }
  }

  Future<String> getSubFix () async{
    try{
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if(prefs.containsKey("subFix")) prefs.setString('preFix', "TimeKeeping");
      return prefs.getString("subFix")!;
    } catch(e){
      print("Error: ${e.toString()}");
      return "";
    }
  }

  Future<double> getQRSize () async{
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey("qrSize")) prefs.setDouble('qrSize', 200);
      return prefs.getDouble("qrSize")!;
    }catch(e){
      print("Error: ${e.toString()}");
      return 0;
    }
  }

}