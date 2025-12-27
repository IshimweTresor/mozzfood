class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final dynamic error;
  final String? referenceId; // 👈 add this

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
    this.referenceId,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) create,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['order'] != null
          ? create(json['order'])
          : null, // backend uses 'order'
      error: json['error'],
      referenceId: json['referenceId'], // 👈 parse here
    );
  }
}
