import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'app_colors.dart';

class NoInternetScaffold extends StatelessWidget {
  const NoInternetScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 188, 191, 194),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0), // Altezza personalizzata della AppBar
        child: AppBar(
          backgroundColor: AppColors.primaryColor,
        ),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.wifi,
                      size: 45,
                      color: AppColors.primaryColor,
                    ),
                    Icon(
                      FontAwesomeIcons.exclamation,
                      size: 45,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nessuna connessione Internet\nconnettersi e riprovare',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}