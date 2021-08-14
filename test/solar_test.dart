import 'package:test/test.dart';
import 'package:astro_calculations/astro_calculations.dart';
import 'package:astro_calculations/src/solar_calc.dart';
import 'data/solar_test_data.dart';

void main() {
  group('Heliocentric Calculations', () {
    test('Get Heliocentric Latitude', () {
      expect(getHeliocentricLatitude(TestData['julianMillenium']),
          closeTo(TestData['heliocentricLatitude'], 0.001));
    });

    test('Get Heliocentric longitude', () {
      expect(getHeliocentricLongitude(TestData['julianMillenium']),
          closeTo(TestData['heliocentricLongitude'], 0.001));
    });

    test('Get Earth Radius Vector', () {
      expect(getEarthRadiusVector(TestData['julianMillenium']),
          closeTo(TestData['earthSunDistance'], 0.001));
    });
  });

  group('Get Nutation Values', () {
    final nutationValue = getNutation(TestData['julianEphemerisCentury']);
    test('Get Nutation longitude', () {
      expect(nutationValue.longitude,
          closeTo(TestData['nutation'].longitude, 0.0000001));
    });
    test('Get Nutation Obliquity', () {
      expect(nutationValue.obliquity,
          closeTo(TestData['nutation'].obliquity, 0.0000001));
    });
  });

  test('Get true obliquity of ecliptic', () {
    expect(
        getTrueObliquityOfEcliptic(
            TestData['julianMillenium'], TestData['nutation']),
        closeTo(TestData['trueObliquityOfEcliptic'], 0.00001));
  });

  test('Get Aberration Correction', () {
    expect(getAberrationCorrection(TestData['earthSunDistance']),
        closeTo(TestData['aberrationCorrection'], 0.00001));
  });

  test('Get Apparent Sun Longitude', () {
    expect(
        getApparentSunLongitude(TestData['geocentricLongitude'],
            TestData['nutation'], TestData['aberrationCorrection']),
        closeTo(TestData['apparentSunLongitude'], 0.001));
  });

  test('Get Apparent Sidereal Time', () {
    expect(
        getApparentSiderealTime(TestData['julianDay'],
            TestData['julianMillenium'], TestData['nutation']),
        closeTo(TestData['apparentSiderealTime'], 0.01));
  });
  test('Get Geocentric Sun Right Ascension', () {
    expect(
        getGeocentricSunRightAscension(
            TestData['apparentSunLongitude'],
            TestData['trueObliquityOfEcliptic'],
            TestData['geocentricLatitude']),
        closeTo(TestData['geocentricRightAscension'], 0.001));
  });
  test('Get Geocentric Sun Declination', () {
    expect(
        getGeocentricSunDeclination(
            TestData['apparentSunLongitude'],
            TestData['trueObliquityOfEcliptic'],
            TestData['geocentricLatitude']),
        closeTo(TestData['geocentricSunDeclination'], 0.001));
  });
  test('get Observer local hour angle', () {
    expect(
        getLocalHourAngle(TestData['apparentSiderealTime'],
            TestData['longitude'], TestData['geocentricRightAscension']),
        closeTo(TestData['localHourAngle'], 0.01));
  });

  group('Position of sun with respect to observer on earth', () {
    test('get Topocentric Right Ascension', () {
      expect(
          getTopocentricSunRightAscension(
              TestData['projectedRadialDistance'],
              TestData['equatorialHorizontalParallaxOfSun'],
              TestData['localHourAngle'],
              TestData['apparentSunLongitude'],
              TestData['trueObliquityOfEcliptic'],
              TestData['geocentricLatitude']),
          closeTo(TestData['topocentricSunRightAscension'], 0.001));
    });
    test('get Topocentric Sun Declination ', () {
      expect(
          getTopocentricSunDeclination(
              TestData['projectedAxialDistance'],
              TestData['equatorialHorizontalParallaxOfSun'],
              TestData['localHourAngle'],
              TestData['projectedRadialDistance'],
              TestData['geocentricSunDeclination']),
          closeTo(TestData['topocentricSunDeclination'], 0.0001));
    });
  });

  test('get Topocentric Local Hour Angle', () {
    //Value of parallaxInSunRightAscension is calculated from this program itself since I couldn't find any data for it
    expect(
        getTopocentricLocalHourAngle(TestData['localHourAngle'],
            TestData['parallaxInSunRightAscension']),
        closeTo(TestData['topocentricLocalHourAngle'], 0.0001));
  });

  test('get Topocentric Zenith Angle', () {
    expect(
        getTopocentricZenithAngle(
            TestData['latitude'],
            TestData['topocentricSunDeclination'],
            TestData['topocentricLocalHourAngle'],
            TestData['pressure'],
            TestData['temperatureInCelsius']),
        closeTo(TestData['topocentricZenithAngle'], 0.0001));
  });

  test('get Topocentric Azimuth Angle', () {
    expect(
        getTopocentricAzimuthAngle(TestData['topocentricLocalHourAngle'],
            TestData['latitude'], TestData['topocentricSunDeclination']),
        closeTo(TestData['topocentricAzimuthAngle'], 0.0001));
  });

  test('get Topocentric Incidence Angle', () {
    expect(
        getIncidenceAngle(TestData['topocentricZenithAngle'], TestData['slope'],
            TestData['slopeOrientation'], TestData['topocentricAzimuthAngle']),
        closeTo(TestData['incidenceAngle'], 0.001));
  });
}
