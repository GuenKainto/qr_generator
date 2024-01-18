class QRData_model{
  String preFix;
  String datePath;
  String subFix;

  String toString(){
    return "$preFix@$datePath@$subFix";
  }

  QRData_model(this.preFix, this.datePath, this.subFix);
}