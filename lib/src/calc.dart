// this file contains the final methods to retrieve useful information for the user

import 'solar_calc.dart';
import 'time_calc.dart' as time_calc;

class SunCalc {
  DateTime sunTransitTime;
  DateTime sunRiseTime;
  DateTime sunSetTime;
  SunCalc({
    this.sunTransitTime,
    this.sunRiseTime,
    this.sunSetTime,
  });

  @override
  String toString() => 'SunCalc(sunTransitTime: $sunTransitTime, sunRiseTime: $sunRiseTime, sunSetTime: $sunSetTime)';
}

SunCalc getCalculations(double latitude, double longitude, DateTime dateTime) {
  final dateTime1 = DateTime.utc(dateTime.year, dateTime.month, dateTime.day, 0);
  final dateTime0 = DateTime.utc(dateTime.year, dateTime.month, dateTime.day - 1, 0);
  final dateTime2 = DateTime.utc(dateTime.year, dateTime.month, dateTime.day + 1, 0);

  final jme1 = time_calc.getJulianEphemerisMillenium(time_calc.getJulianEphemerisCentury(time_calc.getJulianEphemerisDay(dateTime1)));
  final nutation1 = getNutation(time_calc.getJulianEphemerisCentury(time_calc.getJulianEphemerisDay(dateTime1)));

  final geocentricLongitude1 = getGeocentricLongitude(jme1);
  final abCorrection1 = getAberrationCorrection(getEarthRadiusVector(jme1));
  final trueObliquityOfEcliptic1 = getTrueObliquityOfEcliptic(jme1, nutation1);
  final geocentricLatitude1 = getGeocentricLatitude(jme1);

  final apparentSunLongitude1 = getApparentSunLongitude(geocentricLongitude1, nutation1, abCorrection1);

  final jme2 = time_calc.getJulianEphemerisMillenium(time_calc.getJulianEphemerisCentury(time_calc.getJulianEphemerisDay(dateTime2)));
  final nutation2 = getNutation(time_calc.getJulianEphemerisCentury(time_calc.getJulianEphemerisDay(dateTime2)));

  final geocentricLongitude2 = getGeocentricLongitude(jme2);
  final abCorrection2 = getAberrationCorrection(getEarthRadiusVector(jme2));
  final trueObliquityOfEcliptic2 = getTrueObliquityOfEcliptic(jme2, nutation2);
  final geocentricLatitude2 = getGeocentricLatitude(jme2);

  final apparentSunLongitude2 = getApparentSunLongitude(geocentricLongitude2, nutation2, abCorrection2);

  final jme0 = time_calc.getJulianEphemerisMillenium(time_calc.getJulianEphemerisCentury(time_calc.getJulianEphemerisDay(dateTime0)));
  final nutation0 = getNutation(time_calc.getJulianEphemerisCentury(time_calc.getJulianEphemerisDay(dateTime0)));

  final geocentricLongitude0 = getGeocentricLongitude(jme0);
  final abCorrection0 = getAberrationCorrection(getEarthRadiusVector(jme0));
  final trueObliquityOfEcliptic0 = getTrueObliquityOfEcliptic(jme0, nutation0);
  final geocentricLatitude0 = getGeocentricLatitude(jme0);

  final apparentSunLongitude0 = getApparentSunLongitude(geocentricLongitude0, nutation0, abCorrection0);

  final geocentricSunRightAscensionTomorrow = getGeocentricSunRightAscension(apparentSunLongitude2, trueObliquityOfEcliptic2, geocentricLatitude2);

  final geocentricSunRightAscensionYesterday = getGeocentricSunRightAscension(apparentSunLongitude0, trueObliquityOfEcliptic0, geocentricLatitude0);

  final geocentricSunRightAscensionToday = getGeocentricSunRightAscension(apparentSunLongitude1, trueObliquityOfEcliptic1, geocentricLatitude1);

  final geocentricSunDeclinationYesterday = getGeocentricSunDeclination(apparentSunLongitude0, trueObliquityOfEcliptic0, geocentricLatitude0);

  final geocentricSunDeclinationToday = getGeocentricSunDeclination(apparentSunLongitude1, trueObliquityOfEcliptic1, geocentricLatitude1);

  final geocentricSunDeclinationTomorrow = getGeocentricSunDeclination(apparentSunLongitude2, trueObliquityOfEcliptic2, geocentricLatitude2);

  final res = getTimeCalcOfSun(
    time_calc.getJulianDay(dateTime1),
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
  return SunCalc(
    sunTransitTime: dateTime1.add(Duration(seconds: (Duration.secondsPerDay * res[0]).floor())),
    sunRiseTime: dateTime1.add(Duration(seconds: (Duration.secondsPerDay * res[1]).floor())),
    sunSetTime: dateTime1.add(Duration(seconds: (Duration.secondsPerDay * res[2]).floor())),
  );
}

///returns time of sunrise for given latitude and longitude.
///By default returns time in UTC, to get local time set isLocal to true
DateTime getSunRiseTime(double latitude, double longitude, DateTime dateTime, {isLocal = false}) {
  if (isLocal) {
    return getCalculations(latitude, longitude, dateTime).sunRiseTime.toLocal();
  }
  return getCalculations(latitude, longitude, dateTime).sunRiseTime;
}

///returns time of sunset for given latitude and longitude.
///By default returns time in UTC, to get local time set isLocal to true
DateTime getSunSetTime(double latitude, double longitude, DateTime dateTime, {isLocal = false}) {
  if (isLocal) {
    return getCalculations(latitude, longitude, dateTime).sunSetTime.toLocal();
  }
  return getCalculations(latitude, longitude, dateTime).sunSetTime;
}

///returns time of noon or when sun is at highest point for given latitude and longitude.
///By default returns time in UTC, to get local time set isLocal to true
DateTime getSunTransitTime(double latitude, double longitude, DateTime dateTime, {isLocal = false}) {
  if (isLocal) {
    return getCalculations(latitude, longitude, dateTime).sunTransitTime.toLocal();
  }
  return getCalculations(latitude, longitude, dateTime).sunTransitTime;
}

///returns angle in clockwise direction from north to point directly under sun in horizon based coordinates
double getSunAzimuthAngle(DateTime dateTime, double latitude, double longitude, double elevation) {
  final julianDay = time_calc.getJulianDay(dateTime);
  final julianEphemerisDay = time_calc.getJulianEphemerisDay(dateTime);
  final julianEphemerisCentury = time_calc.getJulianEphemerisCentury(julianEphemerisDay);
  final jme = time_calc.getJulianEphemerisMillenium(julianEphemerisCentury);
  final nutation = getNutation(julianEphemerisCentury);

  final apparentSiderealTime = getApparentSiderealTime(julianDay, jme, nutation);

  final geocentricLongitude = getGeocentricLongitude(jme);
  final earthSunDistance = getEarthRadiusVector(jme);
  final abCorrection = getAberrationCorrection(earthSunDistance);
  final apparentSunLongitude = getApparentSunLongitude(geocentricLongitude, nutation, abCorrection);

  final trueObliquityOfEcliptic = getTrueObliquityOfEcliptic(jme, nutation);

  final geocentricLatitude = getGeocentricLatitude(jme);

  final geocentricRightAscension = getGeocentricSunRightAscension(apparentSunLongitude, trueObliquityOfEcliptic, geocentricLatitude);

  final localHourAngle = getLocalHourAngle(apparentSiderealTime, longitude, geocentricRightAscension);

  final projectedRadialDistance = getProjectedRadialDistance(elevation, latitude);
  final equatorialHorizontalParallax = getEquatorialHorizontalParallaxOfSun(earthSunDistance);
  final geocentricSunDeclination = getGeocentricSunDeclination(apparentSunLongitude, trueObliquityOfEcliptic, geocentricLatitude);

  final parallaxInSunRightAscension = getParallaxInSunRightAscension(projectedRadialDistance, equatorialHorizontalParallax, localHourAngle, geocentricSunDeclination);

  final topocentricLocalHourAngle = getTopocentricLocalHourAngle(localHourAngle, parallaxInSunRightAscension);

  final projectedAxialDistance = getProjectedAxialDistance(elevation, latitude);
  final topocentricSunDeclination = getTopocentricSunDeclination(projectedAxialDistance, equatorialHorizontalParallax, localHourAngle, projectedRadialDistance, geocentricSunDeclination);

  return getTopocentricAzimuthAngle(topocentricLocalHourAngle, latitude, topocentricSunDeclination);
}
