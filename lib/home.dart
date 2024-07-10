import 'package:flutter/material.dart';
import 'colors.dart';
import 'generic_list.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedButtonIndex = 0;

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    // Naviga alla pagina di login dopo il logout
    Navigator.of(context).pushNamed('/login'); // Sostituisci con la tua route per la pagina di login
  }

  void _clearSearchField() {
    _searchController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<String> collections = ['pizze', 'bibite', 'dolci'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'HUNGRY NOW?',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color.fromARGB(150, 2, 2, 2),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: AppColors.secondaryColor,
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.black),
                    onPressed: _logout, // Chiama la funzione di logout al click
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                cursorColor: Colors.black,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Find your food ...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1.0),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1.0),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1.0),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.black),
                          onPressed: _clearSearchField,
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                ),
                onChanged: (text) {
                  setState(() {});
                },
                onTap: () {
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 24,
                color: Color.fromARGB(150, 2, 2, 2),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedButtonIndex = 0;
                      });
                      _clearSearchField();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedButtonIndex == 0 ? AppColors.secondaryColor : AppColors.lightYellow,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Pizze'),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedButtonIndex = 1;
                      });
                      _clearSearchField();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedButtonIndex == 1 ? AppColors.secondaryColor : AppColors.lightYellow,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Bibite'),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedButtonIndex = 2;
                      });
                      _clearSearchField();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedButtonIndex == 2 ? AppColors.secondaryColor : AppColors.lightYellow,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Dolci'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GenericList(
                collectionName: collections[_selectedButtonIndex],
                searchQuery: _searchController.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
