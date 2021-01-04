import 'package:test/test.dart';
import 'package:astrocalc/astrocalc.dart';
import 'package:astrocalc/src/solar_calc.dart';

/// Data retrieved  from "Solar Position Algorithm for
/// Solar Radiation Applications" by "Ibrahim Reda and Afshin Andreas" as
/// available on https://www.nrel.gov/docs/fy08osti/34302.pdf
final Map<DateTime, double> julianDayTestData = {
  DateTime.utc(2000, DateTime.january, 1, 12): 2451545.0,
  DateTime.utc(1999, DateTime.january, 1): 2451179.5,
  DateTime.utc(1987, DateTime.january, 27): 2446822.5,
  DateTime.utc(1987, DateTime.june, 19, 12): 2446966.0,
  DateTime.utc(1988, DateTime.january, 27): 2447187.5,
  DateTime.utc(1988, DateTime.june, 19, 12): 2447332.0,
  DateTime.utc(1900, DateTime.january, 1): 2415020.5,
  DateTime.utc(1600, DateTime.january, 1): 2305447.5,
  DateTime.utc(1600, DateTime.december, 31): 2305812.5,
};

void main() {
  ///Using this data from "Solar Position Algorithm for
  /// Solar Radiation Applications" by "Ibrahim Reda and Afshin Andreas"
  final dateTime = DateTime.utc(2003, DateTime.october, 17, 19, 30, 30);
  final latitude = 39.742476;
  final longitude = -105.1786;
  final pressure = 820.0;
  final temperatureInCelsius = 11.0;
  final slope = 30.0;

  group('Julian Day Tests', () {
    test('Get Julian Day from Gregorian Day', () {
      for (var dateTime in julianDayTestData.keys) {
        expect(getJulianDay(dateTime), equals(julianDayTestData[dateTime]));
      }
    });

    test('Get Gregorian Day from Julian Day', () {
      final _reversedMap = julianDayTestData.map((key, value) => MapEntry(value, key));
      for (var julianDay in julianDayTestData.values) {
        expect(getGregorianDay(julianDay), equals(_reversedMap[julianDay]));
      }
    });
  });

  final jd = getJulianDay(dateTime);

  final jme = getJulianEphemerisMillenium(getJulianEphemerisCentury(getJulianDay(dateTime)));

  final jce = getJulianEphemerisCentury(getJulianDay(dateTime));

  final nutation = getNutation(jce);
  group('Heliocentric Calculations', () {
    final jme = getJulianEphemerisMillenium(getJulianEphemerisCentury(getJulianDay(dateTime)));
    test('Get Heliocentric Latitude', () {
      expect(getHeliocentricLatitude(jme), closeTo(-0.0001011219, 0.001));
    });

    test('Get Heliocentric longitude', () {
      expect(getHeliocentricLongitude(jme), closeTo(24.0182616917, 0.001));
    });

    test('Get Earth Radius Vector', () {
      expect(getEarthRadiusVector(jme), closeTo(0.9965422974, 0.001));
    });
  });

  group('Get Nutation Values', () {
    final nutationValue = getNutation(0.03792779857862657);
    test('Get Nutation longitude', () {
      expect(nutationValue.longitude, closeTo(-0.00399840, 0.0000001));
    });
    test('Get Nutation Obliquity', () {
      expect(nutationValue.obliquity, closeTo(0.00166657, 0.0000001));
    });
  });

  test('Get true obliquity of ecliptic', () {
    expect(getTrueObliquityOfEcliptic(jme, getNutation(jce)), closeTo(23.440465, 0.00001));
  });
  var trueObliquityOfEcliptic = getTrueObliquityOfEcliptic(jme, nutation);

  test('Get Aberration Correction', () {
    expect(getAberrationCorrection(getEarthRadiusVector(jme)), closeTo(-0.005711359, 0.00001));
  });
  final aberrationCorrection = getAberrationCorrection(getEarthRadiusVector(jme));

  test('Get Apparent Sun Longitude', () {
    expect(getApparentSunLongitude(getGeocentricLongitude(jme), nutation, aberrationCorrection), closeTo(204.0085519281, 0.001));
  });

  test('Get Apparent Sidereal Time', () {
    expect(getApparentSiderealTime(jd, jme, nutation), closeTo(318.5119, 0.01));
  });
  // final apparentSiderealTime = getApparentSiderealTime(jd, jme, nutation);
  test('Get Geocentric Sun Right Ascension', () {
    expect(
        getGeocentricSunRightAscension(
            getApparentSunLongitude(getGeocentricLongitude(jme), nutation, getAberrationCorrection(getEarthRadiusVector(jme))), trueObliquityOfEcliptic, getGeocentricLatitude(jme)),
        closeTo(202.2274, 0.001));
  });

  test('Get Geocentric Sun Declination', () {
    expect(
        getGeocentricSunDeclination(
            getApparentSunLongitude(getGeocentricLongitude(jme), nutation, getAberrationCorrection(getEarthRadiusVector(jme))), trueObliquityOfEcliptic, getGeocentricLatitude(jme)),
        closeTo(-9.31434, 0.001));
  });

  test('get Observer local hour angle', () {
    expect(getLocalHourAngle(getApparentSiderealTime(2452930.312847, jme, nutation), -105.1786, 202.22741), closeTo(11.105900, 0.01));
  });

  group('Position of sun with respect to observer on earth', () {
    test('get Topocentric Right Ascension', () {
      expect(
          getTopocentricSunRightAscension(getProjectedRadialDistance(1830.14, 39.742476), getEquatorialHorizontalParallaxOfSun(getEarthRadiusVector(jme)), 11.105900, 204.0085519281,
              trueObliquityOfEcliptic, getGeocentricLatitude(jme)),
          closeTo(202.22704, 0.001));
    });

    test('get Topocentric Sun Declination ', () {
      expect(
          getTopocentricSunDeclination(
              getProjectedAxialDistance(1830.14, 39.742476), getEquatorialHorizontalParallaxOfSun(getEarthRadiusVector(jme)), 11.105900, getProjectedRadialDistance(1830.14, 39.742476), -9.31434),
          closeTo(-9.316179, 0.0001));
    });
  });

  test('get Topocentric Local Hour Angle', () {
    //Value of parallaxInSunRightAscension is calculated from this program itself since I couldn't find any data for it
    expect(getTopocentricLocalHourAngle(11.105900, -0.0004733500411988414), closeTo(11.10629, 0.0001));
  });

  test('get Topocentric Zenith Angle', () {
    expect(getTopocentricZenithAngle(latitude, -9.316179, 11.10629, pressure, temperatureInCelsius), closeTo(50.11162, 0.0001));
  });

  test('get Topocentric Azimuth Angle', () {
    expect(getTopocentricAzimuthAngle(11.10629, latitude, -9.316179), closeTo(194.34024, 0.0001));
  });

  test('get Topocentric Incidence Angle', () {
    print(getIncidenceAngle(50.11162, slope, -10, 194.34024));
    expect(getIncidenceAngle(50.11162, slope, -10, 194.34024), closeTo(25.18700, 0.001));
  });
}
