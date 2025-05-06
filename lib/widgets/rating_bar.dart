import 'package:flutter/material.dart';

class RatingBar extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  final int maxRating;

  const RatingBar({
    super.key,
    required this.rating,
    this.size = 16,
    this.color = Colors.amber,
    this.maxRating = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        if (index < rating.floor()) {
          // Full star
          return Icon(
            Icons.star,
            color: color,
            size: size,
          );
        } else if (index == rating.floor() && rating % 1 > 0) {
          // Partial star
          return Stack(
            children: [
              Icon(
                Icons.star,
                color: Colors.grey.shade300,
                size: size,
              ),
              ClipRect(
                clipper: _StarClipper(part: rating % 1),
                child: Icon(
                  Icons.star,
                  color: color,
                  size: size,
                ),
              ),
            ],
          );
        } else {
          // Empty star
          return Icon(
            Icons.star,
            color: Colors.grey.shade300,
            size: size,
          );
        }
      }),
    );
  }
}

class _StarClipper extends CustomClipper<Rect> {
  final double part;

  _StarClipper({required this.part});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * part, size.height);
  }

  @override
  bool shouldReclip(_StarClipper oldClipper) => oldClipper.part != part;
}
