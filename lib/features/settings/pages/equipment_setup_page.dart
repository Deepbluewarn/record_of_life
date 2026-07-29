import 'package:flutter/material.dart';
import 'package:record_of_life/features/settings/widgets/equipment_sections.dart';

class EquipmentSetupPage extends StatelessWidget {
  const EquipmentSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 장비 관리')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            CamerasSection(),
            SizedBox(height: 16),
            FilmsSection(),
            SizedBox(height: 16),
            LensesSection(),
          ],
        ),
      ),
    );
  }
}
