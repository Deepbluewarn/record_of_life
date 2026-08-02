import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record_of_life/data/export.dart';
import 'package:record_of_life/domain/models/lens.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/domain/models/shot.dart';
import 'package:record_of_life/features/roll/presentation/providers/repository_provider.dart';
import 'package:record_of_life/features/settings/providers/settings_provider.dart';
import 'package:share_plus/share_plus.dart';

enum RollExportFormat { rolJson, argfile }

class ExportService {
  final Ref ref;
  ExportService(this.ref);

  Future<void> exportRoll(Roll roll, RollExportFormat format) async {
    final bundle = await _load(roll);
    final artist = (await ref.read(settingsProvider.future)).artist;
    final slug = slugForFilename(roll.title ?? roll.id);

    final (String body, String filename, String mimeType) = switch (format) {
      RollExportFormat.rolJson => (
          buildRolJson(
            roll: roll,
            shots: bundle.shots,
            lenses: bundle.lenses,
            artist: artist,
          ),
          '$slug.rol.json',
          'application/json',
        ),
      RollExportFormat.argfile => (
          buildArgfile(
            roll: roll,
            shots: bundle.shots,
            lenses: bundle.lenses,
            artist: artist,
          ),
          '$slug.args',
          'text/plain',
        ),
    };

    final bytes = Uint8List.fromList(utf8.encode(body));

    if (kIsWeb) {
      await Share.shareXFiles([
        XFile.fromData(bytes, name: filename, mimeType: mimeType),
      ], text: 'ROL export');
      return;
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: mimeType)],
      text: 'ROL export',
    );
  }

  Future<_RollBundle> _load(Roll roll) async {
    final shots = await ref.read(shotRepositoryProvider).getShotsByRollId(roll.id);
    final lensIds = <String>{
      if (roll.defaultLensId != null) roll.defaultLensId!,
      for (final s in shots)
        if (s.lensId != null) s.lensId!,
    };
    final lenses = lensIds.isEmpty
        ? const <Lens>[]
        : await ref.read(lensRepositoryProvider).getLenses(lensIds.toList());
    return _RollBundle(shots: shots, lenses: lenses);
  }
}

class _RollBundle {
  final List<Shot> shots;
  final List<Lens> lenses;
  _RollBundle({required this.shots, required this.lenses});
}

final exportServiceProvider = Provider(ExportService.new);
