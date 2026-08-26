import 'package:flutter/material.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/domain/models/shot.dart';

// 35mm 필름 스트립. sprocket 홀은 프레임 경계와 무관하게 균일 pitch.
// 프레임 비율 24×36mm 근사(3:2), 총 필름 폭 대비 frame 비율 ~0.69.

const _filmBase = Color(0xFFCF823E);
const _hole = Color(0xFFFAF6EE);
const _frameDark = Color(0xFF1A0F08);
const _frameEmpty = Color(0xFFDB9A5C);
const _emptyInk = Color(0x33351404);

class FilmStrip extends StatelessWidget {
  final Roll roll;
  final List<Shot> shots;
  const FilmStrip({super.key, required this.roll, required this.shots});

  static const double frameW = 108;
  static const double frameH = 72;
  static const double sprocketH = 10;
  static const double stripH = sprocketH * 2 + frameH;
  static const double gap = 4;

  @override
  Widget build(BuildContext context) {
    final n = roll.totalShots;
    final totalW = n * (frameW + gap) - gap;

    return SizedBox(
      height: stripH,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            width: totalW,
            height: stripH,
            child: Stack(
              children: [
                Positioned.fill(child: Container(color: _filmBase)),
                Positioned(
                  top: 0,
                  left: 0,
                  child: _SprocketBand(width: totalW, height: sprocketH),
                ),
                Positioned(
                  top: sprocketH,
                  left: 0,
                  child: Row(
                    children: List.generate(n, (i) {
                      return Padding(
                        padding: EdgeInsets.only(right: i == n - 1 ? 0 : gap),
                        child: _Frame(
                          index: i + 1,
                          shot: shots.where((s) => s.idx == i + 1).firstOrNull,
                          width: frameW,
                          height: frameH,
                        ),
                      );
                    }),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: _SprocketBand(width: totalW, height: sprocketH),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SprocketBand extends StatelessWidget {
  final double width;
  final double height;
  const _SprocketBand({required this.width, required this.height});

  static const double _pitch = 12;
  static const double _holeW = 7;
  static const double _holeH = 5;

  @override
  Widget build(BuildContext context) {
    final count = (width / _pitch).floor();
    final margin = (width - count * _pitch) / 2;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: List.generate(count, (i) {
          final x = margin + i * _pitch + (_pitch - _holeW) / 2;
          return Positioned(
            left: x,
            top: (height - _holeH) / 2,
            child: Container(
              width: _holeW,
              height: _holeH,
              decoration: BoxDecoration(
                color: _hole,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  final int index;
  final Shot? shot;
  final double width;
  final double height;
  const _Frame({
    required this.index,
    required this.shot,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final s = shot;
    if (s == null) {
      return SizedBox(
        width: width,
        height: height,
        child: Container(
          color: _frameEmpty,
          alignment: Alignment.center,
          child: Text(
            '$index',
            style: const TextStyle(
              color: _emptyInk,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ),
      );
    }
    // 데이터 프레임: 필름 edge printing 스타일. 사진 자리에 촬영 값이 인쇄됨.
    final ap = s.aperture;
    final ss = s.shutterSpeed;
    final rating = s.rating ?? 0;
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        color: _frameDark,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('$index', style: _edge),
                const Spacer(),
                if (rating > 0) _RatingDots(rating: rating),
              ],
            ),
            const Spacer(),
            if (ap != null)
              Center(
                child: Text('f/${ap.value}',
                    style: _big, maxLines: 1, overflow: TextOverflow.visible),
              ),
            if (ss != null)
              Center(
                child: Text(ss.label,
                    style: _medium, maxLines: 1, overflow: TextOverflow.visible),
              ),
            if (ap == null && ss == null)
              const Center(child: Text('—', style: _medium)),
            const Spacer(),
            Row(
              children: [
                Text(
                  s.focalLength != null ? '${s.focalLength}mm' : '',
                  style: _edge,
                ),
                const Spacer(),
                Text(s.iso != null ? 'ISO ${s.iso}' : '', style: _edge),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const _big = TextStyle(
    color: _hole,
    fontSize: 15,
    fontWeight: FontWeight.w800,
    height: 1.0,
  );
  static const _medium = TextStyle(
    color: _hole,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );
  static const _edge = TextStyle(
    color: Color(0xB3FAF6EE), // _hole 70%
    fontSize: 8,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}

// 별 대신 점 (프레임 상단 인쇄 스타일). 최대 5개.
class _RatingDots extends StatelessWidget {
  final int rating;
  const _RatingDots({required this.rating});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(rating.clamp(0, 5), (_) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 1),
        child: SizedBox(
          width: 3,
          height: 3,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _hole,
              shape: BoxShape.circle,
            ),
          ),
        ),
      )),
    );
  }
}
