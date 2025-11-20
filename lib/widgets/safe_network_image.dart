import 'package:flutter/material.dart';

/// A small wrapper for network images that encodes the URL and provides a
/// graceful fallback when the image can't be loaded (HTML responses, 404s, etc.).
class SafeNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;

  const SafeNetworkImage({
    Key? key,
    this.url,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
  }) : super(key: key);

  Widget _defaultPlaceholder(BuildContext context) => Container(
    width: width,
    height: height,
    color: Colors.grey[300],
    child: const Icon(Icons.broken_image, color: Colors.grey),
  );

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.trim().isEmpty) {
      return placeholder ?? _defaultPlaceholder(context);
    }

    // Encode the URL to avoid spaces or other invalid chars breaking the fetch.
    final encoded = Uri.encodeFull(url!.trim());

    return Image.network(
      encoded,
      width: width,
      height: height,
      fit: fit,
      // If the backend returns HTML (e.g. an error page) or the image can't be
      // decoded, this prevents an unhandled exception and shows the placeholder.
      errorBuilder: (context, error, stackTrace) {
        return placeholder ?? _defaultPlaceholder(context);
      },
      // On web, some invalid bytes can cause issues; this still uses errorBuilder
      // to catch problems.
    );
  }
}
