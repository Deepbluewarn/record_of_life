import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record_of_life/domain/models/shot.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';

class ShotCard extends StatelessWidget {
  final Shot shot;
  final int index;

  const ShotCard({super.key, required this.shot, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // 좌측: 썸네일
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 썸네일
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[400]!, width: 0.5),
                  ),
                  child: shot.imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(shot.imagePath!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[400],
                            size: 32,
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // 중간: 컷 번호 + 날짜
            Expanded(
              child: SizedBox(
                height: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '컷 ${index + 1}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDate(shot.date),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 우측: 카메라 설정 (세로)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 조리개
                Text(
                  shot.aperture.toString(),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                // 셔터 스피드
                Text(
                  shot.shutterSpeed.toString(),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 12),
                // 우측 하단: 평가 (별점)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 평가
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${shot.rating ?? 0}★',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '날짜 미정';
    return '${dateTime.year}. ${dateTime.month}. ${dateTime.day}';
  }
}
