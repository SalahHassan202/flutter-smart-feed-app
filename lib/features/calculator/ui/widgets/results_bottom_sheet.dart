import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:smart_feed_app/core/constants/app_colors.dart';
import 'package:smart_feed_app/core/constants/app_styles.dart';

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
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
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
            const SizedBox(height: 24),
            Text("ملخص الخلطة", style: AppStyles.font20Bold),
            const SizedBox(height: 24),
            _buildResultCard(
              "إجمالي التكلفة",
              totalCost.toStringAsFixed(2),
              "جنيه",
              Colors.green,
            ),
            _buildResultCard(
              "إجمالي الوزن",
              totalWeight.toStringAsFixed(2),
              "كجم",
              Colors.blue,
            ),
            _buildResultCard(
              "سعر الكيلو",
              avgPrice.toStringAsFixed(2),
              "جنيه",
              Colors.orange,
            ),
            _buildResultCard(
              "نسبة البروتين",
              avgProtein.toStringAsFixed(2),
              "%",
              Colors.red,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final image = await screenshotController.capture();
                      if (image != null) {
                        await Gal.putImageBytes(image);
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم حفظ الفاتورة في المعرض'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text(
                      "حفظ كصورة",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppStyles.font16SemiBold),
          Text(
            "$value $unit",
            style: AppStyles.font18WhiteBold.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
