import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run_baza/widgets/race_motif.dart';

import 'package:run_baza/data/race_motif.dart';
import 'package:run_baza/data/mock_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Every event keeps its own country and artwork at all distances', () {
    final expected = <String, (RaceCountry, RaceMotif)>{
      'r1': (RaceCountry.moldova, RaceMotif.orhei),
      'r2': (RaceCountry.moldova, RaceMotif.arch),
      'r3': (RaceCountry.romania, RaceMotif.iasiPalace),
      'r4': (RaceCountry.moldova, RaceMotif.vineyard),
      'r5': (RaceCountry.moldova, RaceMotif.forest),
      'r6': (RaceCountry.moldova, RaceMotif.parkSteps),
      'r7': (RaceCountry.romania, RaceMotif.athenaeum),
      'r8': (RaceCountry.moldova, RaceMotif.riverside),
    };
    for (final race in races) {
      expect(race.country, expected[race.id]!.$1);
      expect(motifForRace(race), expected[race.id]!.$2);
      for (final distance in race.distances) {
        final wanted = race.id == 'r2' && distance >= 20
            ? RaceMotif.stefan
            : expected[race.id]!.$2;
        expect(motifForRace(race, distance), wanted);
      }
    }
  });
  for (final motif in RaceMotif.values) {
    test('${motif.name} has bounded vector art', () async {
      final paths = motifStrokes(motif);
      expect(paths.length, greaterThan(10));
      for (final path in paths) {
        final bounds = path.getBounds();
        expect(bounds.left, greaterThanOrEqualTo(0));
        expect(bounds.top, greaterThanOrEqualTo(0));
        expect(bounds.right, lessThanOrEqualTo(320));
        expect(bounds.bottom, lessThanOrEqualTo(240));
      }
      // Optional local visual QA exports, never required for the test result.
      final out = Platform.environment['MOTIF_QA_DIR'];
      if (out != null) {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        canvas.drawColor(const Color(0xFFEEF0E8), BlendMode.src);
        RaceMotifPainter(
          motif: motif,
          color: const Color(0xFF236649),
        ).paint(canvas, const Size(640, 480));
        final picture = recorder.endRecording();
        final image = await picture.toImage(640, 480);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory(out).create(recursive: true);
        await File('$out/${motif.name}.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
        picture.dispose();
      }
    });
  }
}
