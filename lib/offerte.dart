import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'generic_list.dart';

class Offerte extends StatelessWidget {
  const Offerte({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0), // Altezza personalizzata della AppBar
        child: AppBar(
          backgroundColor: AppColors.primaryColor,
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Offerte',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: GenericList(
                collectionName: 'offerte',
                searchQuery: '', // Search query vuota per Offerte
              ),
            ),
          ],
        ),
      ),
    );
  }
}
