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
import 'package:share_plus/share_plus.dart';

class ExportService {
  final Ref ref;
  ExportService(this.ref);

  Future<void> exportRolls(List<Roll> rolls) async {
    final shotRepo = ref.read(shotRepositoryProvider);
    final lensRepo = ref.read(lensRepositoryProvider);

    final allShots = <Shot>[];
    for (final r in rolls) {
      allShots.addAll(await shotRepo.getShotsByRollId(r.id));
    }
    final lensIds = <String>{
      for (final r in rolls)
        if (r.defaultLensId != null) r.defaultLensId!,
      for (final s in allShots)
        if (s.lensId != null) s.lensId!,
    };
    final List<Lens> lenses = lensIds.isEmpty
        ? const []
        : await lensRepo.getLenses(lensIds.toList());

    final json = ExiftoolExporter(
      rolls: rolls,
      shots: allShots,
      lenses: lenses,
    ).toJson();

    final filename = rolls.length == 1
        ? '${_slug(rolls.first.title ?? rolls.first.id)}.json'
        : 'rol_export_${DateTime.now().millisecondsSinceEpoch}.json';

    final bytes = Uint8List.fromList(utf8.encode(json));

    if (kIsWeb) {
      final xfile = XFile.fromData(
        bytes,
        name: filename,
        mimeType: 'application/json',
      );
      await Share.shareXFiles([xfile], text: 'ROL export');
      return;
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      text: 'ROL export',
    );
  }

  String _slug(String s) => s
      .trim()
      .replaceAll(RegExp(r'[\\/:*?"<>|\s]+'), '_')
      .replaceAll(RegExp(r'_+'), '_');
}

final exportServiceProvider = Provider(ExportService.new);
