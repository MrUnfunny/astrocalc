import 'dart:math';

///Calculated using Polynomial Expressions listed by NASA on
/// https://eclipse.gsfc.nasa.gov/LEcat5/deltatpoly.html
double getDeltaT(int year, int month) {
  final y = year + (month - 0.5) / 12;
  final lunarCorrection = -0.000012932 * pow((y - 1955), 2);

  if (year < -500) {
    return -20 + 32 * pow(((year - 1820) / 100), 2);
  } else if (year >= -500 && year < 500) {
    return 10583.6 -
        1014.41 * (y / 100) +
        33.78311 * pow((y / 100), 2) -
        5.952053 * pow((y / 100), 3) -
        0.1798452 * pow((y / 100), 4) +
        0.022174192 * pow((y / 100), 5) +
        0.0090316521 * pow((y / 100), 6) +
        lunarCorrection;
  } else if (year >= 500 && year < 1600) {
    return 1574.2 -
        556.01 * (y - 1000) / 100 +
        71.23472 * pow((y - 1000) / 100, 2) +
        0.319781 * pow((y - 1000) / 100, 3) -
        0.8503463 * pow((y - 1000) / 100, 4) -
        0.005050998 * pow((y - 1000) / 100, 5) +
        0.0083572073 * pow((y - 1000) / 100, 6) +
        lunarCorrection;
  } else if (year >= 1600 && year < 1700) {
    return 120 - 0.9808 * (y - 1600) - 0.01532 * pow((y - 1600), 2) + pow((y - 1600), 3) / 7129 + lunarCorrection;
  } else if (year >= 1700 && year < 1800) {
    return 8.83 + 0.1603 * (y - 1700) - 0.0059285 * pow((y - 1700), 2) + 0.00013336 * pow((y - 1700), 3) - pow((y - 1700), 4) / 1174000 + lunarCorrection;
  } else if (year >= 1800 && year < 1860) {
    return 13.72 -
        0.332447 * (y - 1800) +
        0.0068612 * pow((y - 1800), 2) +
        0.0041116 * pow((y - 1800), 3) -
        0.00037436 * pow((y - 1800), 4) +
        0.0000121272 * pow((y - 1800), 5) -
        0.0000001699 * pow((y - 1800), 6) +
        0.000000000875 * pow((y - 1800), 7) +
        lunarCorrection;
  } else if (year >= 1860 && year < 1900) {
    return 7.62 + 0.5737 * (y - 1860) - 0.251754 * pow((y - 1860), 2) + 0.01680668 * pow((y - 1860), 3) - 0.0004473624 * pow((y - 1860), 4) + pow((y - 1860), 5) / 233174 + lunarCorrection;
  } else if (year >= 1900 && year < 1920) {
    return -2.79 + 1.494119 * (y - 1900) - 0.0598939 * pow((y - 1900), 2) + 0.0061966 * pow((y - 1900), 3) - 0.000197 * pow((y - 1900), 4) + lunarCorrection;
  } else if (year >= 1920 && year < 1941) {
    return 21.20 + 0.84493 * (y - 1920) - 0.076100 * pow((y - 1920), 2) + 0.0020936 * pow((y - 1920), 3) + lunarCorrection;
  } else if (year >= 1941 && year < 1961) {
    final _lunarCorrection = (year >= 1955) ? 0 : lunarCorrection;
    return 29.07 + 0.407 * (y - 1950) - pow((y - 1950), 2) / 233 + pow((y - 1950), 3) / 2547 + _lunarCorrection;
  } else if (year >= 1961 && year < 1986) {
    return 45.45 + 1.067 * (y - 1975) - pow((y - 1975), 2) / 260 - pow((y - 1975), 3) / 718;
  } else if (year >= 1986 && year < 2005) {
    return 63.86 + 0.3345 * (y - 2000) - 0.060374 * pow((y - 2000), 2) + 0.0017275 * pow((y - 2000), 3) + 0.000651814 * pow((y - 2000), 4) + 0.00002373599 * pow((y - 2000), 5);
  } else if (year >= 2005 && year < 2050) {
    return 62.92 + 0.32217 * (y - 2000) + 0.005589 * pow((y - 2000), 2) + lunarCorrection;
  } else if (year >= 2050 && year < 2150) {
    return -20 + 32 * pow(((y - 1820) / 100), 2) - 0.5628 * (2150 - y) + lunarCorrection;
  } else {
    return -20 + 32 * pow(((year - 1820) / 100), 2) + lunarCorrection;
  }
}

/// Epoch for Julian day is January 1, 4713 BC in proleptic Julian calendar and
/// November 24, 4714 BC in the proleptic Gregorian calendar
/// Since 1 BC is year 0, we'll use year -4713
final julianEpoch = DateTime.utc(-4713, 11, 24, 12, 0, 0);

///calculated using Universal Time
double getJulianDay(DateTime dateTime) {
  return ((dateTime.difference(julianEpoch).inSeconds / Duration.secondsPerDay));
}

///calculated using Terrestrial Time
double getJulianEphemerisDay(DateTime dateTime) {
  return (getJulianDay(dateTime) + getDeltaT(dateTime.year, dateTime.month) / Duration.secondsPerDay);
}

double getJulianCentury(double julianDay) {
  return (julianDay - 2451545.0) / 36525.0;
}

double getJulianEphemerisCentury(double julianEphemerisDay) {
  return (julianEphemerisDay - 2451545.0) / 36525.0;
}

double getJulianEphemerisMillenium(double julianEphemerisCentury) {
  return julianEphemerisCentury / 10.0;
}

DateTime getGregorianDay(double julianDay) {
  return julianEpoch.add(Duration(milliseconds: (julianDay * Duration.secondsPerDay * 1000).floor()));
}
