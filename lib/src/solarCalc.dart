import 'dart:math';

import 'package:meta/meta.dart';

import 'constants.dart';
import 'timeCalc.dart' as time_calc;

double degToRad(double degree) => degree * pi / 180;
double radToDeg(double radian) => radian * 180 / pi;
double cosRad(double degree) => cos(degToRad(degree));
double sinRad(double degree) => sin(degToRad(degree));
double tanRad(double degree) => tan(degToRad(degree));

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

double getHeliocentricLongitude(num jme) =>
    (((getCoefficients(jme, HeliocentriclongitudeCoefficients) / 1e8) * 180) /
        pi) %
    360;

double getHeliocentricLatitude(num jme) =>
    ((getCoefficients(jme, HeliocentricLatitudeCoefficients) / 1e8) * 180) / pi;

/// Returns Radius Vector in Astronomical Units(AU). This is basically
/// the distance between Earth and Sun
double getEarthRadiusVector(num jme) =>
    getCoefficients(jme, EarthRadiusVectorCoefficients) / 1e8;

double getGeocentricLongitude(num jme) {
  return (getHeliocentricLongitude(jme) + 180) % 360;
}

double getGeocentricLatitude(num jme) {
  return -1 * getHeliocentricLatitude(jme);
}

//-----------------------------------------------------------------------------

double thirdOrderPolynomial(List<double> coeff, double jce) {
  return coeff[0] +
      coeff[1] * jce +
      coeff[2] * pow(jce, 2) +
      pow(jce, 3) / coeff[3];
}

double getMeanElongationOfMoon(double jce) {
  return thirdOrderPolynomial(
      NutationCoefficients['getMeanElongationOfMoon'], jce);
}

double getMeanAnomalyOfSun(double jce) {
  return thirdOrderPolynomial(NutationCoefficients['getMeanAnomalyOfSun'], jce);
}

double getMeanAnomalyOfMoon(double jce) {
  return thirdOrderPolynomial(
      NutationCoefficients['getMeanAnomalyOfMoon'], jce);
}

double getArgumentLatitude(double jce) {
  return thirdOrderPolynomial(NutationCoefficients['getArgumentLatitude'], jce);
}

double getAscendingAltitude(double jce) {
  return thirdOrderPolynomial(
      NutationCoefficients['getAscendingAltitude'], jce);
}

Nutation getNutation(double jce) {
  var nutationlongitude = 0.0;
  var nutationOblique = 0.0;
  var xList = <double>[
    getMeanElongationOfMoon(jce),
    getMeanAnomalyOfSun(jce),
    getMeanAnomalyOfMoon(jce),
    getArgumentLatitude(jce),
    getAscendingAltitude(jce)
  ];

  for (var i = 0; i < NutationCoefficientsList.length; i++) {
    var xySum = 0.0;
    for (var j = 0; j < xList.length; j++) {
      xySum += xList[j] * AberrationSinTerms[i][j];
    }
    nutationlongitude += ((NutationCoefficientsList[i][0] +
            (NutationCoefficientsList[i][1] * jce)) *
        sin((xySum * pi) / 180));

    nutationOblique += ((NutationCoefficientsList[i][2] +
            (NutationCoefficientsList[i][3] * jce)) *
        cos((xySum * pi) / 180));
  }
  return Nutation(
      longitude: nutationlongitude / 36000000.0,
      obliquity: nutationOblique / 36000000.0);
}

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

double getAberrationCorrection(double earthSunDistance) {
  return -20.4898 / (3600 * earthSunDistance);
}

double getApparentSunLongitude(
    double geocentricLongitude, Nutation nutation, double abCorrection) {
  return geocentricLongitude + nutation.longitude + abCorrection;
}

double getMeanSiderealTime(double julianDay) {
  final julianCen = time_calc.getJulianCentury(julianDay);
  final meanSidereal = 280.46061837 +
      (360.98564736629 * (julianDay - 2451545.0)) +
      0.000387933 * pow(julianCen, 2) -
      pow(julianCen, 3) / 38710000;
  return meanSidereal % 360;
}

double getApparentSiderealTime(
    double julianDay, double jme, Nutation nutation) {
  return getMeanSiderealTime(julianDay) +
      nutation.longitude * cos(getTrueObliquityOfEcliptic(jme, nutation));
}

double getGeocentricSunRightAscension(double apparentSunLongitude,
    double trueObliquityOfEcliptic, double geocentricLatitude) {
  var a = sinRad(apparentSunLongitude) * cosRad(trueObliquityOfEcliptic);
  var b = tanRad(geocentricLatitude) * sinRad(trueObliquityOfEcliptic);
  var c = cosRad(apparentSunLongitude);
  var alpha = atan2((a - b), c);
  return radToDeg(alpha) % 360;
}

double getGeocentricSunDeclination(double apparentSunLongitude,
    double trueObliquityOfEcliptic, double geocentricLatitude) {
  var a = sinRad(geocentricLatitude) * cosRad(trueObliquityOfEcliptic);
  var b = sinRad(apparentSunLongitude) *
      cosRad(geocentricLatitude) *
      sinRad(trueObliquityOfEcliptic);
  return radToDeg(asin(a + b));
}
//-------------------------------------------------------------------------\\

double getLocalHourAngle(double apparentSiderealTime, double longitude,
    double geocentricRightAscension) {
  return (apparentSiderealTime + longitude - geocentricRightAscension) % 360;
}

double getEquatorialHorizontalParallaxOfSun(double earthRadiusVector) {
  return 8.794 / (3600 * earthRadiusVector);
}

double getFlattenedLatitude(double latitude) {
  return radToDeg(atan(0.99664719 * tanRad(latitude)));
}

double getProjectedRadialDistance(double elevation, double latitude) {
  return cosRad(getFlattenedLatitude(latitude)) +
      (elevation * cosRad(latitude)) / 6378140.0;
}

double getProjectedAxialDistance(double elevation, double latitude) {
  return 0.99664719 * sinRad(getFlattenedLatitude(latitude)) +
      elevation * sinRad(latitude) / 6378140.0;
}

double getParallaxInSunRightAscension(
    double projectedRadialDistance,
    double equatorialHorizontalParallax,
    double localHourAngle,
    double geocentricSunDeclination) {
  var a = -1 * sinRad(equatorialHorizontalParallax) * sinRad(localHourAngle);
  var b = cosRad(geocentricSunDeclination) -
      projectedRadialDistance *
          sinRad(equatorialHorizontalParallax) *
          cosRad(localHourAngle);
  return radToDeg(atan2(a, b));
}

double getTopocentricSunRightAscension(
    double projectedRadialDistance,
    double equatorialHorizontalParallax,
    double localHourAngle,
    double apparentSunLongitude,
    double trueObliquityOfEcliptic,
    double geocentricLatitude) {
  var geocentricSunDeclination = getGeocentricSunDeclination(
      apparentSunLongitude, trueObliquityOfEcliptic, geocentricLatitude);
  var parallaxInSunRightAscension = getParallaxInSunRightAscension(
      projectedRadialDistance,
      equatorialHorizontalParallax,
      localHourAngle,
      geocentricSunDeclination);
  var geocentricSunRightAscension = getGeocentricSunRightAscension(
      apparentSunLongitude, trueObliquityOfEcliptic, geocentricLatitude);

  return geocentricSunRightAscension + parallaxInSunRightAscension;
}

double getTopocentricSunDeclination(
    double projectedAxialDistance,
    double equatorialHorizontalParallax,
    double localHourAngle,
    double parallaxSunRightAscension,
    double geocentricSunDeclination) {
  var a = (sinRad(geocentricSunDeclination) -
          projectedAxialDistance * sinRad(equatorialHorizontalParallax)) *
      cosRad(parallaxSunRightAscension);
  var b = cosRad(geocentricSunDeclination) -
      (projectedAxialDistance *
          sinRad(equatorialHorizontalParallax) *
          cosRad(localHourAngle));
  return radToDeg(atan2(a, b));
}

double getTopocentricLocalHourAngle(
    double localHourAngle, double parallaxInSunRightAscension) {
  return localHourAngle - parallaxInSunRightAscension;
}

double getTopocentricElevationAngle(double latitude,
    double topocentricSunDeclination, double topocentricLocalHourAngle) {
  return radToDeg(asin((sinRad(latitude) * sinRad(topocentricSunDeclination)) +
      cosRad(latitude) *
          cosRad(topocentricLocalHourAngle) *
          cosRad(topocentricSunDeclination)));
}

double getAtmosphericRefractionCorrection(double pressure,
    double temperatureInCelsius, double topocentricElevationAngle) {
  var a = pressure * 2.830 * 1.02;
  var b = 1010.0 *
      (temperatureInCelsius + 273) *
      60.0 *
      tanRad(topocentricElevationAngle +
          (10.3 / (topocentricElevationAngle + 5.11)));

  if (topocentricElevationAngle >= -1.0 * (2.830 + 0.5667)) return a / b;
  return 0;
}

double getTopocentricZenithAngle(
    double latitude,
    double topocentricSunDeclination,
    double topocentricLocalHourAngle,
    double pressure,
    double temperatureInCelsius) {
  final topocentricElevationAngle = getTopocentricElevationAngle(
      latitude, topocentricSunDeclination, topocentricLocalHourAngle);

  return 90 -
      topocentricElevationAngle -
      getAtmosphericRefractionCorrection(
          pressure, temperatureInCelsius, topocentricElevationAngle);
}

double getTopocentricAzimuthAngle(double topocentricLocalHourAngle,
    double latitude, double topocentricSunDeclination) {
  var a = sinRad(topocentricLocalHourAngle);
  var b = cos(topocentricLocalHourAngle) * sinRad(latitude) -
      tanRad(topocentricSunDeclination) * cos(latitude);
  return (180 + radToDeg(atan2(a, b))) % 360;
}

double getIncidenceAngle(double topocentricZenithAngle, double slope,
    double slopeOrientation, double topocentricAzimuthAngle) {
  return radToDeg(acos(cosRad(topocentricZenithAngle) * cosRad(slope) +
      sinRad(slope) *
          sinRad(topocentricZenithAngle) *
          cos(degToRad(topocentricAzimuthAngle) -
              pi -
              degToRad(slopeOrientation))));
}

//------------------------------------------------------------------------\\

//Calculation Of Sunrise, Sunset and transit time

double getMeanLongitudeOfSun(double jme) {
  return (280.4664567 +
          (360007.6982779 * jme) +
          (0.03032028 * pow(jme, 2)) +
          (pow(jme, 3) / 49931) -
          (pow(jme, 4) / 15300) -
          (pow(jme, 5) / 2000000)) %
      360;
}

double getEquationOfTime(
    double meanLongitudeOfSun,
    double geocentricRightAscension,
    double nutationInLongitude,
    double trueObliquityOfEcliptic) {
  final eot = (meanLongitudeOfSun -
          0.0057183 -
          geocentricRightAscension +
          (nutationInLongitude * cosRad(trueObliquityOfEcliptic))) *
      4;
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

  final apparentSiderealTime =
      getApparentSiderealTime(julianDay, jme, nutation);

  final approxSunTransitTime =
      (geocentricSunRightAscensionToday - longitude - apparentSiderealTime) /
          360;

//TODO: Arccosine is not in the range from -1 to 1, it means that the sun is always above or below the horizon for that day
  final localHourAngle = radToDeg(acos(
      (sinRad(h0) - sinRad(latitude) * sinRad(geocentricSunDeclinationToday)) /
          cosRad(latitude) *
          cosRad(geocentricSunDeclinationToday)));

  final approxSunriseTime = (approxSunTransitTime - (localHourAngle / 360));
  final approxSunsetTime = approxSunTransitTime + (localHourAngle / 360);

  final sTGsunTransit =
      apparentSiderealTime + 360.985647 * approxSunTransitTime;
  final sTGsunrise = apparentSiderealTime + 360.985647 * approxSunriseTime;
  final sTGsunset = apparentSiderealTime + 360.985647 * approxSunsetTime;

  final n0 = approxSunTransitTime + deltaT / 86400;
  final n1 = approxSunriseTime + deltaT / 86400;
  final n2 = approxSunsetTime + deltaT / 86400;

  final a =
      geocentricSunRightAscensionToday - geocentricSunRightAscensionYesterday;
  final b =
      geocentricSunRightAscensionTomorrow - geocentricSunRightAscensionToday;
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

  final lh0 = limit_degrees180pm(sTGsunTransit + longitude - alpha0);
  final lh1 = limit_degrees180pm(sTGsunrise + longitude - alpha1);
  final lh2 = limit_degrees180pm(sTGsunset + longitude - alpha2);

  final sunalt0 = radToDeg(asin(sinRad(latitude) * sinRad(delta0) +
      cosRad(latitude) * cosRad(delta0) * cosRad(lh0)));
  final sunalt1 = radToDeg(asin(sinRad(latitude) * sinRad(delta1) +
      cosRad(latitude) * cosRad(delta1) * cosRad(lh1)));
  final sunalt2 = radToDeg(asin(sinRad(latitude) * sinRad(delta2) +
      cosRad(latitude) * cosRad(delta2) * cosRad(lh2)));

  final T = approxSunTransitTime - lh0 / 360;
  final R = approxSunriseTime +
      (sunalt1 - h0) / (360 * cosRad(delta1) * cosRad(latitude) * sinRad(lh1));
  final S = approxSunsetTime +
      (sunalt2 - h0) / (360 * cosRad(delta2) * cosRad(latitude) * sinRad(lh2));

  return [(T * 24) % 24, (R * 24) % 24, (S * 24) % 24];
}

double limit_degrees180pm(double degrees) {
  double limited;

  degrees /= 360.0;
  limited = 360.0 * (degrees - (degrees.floor()));
  if (limited < -180.0) {
    limited += 360.0;
  } else if (limited > 180.0) {
    limited -= 360.0;
  }

  return limited;
}
