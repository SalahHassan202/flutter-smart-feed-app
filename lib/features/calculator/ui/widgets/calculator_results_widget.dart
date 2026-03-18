import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:smart_feed_app/core/constants/app_colors.dart';

class ResultsBottomSheet extends StatelessWidget {
  final double totalCost;
  final double totalWeight;
  final double avgPrice;
  final double avgProtein;
  final ScreenshotController screenshotController = ScreenshotController();

  ResultsBottomSheet({
    super.key,
    required this.totalCost,
    required this.totalWeight,
    required this.avgPrice,
    required this.avgProtein,
  });

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "نتائج الخلطة",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildRow(
              "إجمالي التكلفة",
              "${totalCost.toStringAsFixed(2)} جنيه",
              Colors.green,
            ),
            _buildRow(
              "إجمالي الوزن",
              "${totalWeight.toStringAsFixed(2)} كجم",
              Colors.blue,
            ),
            _buildRow(
              "سعر الكيلو",
              "${avgPrice.toStringAsFixed(2)} جنيه",
              Colors.orange,
            ),
            _buildRow(
              "نسبة البروتين",
              "${avgProtein.toStringAsFixed(2)} %",
              Colors.red,
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final image = await screenshotController.capture();
                  if (image != null) {
                    await Gal.putImageBytes(image);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم الحفظ في المعرض')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text(
                  "حفظ النتائج كصورة",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.all(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
