# Astrocalc

Astrocalc is a Dart package for astronomical calculations. Astrocalc is inspired by [Pysolar](https://github.com/pingswept/pysolar) and based on [this pdf](https://www.nrel.gov/docs/fy08osti/34302.pdf) by <strong>Ibrahim Reda</strong> and <strong>Afshin Andreas</strong>.

Astrocalc is currently a work in progress. It will soon support many more calculations.

## Usage

**SUNRISE TIME**
<br>
By default all functions return DateTime object for UTC. To get it in Local format, pass isLocal as true. 
```dart
  final latitude = 28.6139;
  final longitude = 77.2090;
  final dateTime = DateTime.utc(2020, 12, 30);

  final sunRiseTime =
      getSunRiseTime(latitude, longitude, dateTime, isLocal: true);
      
```
**SUNSET TIME**
```dart
 final sunSetTime =
      getSunSetTime(latitude, longitude, dateTime, isLocal: true);
      
```
**SUN TRANSIT TIME**
```dart
 final sunTransitTime =
      getSunTransitTime(latitude, longitude, dateTime, isLocal: true);
      
```

## Example
```dart
void main() {
  final latitude = 28.6139;
  final longitude = 77.2090;
  final dateTime = DateTime.utc(2020, 12, 30);

  final sunRiseTime =
      getSunRiseTime(latitude, longitude, dateTime, isLocal: true);
  final sunSetTime =
      getSunSetTime(latitude, longitude, dateTime, isLocal: true);
  final sunTransitTime =
      getSunTransitTime(latitude, longitude, dateTime, isLocal: true);

  print('Sunrise Time: $sunRiseTime');
  print('Sunset Time: $sunSetTime');
  print('Sun Transit Time: $sunTransitTime');
}
````

**OUTPUT**

```
Sunrise Time: 2020-12-30 07:13:20.000
Sunset Time: 2020-12-30 17:34:16.000
Sun Transit Time: 2020-12-30 12:23:46.000

```

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).
