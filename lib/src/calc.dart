import 'solarCalc.dart';
import 'timeCalc.dart' as time_calc;

dynamic getCalculations(double latitude, double longitude, DateTime dateTime) {
  final dateTime1 =
      DateTime.utc(dateTime.year, dateTime.month, dateTime.day, 0);
  final dateTime0 =
      DateTime.utc(dateTime.year, dateTime.month, dateTime.day - 1, 0);
  final dateTime2 =
      DateTime.utc(dateTime.year, dateTime.month, dateTime.day + 1, 0);

  final jme1 = time_calc.getJulianEphemerisMillenium(
      time_calc.getJulianEphemerisCentury(
          time_calc.gregorianToJulianEphemerisDay(dateTime1)));
  final nutation1 = getNutation(
      time_calc.getJulianCentury(time_calc.gregorianToJulianDay(dateTime1)));

  final geocentricLongitude1 = getGeocentricLongitude(jme1);
  final abCorrection1 = getAberrationCorrection(getEarthRadiusVector(jme1));
  final trueObliquityOfEcliptic1 = getTrueObliquityOfEcliptic(jme1, nutation1);
  final geocentricLatitude1 = getGeocentricLatitude(jme1);

  final apparentSunLongitude1 =
      getApparentSunLongitude(geocentricLongitude1, nutation1, abCorrection1);

  final jme2 = time_calc.getJulianEphemerisMillenium(
      time_calc.getJulianEphemerisCentury(
          time_calc.gregorianToJulianEphemerisDay(dateTime2)));
  final nutation2 = getNutation(
      time_calc.getJulianCentury(time_calc.gregorianToJulianDay(dateTime2)));

  final geocentricLongitude2 = getGeocentricLongitude(jme2);
  final abCorrection2 = getAberrationCorrection(getEarthRadiusVector(jme2));
  final trueObliquityOfEcliptic2 = getTrueObliquityOfEcliptic(jme2, nutation2);
  final geocentricLatitude2 = getGeocentricLatitude(jme2);

  final apparentSunLongitude2 =
      getApparentSunLongitude(geocentricLongitude2, nutation2, abCorrection2);

  final jme0 = time_calc.getJulianEphemerisMillenium(
      time_calc.getJulianEphemerisCentury(
          time_calc.gregorianToJulianEphemerisDay(dateTime0)));
  final nutation0 = getNutation(
      time_calc.getJulianCentury(time_calc.gregorianToJulianDay(dateTime0)));

  final geocentricLongitude0 = getGeocentricLongitude(jme0);
  final abCorrection0 = getAberrationCorrection(getEarthRadiusVector(jme0));
  final trueObliquityOfEcliptic0 = getTrueObliquityOfEcliptic(jme0, nutation0);
  final geocentricLatitude0 = getGeocentricLatitude(jme0);

  final apparentSunLongitude0 =
      getApparentSunLongitude(geocentricLongitude0, nutation0, abCorrection0);

  final geocentricSunRightAscensionTomorrow = getGeocentricSunRightAscension(
      apparentSunLongitude2, trueObliquityOfEcliptic2, geocentricLatitude2);

  final geocentricSunRightAscensionYesterday = getGeocentricSunRightAscension(
      apparentSunLongitude0, trueObliquityOfEcliptic0, geocentricLatitude0);

  final geocentricSunRightAscensionToday = getGeocentricSunRightAscension(
      apparentSunLongitude1, trueObliquityOfEcliptic1, geocentricLatitude1);

  final geocentricSunDeclinationYesterday = getGeocentricSunDeclination(
      apparentSunLongitude0, trueObliquityOfEcliptic0, geocentricLatitude0);

  final geocentricSunDeclinationToday = getGeocentricSunDeclination(
      apparentSunLongitude1, trueObliquityOfEcliptic1, geocentricLatitude1);

  final geocentricSunDeclinationTomorrow = getGeocentricSunDeclination(
      apparentSunLongitude2, trueObliquityOfEcliptic2, geocentricLatitude2);

  final res = getTimeCalcOfSun(
    time_calc.gregorianToJulianDay(dateTime1),
    jme1,
    nutation1,
    geocentricSunRightAscensionYesterday,
    geocentricSunRightAscensionToday,
    geocentricSunRightAscensionTomorrow,
    geocentricSunDeclinationYesterday,
    geocentricSunDeclinationToday,
    geocentricSunDeclinationTomorrow,
    longitude, //77.317787,
    latitude, //28.408913,
    dateTime.year,
    dateTime.month,
  );
  for (var d in res) {
    var hr = (d + 5.5).truncate();
    var min = ((d + 5.5) - hr) * 60;
    var sec = ((min - min.truncate()) * 60).truncate();
    print('$hr:${min.truncate()}:$sec');
  }
}

//TODO: remove after proper implementation
void main(List<String> args) {
  getCalculations(28.408913, 77.317787, DateTime.utc(2020, 12, 26));
}
