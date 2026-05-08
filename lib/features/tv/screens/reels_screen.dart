import 'package:flutter/material.dart';

class ReelsScreen extends StatelessWidget {
  const ReelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView(
      scrollDirection: Axis.vertical,
      children: const [
        _ReelCard(text: "Islamic Reminder 1"),
        _ReelCard(text: "Islamic Reminder 2"),
        _ReelCard(text: "Islamic Reminder 3"),
      ],
    );
  }
}

class _ReelCard extends StatelessWidget {
  final String text;

  const _ReelCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}