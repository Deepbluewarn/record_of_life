import 'package:flutter/material.dart';

enum RollStatus { planning, inProgress, completed, archived }

const Map<String, Map<RollStatus, String>> statusLocale = {
  'ko': {
    RollStatus.planning: '준비중',
    RollStatus.inProgress: '촬영중',
    RollStatus.completed: '현상중',
    RollStatus.archived: '보관됨',
  },
  // 'en': {
  //   RollStatus.planning: 'Planning',
  //   RollStatus.inProgress: 'Shooting',
  //   RollStatus.completed: 'Developing',
  //   RollStatus.archived: 'Archived',
  // },
};

extension RollStatusDisplay on RollStatus {
  String displayName(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return statusLocale[locale]?[this] ?? statusLocale['ko']![this]!;
  }

  Color get displayColor {
    switch (this) {
      case RollStatus.planning:
        return Colors.grey;
      case RollStatus.inProgress:
        return Colors.blue;
      case RollStatus.completed:
        return Colors.orange;
      case RollStatus.archived:
        return Colors.black;
    }
  }
}
