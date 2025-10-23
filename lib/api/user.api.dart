import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vuba/response/api_response.dart';
import 'package:vuba/response/auth_responses.dart';
import 'package:vuba/response/user_responses.dart';
import '../models/user.model.dart' as user_model;
// Import LoginResponse from user.model.dart
import '../models/user.model.dart' show LoginResponse;
import 'package:vuba/response/user_location_responses.dart';

class UserApi {
  // For Android Emulator, use 10.0.2.2 instead of localhost
  // For real device on same network, use your computer's local IP (e.g., 192.168.x.x)
  // For remote server, use the actual server IP/domain
  static const String baseUrl = 'http://167.235.155.3:8085/api/auth';

  // Alternative: Use this if backend is on your local machine
  // static const String baseUrl = 'http://10.0.2.2:8085/api/auth'; // For Android Emulator
  // static const String baseUrl = 'http://localhost:8085/api/auth'; // For Web/Desktop

  // Helper method to get headers
  static Map<String, String> _getHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Register user and send verification code
  static Future<ApiResponse<RegisterResponse>> registerUser({
    required String name,
    required String phone,
    required String email,
    required String password,
    String role = 'customer',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: _getHeaders(),
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<RegisterResponse>(
          success: true,
          message: data['message'],
          data: RegisterResponse.fromJson(data),
        );
      } else {
        return ApiResponse<RegisterResponse>(
          success: false,
          message: data['message'] ?? 'Registration failed',
          error: data['error'],
        );
      }
    } catch (e) {
      return ApiResponse<RegisterResponse>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Verify registration code
  static Future<ApiResponse<LoginResponse>> verifyCode({
    required String verificationKey,
    required String code,
  }) async {
    try {
      print('🌐 Verify Code API Call:');
      print('   - URL: $baseUrl/verify');
      print('   - Verification Key: $verificationKey');
      print('   - Code: $code');
      print(jsonEncode({'key': verificationKey, 'code': code}));

      final response = await http.post(
        Uri.parse('$baseUrl/verify'),
        headers: _getHeaders(),
        body: jsonEncode({
          'verificationKey': verificationKey, // ✅
          'code': code,
        }),
      );

      print('🌐 Verify Response:');
      print('   - Status: ${response.statusCode}');
      print('   - Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // ✅ Accept both 200 and 201
        return ApiResponse<LoginResponse>(
          success: true,
          message: data['message'],
          data: LoginResponse.fromJson(data),
        );
      } else {
        return ApiResponse<LoginResponse>(
          success: false,
          message: data['message'] ?? 'Verification failed',
          error: data['attemptsLeft']?.toString() ?? data['error']?.toString(),
        );
      }
    } catch (e) {
      print('❌ Verify Code Error: $e');
      return ApiResponse<LoginResponse>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Resend verification code
  static Future<ApiResponse<ResendCodeResponse>> resendCode({
    required String verificationKey,
    String? method, // 'phone' or 'email'
  }) async {
    try {
      print('🌐 Resend Code API Call:');
      print('   - URL: $baseUrl/resend-code');
      print('   - Verification Key: $verificationKey');
      print('   - Method: $method');

      final body = {
        'key': verificationKey, // ✅ Changed from 'verificationKey' to 'key'
      };
      if (method != null) {
        body['method'] = method;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/resend-code'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      print('🌐 Resend Response:');
      print('   - Status: ${response.statusCode}');
      print('   - Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<ResendCodeResponse>(
          success: true,
          message: data['message'],
          data: ResendCodeResponse.fromJson(data),
        );
      } else {
        return ApiResponse<ResendCodeResponse>(
          success: false,
          message: data['message'] ?? 'Failed to resend code',
        );
      }
    } catch (e) {
      print('❌ Resend Code Error: $e');
      return ApiResponse<ResendCodeResponse>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Login user
  static Future<ApiResponse<LoginResponse>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _getHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('🌐 Raw API Response:');
      print('   - Status Code: ${response.statusCode}');
      print('   - Body: ${response.body}');

      if (response.statusCode != 200) {
        String errorMessage = 'Login failed';
        print('❌ Login failed. Status: ${response.statusCode}');
        try {
          final errorData = jsonDecode(response.body);
          print('❌ Error response JSON: $errorData');
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          print('❌ Error response not JSON: ${response.body}');
        }
        return ApiResponse<LoginResponse>(
          success: false,
          message: errorMessage,
        );
      }

      final data = jsonDecode(response.body);
      print('✅ Login success. Response JSON: $data');
      // You may need to update this part based on the actual response structure
      return ApiResponse<LoginResponse>(
        success: true,
        message: data['message'] ?? 'Login successful',
        data: LoginResponse.fromJson(data),
      );
    } catch (e) {
      print('❌ API Error: $e');
      return ApiResponse<LoginResponse>(
        success: false,
        message: 'Network error: Unable to connect to server',
      );
    }
  }

  // Get user profile
  static Future<ApiResponse<user_model.User>> getUserProfile(
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<user_model.User>(
          success: true,
          message: 'Profile retrieved successfully',
          data: user_model.User.fromJson(data['user']),
        );
      } else {
        return ApiResponse<user_model.User>(
          success: false,
          message: data['message'] ?? 'Failed to get profile',
        );
      }
    } catch (e) {
      return ApiResponse<user_model.User>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Update user profile
  static Future<ApiResponse<user_model.User>> updateUserProfile({
    required String token,
    String? name,
    user_model.Location? location,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (location != null) body['location'] = location.toJson();

      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<user_model.User>(
          success: true,
          message: data['message'],
          data: user_model.User.fromJson(data['user']),
        );
      } else {
        return ApiResponse<user_model.User>(
          success: false,
          message: data['message'] ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      return ApiResponse<user_model.User>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Get all users (Admin only)
  static Future<ApiResponse<UsersListResponse>> getAllUsers({
    required String token,
    int page = 1,
    int limit = 10,
    String? role,
    bool? verified,
    String? search,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (role != null) queryParams['role'] = role;
      if (verified != null) queryParams['verified'] = verified.toString();
      if (search != null) queryParams['search'] = search;

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _getHeaders(token: token));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<UsersListResponse>(
          success: true,
          message: data['message'],
          data: UsersListResponse.fromJson(data['data']),
        );
      } else {
        return ApiResponse<UsersListResponse>(
          success: false,
          message: data['message'] ?? 'Failed to get users',
        );
      }
    } catch (e) {
      return ApiResponse<UsersListResponse>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Forgot password
  static Future<ApiResponse<ForgotPasswordResponse>> forgotPassword({
    required String identifier, // email or phone
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: _getHeaders(),
        body: jsonEncode({'identifier': identifier}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<ForgotPasswordResponse>(
          success: true,
          message: data['message'],
          data: ForgotPasswordResponse.fromJson(data),
        );
      } else {
        return ApiResponse<ForgotPasswordResponse>(
          success: false,
          message: data['message'] ?? 'Failed to send reset code',
        );
      }
    } catch (e) {
      return ApiResponse<ForgotPasswordResponse>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Verify reset code
  static Future<ApiResponse<VerifyResetCodeResponse>> verifyResetCode({
    required String resetKey,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-reset-code'),
        headers: _getHeaders(),
        body: jsonEncode({'resetKey': resetKey, 'code': code}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<VerifyResetCodeResponse>(
          success: true,
          message: data['message'],
          data: VerifyResetCodeResponse.fromJson(data),
        );
      } else {
        return ApiResponse<VerifyResetCodeResponse>(
          success: false,
          message: data['message'] ?? 'Invalid reset code',
          error: data['attemptsLeft']?.toString(),
        );
      }
    } catch (e) {
      return ApiResponse<VerifyResetCodeResponse>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Reset password
  static Future<ApiResponse<user_model.User>> resetPassword({
    required String resetKey,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: _getHeaders(),
        body: jsonEncode({
          'resetKey': resetKey,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);
      print('ResetKey used: ${resetKey}');

      if (response.statusCode == 200) {
        return ApiResponse<user_model.User>(
          success: true,
          message: data['message'],
          data: user_model.User.fromJson(data['user']),
        );
      } else {
        return ApiResponse<user_model.User>(
          success: false,
          message: data['message'] ?? 'Failed to reset password',
        );
      }
    } catch (e) {
      return ApiResponse<user_model.User>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Update user role (Admin only)
  static Future<ApiResponse<user_model.User>> updateUserRole({
    required String token,
    required String userId,
    required String role,
    String? reason,
  }) async {
    try {
      final body = {'role': role, if (reason != null) 'reason': reason};

      final response = await http.put(
        Uri.parse('$baseUrl/$userId/role'),
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<user_model.User>(
          success: true,
          message: data['message'],
          data: user_model.User.fromJson(data['user']),
        );
      } else {
        return ApiResponse<user_model.User>(
          success: false,
          message: data['message'] ?? 'Failed to update role',
        );
      }
    } catch (e) {
      return ApiResponse<user_model.User>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Get user role history (Admin only)
  static Future<ApiResponse<RoleHistoryResponse>> getUserRoleHistory({
    required String token,
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$userId/role-history'),
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<RoleHistoryResponse>(
          success: true,
          message: data['message'],
          data: RoleHistoryResponse.fromJson(data['data']),
        );
      } else {
        return ApiResponse<RoleHistoryResponse>(
          success: false,
          message: data['message'] ?? 'Failed to get role history',
        );
      }
    } catch (e) {
      return ApiResponse<RoleHistoryResponse>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Get user's saved locations
  static Future<ApiResponse<UserLocationsResponse>> getUserLocations({
    required String token,
  }) async {
    try {
      print('🌐 Making API call to: $baseUrl/locations');
      print('🔑 Token: ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse('$baseUrl/locations'),
        headers: _getHeaders(token: token),
      );

      print('📡 API Response:');
      print('   - Status: ${response.statusCode}');
      print('   - Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<UserLocationsResponse>(
          success: true,
          message: data['message'],
          data: UserLocationsResponse.fromJson(data['data']),
        );
      } else {
        return ApiResponse<UserLocationsResponse>(
          success: false,
          message: data['message'] ?? 'Failed to get locations',
        );
      }
    } catch (e) {
      print('❌ API Error: $e');
      return ApiResponse<UserLocationsResponse>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Add a new saved location
  static Future<ApiResponse<user_model.SavedLocation>> addUserLocation({
    required String token,
    required String name,
    required String address,
    required double lat,
    required double lng,
    String? phone,
    bool isDefault = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/locations'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'name': name,
          'address': address,
          'lat': lat,
          'lng': lng,
          if (phone != null) 'phone': phone,
          'isDefault': isDefault,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return ApiResponse<user_model.SavedLocation>(
          success: true,
          message: data['message'],
          data: user_model.SavedLocation.fromJson(data['location']),
        );
      } else {
        return ApiResponse<user_model.SavedLocation>(
          success: false,
          message: data['message'] ?? 'Failed to add location',
          error: data['errors']?.join(', '),
        );
      }
    } catch (e) {
      return ApiResponse<user_model.SavedLocation>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Update a saved location
  static Future<ApiResponse<user_model.SavedLocation>> updateUserLocation({
    required String token,
    required String locationId,
    String? name,
    String? address,
    double? lat,
    double? lng,
    String? phone,
    bool? isDefault,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (address != null) body['address'] = address;
      if (lat != null) body['lat'] = lat;
      if (lng != null) body['lng'] = lng;
      if (phone != null) body['phone'] = phone;
      if (isDefault != null) body['isDefault'] = isDefault;

      final response = await http.put(
        Uri.parse('$baseUrl/locations/$locationId'),
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<user_model.SavedLocation>(
          success: true,
          message: data['message'],
          data: user_model.SavedLocation.fromJson(data['location']),
        );
      } else {
        return ApiResponse<user_model.SavedLocation>(
          success: false,
          message: data['message'] ?? 'Failed to update location',
        );
      }
    } catch (e) {
      return ApiResponse<user_model.SavedLocation>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Delete a saved location
  static Future<ApiResponse<void>> deleteUserLocation({
    required String token,
    required String locationId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/locations/$locationId'),
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<void>(success: true, message: data['message']);
      } else {
        return ApiResponse<void>(
          success: false,
          message: data['message'] ?? 'Failed to delete location',
        );
      }
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Update user location preferences
  static Future<ApiResponse<Map<String, dynamic>>> updateLocationPreferences({
    required String token,
    String? addressUsageOption,
    String? country,
    String? province,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (addressUsageOption != null)
        body['addressUsageOption'] = addressUsageOption;
      if (country != null) body['country'] = country;
      if (province != null) body['province'] = province;

      final response = await http.put(
        Uri.parse('$baseUrl/location-preferences'),
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: data['message'],
          data:
              (data['preferences'] is Map)
                  ? Map<String, dynamic>.from(data['preferences'])
                  : <String, dynamic>{},
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: data['message'] ?? 'Failed to update preferences',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Get nearby vendors for user
  static Future<ApiResponse<NearbyVendorsResponse>> getNearbyVendors({
    required String token,
    String? locationId,
    double? lat,
    double? lng,
    double radius = 10.0,
  }) async {
    try {
      final queryParams = <String, String>{'radius': radius.toString()};

      if (locationId != null) {
        queryParams['locationId'] = locationId;
      } else if (lat != null && lng != null) {
        queryParams['lat'] = lat.toString();
        queryParams['lng'] = lng.toString();
      }

      final uri = Uri.parse(
        '$baseUrl/nearby-vendors',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _getHeaders(token: token));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<NearbyVendorsResponse>(
          success: true,
          message: data['message'],
          data: NearbyVendorsResponse.fromJson(data['data']),
        );
      } else {
        return ApiResponse<NearbyVendorsResponse>(
          success: false,
          message: data['message'] ?? 'Failed to get nearby vendors',
        );
      }
    } catch (e) {
      return ApiResponse<NearbyVendorsResponse>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
