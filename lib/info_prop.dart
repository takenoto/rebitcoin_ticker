//This object will store the property name & its value
class InfoProp {
  String propName;
  double propValue;
  bool isPercentage;

  InfoProp(String propName, double propValue) {
    this.propName = propName;
    this.propValue = propValue;
    propName.toLowerCase().contains('percentage')
        ? isPercentage = true
        : isPercentage = false;
  }
}
