import 'package:astrocalc/src/solar_calc.dart';

/// Data retrieved  from "Solar Position Algorithm for
/// Solar Radiation Applications" by "Ibrahim Reda and Afshin Andreas" as
/// available on https://www.nrel.gov/docs/fy08osti/34302.pdf

final Map<String, dynamic> TestData = {
  'julianDayTestData': {
    DateTime.utc(2000, DateTime.january, 1, 12): 2451545.0,
    DateTime.utc(1999, DateTime.january, 1): 2451179.5,
    DateTime.utc(1987, DateTime.january, 27): 2446822.5,
    DateTime.utc(1987, DateTime.june, 19, 12): 2446966.0,
    DateTime.utc(1988, DateTime.january, 27): 2447187.5,
    DateTime.utc(1988, DateTime.june, 19, 12): 2447332.0,
    DateTime.utc(1900, DateTime.january, 1): 2415020.5,
    DateTime.utc(1600, DateTime.january, 1): 2305447.5,
    DateTime.utc(1600, DateTime.december, 31): 2305812.5,
  },
  //-------------------------------Initial Data-------------------------------//
  'latitude': 39.742476,
  'longitude': -105.1786,
  'dateTime': DateTime.utc(2003, DateTime.october, 17, 19, 30, 30),
  'elevation': 1830.14,
  'pressure': 820.0,
  'temperatureInCelsius': 11.0,
  'slope': 30.0,
  'slopeOrientation': -10.0,

//-----------------------Data that can be verified----------------------------//
  'julianDay': 2452930.312847,
  'julianMillenium': 0.003792779869191517,
  'julianEphemerisCentury': 0.03792779869191517,
  'nutation': Nutation(longitude: -0.00399840, obliquity: 0.00166657),
  'earthSunDistance': 0.9965422974,
  'trueObliquityOfEcliptic': 23.440465,
  'aberrationCorrection': -0.005711359,
  'apparentSiderealTime': 318.5119,
  'apparentSunLongitude': 204.0085519281,
  'geocentricLongitude': 204.0174921859384,
  'geocentricLatitude': 0.00010110749648050061,
  'geocentricRightAscension': 202.22741,
  'geocentricSunDeclination': -9.31434,
  'heliocentricLongitude': 24.0182616917,
  'heliocentricLatitude': -0.0001011219,
  'topocentricSunDeclination': -9.316179,
  'topocentricSunRightAscension': 202.22704,
  'topocentricLocalHourAngle': 11.10629,
  'topocentricZenithAngle': 50.11162,
  'topocentricAzimuthAngle': 194.34024,
  'projectedRadialDistance': 0.7702006191191089,
  'projectedAxialDistance': 0.6361121708785658,
  'equatorialHorizontalParallaxOfSun': 0.0024512534833203135,
  'localHourAngle': 11.105900,
  'parallaxInSunRightAscension': -0.0004733500411988414,
  'incidenceAngle': 25.18700,
};
