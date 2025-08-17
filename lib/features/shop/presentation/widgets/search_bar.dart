import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  const SearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: const Color(0xFF7A7977)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Search here',
                border: InputBorder.none,
              ),
            ),
          )
        ],
      ),
    );
  }
}