import 'dart:math';

//This file contains general utility functions used in different files

double degToRad(double degree) => degree * pi / 180;
double radToDeg(double radian) => radian * 180 / pi;
double cosRad(double degree) => cos(degToRad(degree));
double sinRad(double degree) => sin(degToRad(degree));
double tanRad(double degree) => tan(degToRad(degree));

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