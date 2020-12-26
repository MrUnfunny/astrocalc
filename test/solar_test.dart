import 'package:test/test.dart';
import 'package:astrocalc/astrocalc.dart';

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

  group('Julian Day Tests', () {
    test('Get Julian Day from Gregorian Day', () {
      for (var dateTime in julianDayTestData.keys) {
        expect(gregorianToJulianDay(dateTime),
            equals(julianDayTestData[dateTime]));
      }
    });

    test('Get Gregorian Day from Julian Day', () {
      final _reversedMap =
          julianDayTestData.map((key, value) => MapEntry(value, key));
      for (var julianDay in julianDayTestData.values) {
        expect(
            julianToGregorianDay(julianDay), equals(_reversedMap[julianDay]));
      }
    });
  });

  final jd = gregorianToJulianDay(dateTime);

  final jme = getJulianEphemerisMillenium(
      getJulianEphemerisCentury(gregorianToJulianDay(dateTime)));

  final jce = getJulianEphemerisCentury(gregorianToJulianDay(dateTime));

  final nutation = getNutation(jce);
  group('Heliocentric Calculations', () {
    final jme = getJulianEphemerisMillenium(
        getJulianEphemerisCentury(gregorianToJulianDay(dateTime)));
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
    expect(getTrueObliquityOfEcliptic(jme, getNutation(jce)),
        closeTo(23.440465, 0.00001));
  });
  var trueObliquityOfEcliptic = getTrueObliquityOfEcliptic(jme, nutation);

  test('Get Aberration Correction', () {
    expect(getAberrationCorrection(getEarthRadiusVector(jme)),
        closeTo(-0.005711359, 0.00001));
  });
  final aberrationCorrection =
      getAberrationCorrection(getEarthRadiusVector(jme));

  test('Get Apparent Sun Longitude', () {
    expect(
        getApparentSunLongitude(
            getGeocentricLongitude(jme), nutation, aberrationCorrection),
        closeTo(204.0085519281, 0.001));
  });

  test('Get Apparent Sidereal Time', () {
    expect(getApparentSiderealTime(jd, jme, nutation), closeTo(318.5119, 0.01));
  });
  // final apparentSiderealTime = getApparentSiderealTime(jd, jme, nutation);
  test('Get Geocentric Sun Right Ascension', () {
    expect(
        getGeocentricSunRightAscension(
            getApparentSunLongitude(getGeocentricLongitude(jme), nutation,
                getAberrationCorrection(getEarthRadiusVector(jme))),
            trueObliquityOfEcliptic,
            getGeocentricLatitude(jme)),
        closeTo(202.2274, 0.001));
  });

  test('Get Geocentric Sun Declination', () {
    expect(
        getGeocentricSunDeclination(
            getApparentSunLongitude(getGeocentricLongitude(jme), nutation,
                getAberrationCorrection(getEarthRadiusVector(jme))),
            trueObliquityOfEcliptic,
            getGeocentricLatitude(jme)),
        closeTo(-9.31434, 0.001));
  });

  test('get Observer local hour angle', () {
    expect(
        getLocalHourAngle(
            getApparentSiderealTime(2452930.312847, jme, nutation),
            -105.1786,
            202.22741),
        closeTo(11.105900, 0.01));
  });
}
