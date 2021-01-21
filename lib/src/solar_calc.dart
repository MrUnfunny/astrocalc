import 'dart:math';

import 'package:meta/meta.dart';

import 'constants.dart' as constant;
import 'time_calc.dart' as time_calc;
import 'utils.dart' as utils;

class Nutation {
  double longitude;
  double obliquity;
  Nutation({
    @required this.longitude,
    @required this.obliquity,
  });

  @override
  String toString() => 'Nutation(longitude: $longitude, obliquity: $obliquity)';
}

double getCoefficients(num jme, List<List<List<num>>> coefficientTable) {
  var result = 0.0;
  var jmeRes = 1.0;
  for (var helioList in coefficientTable) {
    var resHolder = 0.0;
    for (var helioValues in helioList) {
      resHolder += helioValues[0] * cos(helioValues[1] + helioValues[2] * jme);
    }
    result += resHolder * jmeRes;
    jmeRes *= jme;
  }
  return result;
}

double thirdOrderPolynomial(List<double> coeff, double jce) {
  return coeff[0] + coeff[1] * jce + coeff[2] * pow(jce, 2) + pow(jce, 3) / coeff[3];
}

//-----------------------------------------------------------------------------

double getHeliocentricLongitude(num jme) => (((getCoefficients(jme, constant.HeliocentriclongitudeCoefficients) / 1e8) * 180) / pi) % 360;

double getHeliocentricLatitude(num jme) => ((getCoefficients(jme, constant.HeliocentricLatitudeCoefficients) / 1e8) * 180) / pi;

/// Returns Radius Vector in Astronomical Units(AU). This is basically
/// the distance between Earth and Sun
double getEarthRadiusVector(num jme) => getCoefficients(jme, constant.EarthRadiusVectorCoefficients) / 1e8;

double getGeocentricLongitude(num jme) {
  return (getHeliocentricLongitude(jme) + 180) % 360;
}

double getGeocentricLatitude(num jme) {
  return -1 * getHeliocentricLatitude(jme);
}

double getMeanElongationOfMoon(double jce) {
  return thirdOrderPolynomial(constant.NutationCoefficients['getMeanElongationOfMoon'], jce);
}

double getMeanAnomalyOfSun(double jce) {
  return thirdOrderPolynomial(constant.NutationCoefficients['getMeanAnomalyOfSun'], jce);
}

double getMeanAnomalyOfMoon(double jce) {
  return thirdOrderPolynomial(constant.NutationCoefficients['getMeanAnomalyOfMoon'], jce);
}

double getArgumentLatitude(double jce) {
  return thirdOrderPolynomial(constant.NutationCoefficients['getArgumentLatitude'], jce);
}

double getAscendingAltitude(double jce) {
  return thirdOrderPolynomial(constant.NutationCoefficients['getAscendingAltitude'], jce);
}

/// irregularity in axis of rotation of earth due to precession
Nutation getNutation(double jce) {
  var nutationlongitude = 0.0;
  var nutationOblique = 0.0;
  var xList = <double>[getMeanElongationOfMoon(jce), getMeanAnomalyOfSun(jce), getMeanAnomalyOfMoon(jce), getArgumentLatitude(jce), getAscendingAltitude(jce)];

  for (var i = 0; i < constant.NutationCoefficientsList.length; i++) {
    var xySum = 0.0;
    for (var j = 0; j < xList.length; j++) {
      xySum += xList[j] * constant.AberrationSinTerms[i][j];
    }
    nutationlongitude += ((constant.NutationCoefficientsList[i][0] + (constant.NutationCoefficientsList[i][1] * jce)) * sin((xySum * pi) / 180));

    nutationOblique += ((constant.NutationCoefficientsList[i][2] + (constant.NutationCoefficientsList[i][3] * jce)) * cos((xySum * pi) / 180));
  }
  return Nutation(longitude: nutationlongitude / 36000000.0, obliquity: nutationOblique / 36000000.0);
}

///angle of earth's equator with ecliptic plane
double getTrueObliquityOfEcliptic(double jme, Nutation nutation) {
  var u = jme / 10;
  var meanObliquity = 84381.448 -
      (4680.93 * u) -
      (1.55 * pow(u, 2)) +
      (1999.25 * pow(u, 3)) -
      (51.38 * pow(u, 4)) -
      (249.67 * pow(u, 5)) -
      (39.05 * pow(u, 6)) +
      (7.12 * pow(u, 7)) +
      (27.87 * pow(u, 8)) +
      (5.79 * pow(u, 9)) +
      (2.45 * pow(u, 10));
  return meanObliquity / 3600.0 + nutation.obliquity;
}

///correction in position of sun due to earth's motion
double getAberrationCorrection(double earthSunDistance) {
  return -20.4898 / (3600 * earthSunDistance);
}

double getApparentSunLongitude(double geocentricLongitude, Nutation nutation, double abCorrection) {
  return geocentricLongitude + nutation.longitude + abCorrection;
}

double getMeanSiderealTime(double julianDay) {
  final julianCen = time_calc.getJulianCentury(julianDay);
  final meanSidereal = 280.46061837 + (360.98564736629 * (julianDay - 2451545.0)) + 0.000387933 * pow(julianCen, 2) - pow(julianCen, 3) / 38710000;
  return meanSidereal % 360;
}

double getApparentSiderealTime(double julianDay, double jme, Nutation nutation) {
  return getMeanSiderealTime(julianDay) + nutation.longitude * cos(getTrueObliquityOfEcliptic(jme, nutation));
}

double getGeocentricSunRightAscension(double apparentSunLongitude, double trueObliquityOfEcliptic, double geocentricLatitude) {
  var a = utils.sinRad(apparentSunLongitude) * utils.cosRad(trueObliquityOfEcliptic);
  var b = utils.tanRad(geocentricLatitude) * utils.sinRad(trueObliquityOfEcliptic);
  var c = utils.cosRad(apparentSunLongitude);
  var alpha = atan2((a - b), c);
  return utils.radToDeg(alpha) % 360;
}

double getGeocentricSunDeclination(double apparentSunLongitude, double trueObliquityOfEcliptic, double geocentricLatitude) {
  var a = utils.sinRad(geocentricLatitude) * utils.cosRad(trueObliquityOfEcliptic);
  var b = utils.sinRad(apparentSunLongitude) * utils.cosRad(geocentricLatitude) * utils.sinRad(trueObliquityOfEcliptic);
  return utils.radToDeg(asin(a + b));
}

/// Right Ascension of sun with respect to the observer
double getLocalHourAngle(double apparentSiderealTime, double longitude, double geocentricRightAscension) {
  return (apparentSiderealTime + longitude - geocentricRightAscension) % 360;
}

double getEquatorialHorizontalParallaxOfSun(double earthRadiusVector) {
  return 8.794 / (3600 * earthRadiusVector);
}

double getFlattenedLatitude(double latitude) {
  return utils.radToDeg(atan(0.99664719 * utils.tanRad(latitude)));
}

double getProjectedRadialDistance(double elevation, double latitude) {
  return utils.cosRad(getFlattenedLatitude(latitude)) + (elevation * utils.cosRad(latitude)) / 6378140.0;
}

double getProjectedAxialDistance(double elevation, double latitude) {
  return 0.99664719 * utils.sinRad(getFlattenedLatitude(latitude)) + elevation * utils.sinRad(latitude) / 6378140.0;
}

double getParallaxInSunRightAscension(double projectedRadialDistance, double equatorialHorizontalParallax, double localHourAngle, double geocentricSunDeclination) {
  var a = -1 * utils.sinRad(equatorialHorizontalParallax) * utils.sinRad(localHourAngle);
  var b = utils.cosRad(geocentricSunDeclination) - projectedRadialDistance * utils.sinRad(equatorialHorizontalParallax) * utils.cosRad(localHourAngle);
  return utils.radToDeg(atan2(a, b));
}

double getTopocentricSunRightAscension(
    double projectedRadialDistance, double equatorialHorizontalParallax, double localHourAngle, double apparentSunLongitude, double trueObliquityOfEcliptic, double geocentricLatitude) {
  var geocentricSunDeclination = getGeocentricSunDeclination(apparentSunLongitude, trueObliquityOfEcliptic, geocentricLatitude);
  var parallaxInSunRightAscension = getParallaxInSunRightAscension(projectedRadialDistance, equatorialHorizontalParallax, localHourAngle, geocentricSunDeclination);
  var geocentricSunRightAscension = getGeocentricSunRightAscension(apparentSunLongitude, trueObliquityOfEcliptic, geocentricLatitude);

  return geocentricSunRightAscension + parallaxInSunRightAscension;
}

double getTopocentricSunDeclination(double projectedAxialDistance, double equatorialHorizontalParallax, double localHourAngle, double projectedRadialDistance, double geocentricSunDeclination) {
  var parallaxSunRightAscension = getParallaxInSunRightAscension(projectedRadialDistance, equatorialHorizontalParallax, localHourAngle, geocentricSunDeclination);
  var a = (utils.sinRad(geocentricSunDeclination) - projectedAxialDistance * utils.sinRad(equatorialHorizontalParallax)) * utils.cosRad(parallaxSunRightAscension);
  var b = utils.cosRad(geocentricSunDeclination) - (projectedAxialDistance * utils.sinRad(equatorialHorizontalParallax) * utils.cosRad(localHourAngle));
  return utils.radToDeg(atan2(a, b));
}

double getTopocentricLocalHourAngle(double localHourAngle, double parallaxInSunRightAscension) {
  return localHourAngle - parallaxInSunRightAscension;
}

double getTopocentricElevationAngle(double latitude, double topocentricSunDeclination, double topocentricLocalHourAngle) {
  return utils.radToDeg(asin((utils.sinRad(latitude) * utils.sinRad(topocentricSunDeclination)) + utils.cosRad(latitude) * utils.cosRad(topocentricLocalHourAngle) * utils.cosRad(topocentricSunDeclination)));
}

double getAtmosphericRefractionCorrection(double pressure, double temperatureInCelsius, double topocentricElevationAngle) {
  var a = pressure * 283 * 1.02;
  var b = 1010.0 * (temperatureInCelsius + 273) * 60.0 * utils.tanRad(topocentricElevationAngle + (10.3 / (topocentricElevationAngle + 5.11)));

  if (topocentricElevationAngle >= -1.0 * (2.830 + 0.5667)) return a / b;
  return 0;
}

double getTopocentricZenithAngle(double latitude, double topocentricSunDeclination, double topocentricLocalHourAngle, double pressure, double temperatureInCelsius) {
  final topocentricElevationAngle = getTopocentricElevationAngle(latitude, topocentricSunDeclination, topocentricLocalHourAngle);

  return 90 - topocentricElevationAngle - getAtmosphericRefractionCorrection(pressure, temperatureInCelsius, topocentricElevationAngle);
}

double getTopocentricAzimuthAngle(double topocentricLocalHourAngle, double latitude, double topocentricSunDeclination) {
  var a = utils.sinRad(topocentricLocalHourAngle);
  var b = utils.cosRad(topocentricLocalHourAngle) * utils.sinRad(latitude) - utils.tanRad(topocentricSunDeclination) * utils.cosRad(latitude);
  return (180 + utils.radToDeg(atan2(a, b))) % 360;
}

double getIncidenceAngle(double topocentricZenithAngle, double slope, double slopeOrientation, double topocentricAzimuthAngle) {
  return utils.radToDeg(acos(utils.cosRad(topocentricZenithAngle) * utils.cosRad(slope) + utils.sinRad(slope) * utils.sinRad(topocentricZenithAngle) * cos(utils.degToRad(topocentricAzimuthAngle) - pi - utils.degToRad(slopeOrientation))));
}

//------------------------------------------------------------------------\\

//Calculation Of Sunrise, Sunset and transit time

double getMeanLongitudeOfSun(double jme) {
  return (280.4664567 + (360007.6982779 * jme) + (0.03032028 * pow(jme, 2)) + (pow(jme, 3) / 49931) - (pow(jme, 4) / 15300) - (pow(jme, 5) / 2000000)) % 360;
}

double getEquationOfTime(double meanLongitudeOfSun, double geocentricRightAscension, double nutationInLongitude, double trueObliquityOfEcliptic) {
  final eot = (meanLongitudeOfSun - 0.0057183 - geocentricRightAscension + (nutationInLongitude * utils.cosRad(trueObliquityOfEcliptic))) * 4;
  if (eot > 20) return eot - 1440;
  if (eot < -20) return eot + 1440;
  return eot;
}

List<double> getTimeCalcOfSun(
  double julianDay,
  double jme,
  Nutation nutation,
  double geocentricSunRightAscensionYesterday,
  double geocentricSunRightAscensionToday,
  double geocentricSunRightAscensionTomorrow,
  double geocentricSunDeclinationYesterday,
  double geocentricSunDeclinationToday,
  double geocentricSunDeclinationTomorrow,
  double longitude,
  double latitude,
  int year,
  int month,
) {
  final h0 = -0.8333;
  final deltaT = time_calc.getDeltaT(year, month);

  final apparentSiderealTime = getApparentSiderealTime(julianDay, jme, nutation);

  final approxSunTransitTime = (geocentricSunRightAscensionToday - longitude - apparentSiderealTime) / 360;

//TODO: Arccosine is not in the range from -1 to 1, it means that the sun is always above or below the horizon for that day
  final localHourAngle = utils.radToDeg(acos((utils.sinRad(h0) - utils.sinRad(latitude) * utils.sinRad(geocentricSunDeclinationToday)) / utils.cosRad(latitude) * utils.cosRad(geocentricSunDeclinationToday)));

  final approxSunriseTime = (approxSunTransitTime - (localHourAngle / 360));
  final approxSunsetTime = approxSunTransitTime + (localHourAngle / 360);

  final sTGsunTransit = apparentSiderealTime + 360.985647 * approxSunTransitTime;
  final sTGsunrise = apparentSiderealTime + 360.985647 * approxSunriseTime;
  final sTGsunset = apparentSiderealTime + 360.985647 * approxSunsetTime;

  final n0 = approxSunTransitTime + deltaT / 86400;
  final n1 = approxSunriseTime + deltaT / 86400;
  final n2 = approxSunsetTime + deltaT / 86400;

  final a = geocentricSunRightAscensionToday - geocentricSunRightAscensionYesterday;
  final b = geocentricSunRightAscensionTomorrow - geocentricSunRightAscensionToday;
  final c = b - a;
  final ad = geocentricSunDeclinationToday - geocentricSunDeclinationYesterday;
  final bd = geocentricSunDeclinationTomorrow - geocentricSunDeclinationToday;
  final cd = bd - ad;

  final alpha0 = geocentricSunRightAscensionToday + n0 * (a + b + c * n0) / 2;
  final delta0 = geocentricSunDeclinationToday + n0 * (ad + bd + cd * n0) / 2;
  final alpha1 = geocentricSunRightAscensionToday + n1 * (a + b + c * n1) / 2;
  final delta1 = geocentricSunDeclinationToday + n1 * (ad + bd + cd * n1) / 2;
  final alpha2 = geocentricSunRightAscensionToday + n2 * (a + b + c * n2) / 2;
  final delta2 = geocentricSunDeclinationToday + n2 * (ad + bd + cd * n2) / 2;

  final lh0 = utils.limit_degrees180pm(sTGsunTransit + longitude - alpha0);
  final lh1 = utils.limit_degrees180pm(sTGsunrise + longitude - alpha1);
  final lh2 = utils.limit_degrees180pm(sTGsunset + longitude - alpha2);

  final sunalt0 = utils.radToDeg(asin(utils.sinRad(latitude) * utils.sinRad(delta0) + utils.cosRad(latitude) * utils.cosRad(delta0) * utils.cosRad(lh0)));
  final sunalt1 = utils.radToDeg(asin(utils.sinRad(latitude) * utils.sinRad(delta1) + utils.cosRad(latitude) * utils.cosRad(delta1) * utils.cosRad(lh1)));
  final sunalt2 = utils.radToDeg(asin(utils.sinRad(latitude) * utils.sinRad(delta2) + utils.cosRad(latitude) * utils.cosRad(delta2) * utils.cosRad(lh2)));

  final T = approxSunTransitTime - lh0 / 360;
  final R = approxSunriseTime + (sunalt1 - h0) / (360 * utils.cosRad(delta1) * utils.cosRad(latitude) * utils.sinRad(lh1));
  final S = approxSunsetTime + (sunalt2 - h0) / (360 * utils.cosRad(delta2) * utils.cosRad(latitude) * utils.sinRad(lh2));

  return [T, R, S];
}
