class CloudinaryUploadResponse {
  final String publicId;
  final String secureUrl;
  final String url;
  final int width;
  final int height;
  final String format;
  final int bytes;

  CloudinaryUploadResponse({
    required this.publicId,
    required this.secureUrl,
    required this.url,
    required this.width,
    required this.height,
    required this.format,
    required this.bytes,
  });

  @override
  String toString() {
    return 'CloudinaryUploadResponse(publicId: $publicId, secureUrl: $secureUrl, width: $width, height: $height)';
  }
}