import 'package:flutter/material.dart';
import '../asma_ul_husna_screen.dart';

class AsmaUlHusnaCard extends StatelessWidget {
  const AsmaUlHusnaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AsmaUlHusnaScreen()),
        );
      },
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Text(
              'Asma Ul Husna – 99 Names of Allah',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}