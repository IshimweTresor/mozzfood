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

    // Handle relative URLs by prepending the base URL
    String finalUrl = url!.trim();

    // If the URL doesn't start with http, it's likely a relative path
    if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
      // Prepend the backend base URL
      final baseUrl = 'https://delivery.apis.ivas.rw';
      // Remove leading slash if present to avoid double slashes
      if (finalUrl.startsWith('/')) {
        finalUrl = '$baseUrl$finalUrl';
      } else {
        finalUrl = '$baseUrl/$finalUrl';
      }
    }

    print('🖼️ DEBUG: Loading image from URL: $finalUrl');

    // Encode the URL to avoid spaces or other invalid chars breaking the fetch.
    final encoded = Uri.encodeFull(finalUrl);

    return Image.network(
      encoded,
      width: width,
      height: height,
      fit: fit,
      // If the backend returns HTML (e.g. an error page) or the image can't be
      // decoded, this prevents an unhandled exception and shows the placeholder.
      errorBuilder: (context, error, stackTrace) {
        print('❌ DEBUG: Failed to load image from: $encoded');
        print('❌ DEBUG: Error: $error');
        return placeholder ?? _defaultPlaceholder(context);
      },
      // On web, some invalid bytes can cause issues; this still uses errorBuilder
      // to catch problems.
    );
  }
}
