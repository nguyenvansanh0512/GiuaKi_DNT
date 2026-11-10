import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String image, name;
  final double radius;
  const UserAvatar({
    super.key,
    required this.image,
    required this.name,
    this.radius = 22,
  });
  @override
  Widget build(BuildContext context) {
    Uint8List? bytes;
    try {
      if (image.startsWith('data:image/')) {
        bytes = base64Decode(image.split(',').last);
      }
    } catch (_) {
      /* Placeholder cho dữ liệu ảnh hỏng. */
    }
    final placeholder = Center(
      child: Text(
        name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase(),
        style: TextStyle(
          fontSize: radius * .7,
          fontWeight: FontWeight.w700,
          color: const Color(0xff175d59),
        ),
      ),
    );
    return ClipOval(
      child: Container(
        width: radius * 2,
        height: radius * 2,
        color: const Color(0xffdeeeeb),
        child: bytes == null
            ? placeholder
            : Image.memory(
                bytes,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}
