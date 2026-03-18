import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> savedMixes = [];

  @override
  void initState() {
    super.initState();

    _loadMixes();
  }

  Future<void> _loadMixes() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> history = prefs.getStringList('saved_mixes') ?? [];

    setState(() {
      savedMixes = history
          .map((e) => jsonDecode(e) as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> _deleteMix(int index) async {
    final prefs = await SharedPreferences.getInstance();

    savedMixes.removeAt(index);

    final List<String> updatedHistory = savedMixes
        .map((e) => jsonEncode(e))
        .toList();

    await prefs.setStringList('saved_mixes', updatedHistory);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("أرشيف الخلطات"),

        backgroundColor: AppColors.primary,

        foregroundColor: Colors.white,
      ),

      body: savedMixes.isEmpty
          ? const Center(child: Text("لا توجد خلطات محفوظة"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),

              itemCount: savedMixes.length,

              itemBuilder: (context, index) {
                final mix = savedMixes[index];

                return Dismissible(
                  key: Key(mix['date']),

                  direction: DismissDirection.endToStart,

                  onDismissed: (direction) => _deleteMix(index),

                  background: Container(
                    alignment: Alignment.centerRight,

                    padding: const EdgeInsets.symmetric(horizontal: 20),

                    color: Colors.red,

                    child: const Icon(Icons.delete, color: Colors.white),
                  ),

                  child: Card(
                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: AppColors.border),

                      borderRadius: BorderRadius.circular(16),
                    ),

                    margin: const EdgeInsets.only(bottom: 12),

                    child: ListTile(
                      title: Text(mix['name'], style: AppStyles.font16SemiBold),

                      subtitle: Text("التاريخ: ${mix['date'].split('T')[0]}"),

                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),

                      onTap: () => Navigator.pop(context, mix),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
