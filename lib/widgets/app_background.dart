import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final String? imageAsset;
  final String? imageUrl;
  final Widget child;
  const AppBackground({super.key, this.imageAsset, this.imageUrl, required this.child});
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
        Positioned.fill(
          child: imageUrl != null
            ? Image.network(imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) =>
              imageAsset != null
                ? Image.asset(imageAsset!, fit: BoxFit.cover)
                : const ColoredBox(color: Color.fromRGBO(0, 0, 0, 1)))
            : (imageAsset != null
              ? Image.asset(imageAsset!, fit: BoxFit.cover)
              : const ColoredBox(color: Color.fromRGBO(0, 0, 0, 1)))),
      Positioned.fill(
        child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                const Color.fromRGBO(0, 0, 0, 0.35),
                const Color.fromRGBO(0, 0, 0, 0.1)
              ], begin: Alignment.bottomCenter, end: Alignment.topCenter))),
      ),
      child
    ]);
  }
}
