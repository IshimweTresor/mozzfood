import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as ll;
import 'package:shared_preferences/shared_preferences.dart';

import '../api/user.api.dart';
import '../utils/colors.dart';

class MapLocationPickerPage extends StatefulWidget {
  final String? initialCountry;

  const MapLocationPickerPage({super.key, this.initialCountry});

  @override
  State<MapLocationPickerPage> createState() => _MapLocationPickerPageState();
}

class _MapLocationPickerPageState extends State<MapLocationPickerPage> {
  ll.LatLng _center = ll.LatLng(-1.9441, 30.0619);
  final MapController _mapController = MapController();
  bool _loading = false;
  Timer? _debounce;
  String? _displayAddress;
  bool _addressLoading = false;
  List<Map<String, dynamic>> _countries = [];
  final Map<int, List<Map<String, dynamic>>> _citiesCache = {};

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _showSearchResults = false;
  bool _isSearching = false;
  bool _isInitializingLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLocation();
    });
  }

  Future<void> _initLocation() async {
    setState(() {
      _isInitializingLocation = true;
    });

    bool locationObtained = false;

    try {
      // 1. FAST INITIAL ESTIMATE: Check last known position for instant map centering
      try {
        final lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null) {
          print(
            '📍 Fast estimate (LastKnown): ${lastPos.latitude}, ${lastPos.longitude}',
          );
          _center = ll.LatLng(lastPos.latitude, lastPos.longitude);
          _mapController.move(_center, 15.0);
          setState(() {});
          _fetchAddressForCenter();
        }
      } catch (e) {
        print('Fast estimate error: $e');
      }

      // 2. ACCURATE POSITION: Fetch fresh device location
      try {
        final pos = await _determinePosition().timeout(
          const Duration(seconds: 8),
          onTimeout: () => throw Exception('Timeout'),
        );
        print(
          '📍 Accurate position (Current): ${pos.latitude}, ${pos.longitude}',
        );
        _center = ll.LatLng(pos.latitude, pos.longitude);
        locationObtained = true;
      } catch (e) {
        print('Location fetch error: $e');
        // Fallback to country center only if we still don't have a good position
        if (!locationObtained && widget.initialCountry != null) {
          final c = widget.initialCountry!.toLowerCase();
          if (c.contains('rwanda')) {
            _center = ll.LatLng(-1.9441, 30.0619);
          } else if (c.contains('mozambique')) {
            _center = ll.LatLng(-25.9653, 32.5832);
          }
        }
      }

      if (mounted) {
        setState(() {});
      }

      // move the map to the final center if controller is ready
      try {
        _mapController.move(_center, 15.0);
      } catch (_) {}

      // fetch final address
      await _fetchAddressForCenter();

      // load countries for city resolution
      _loadCountries();

      // Show feedback if location wasn't obtained at all
      if (!locationObtained &&
          _center.latitude == -1.9441 &&
          _center.longitude == 30.0619 &&
          mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Using default location. Enable location services for better accuracy.',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Init location error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializingLocation = false;
        });
      }
    }
  }

  Future<void> _loadCountries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final res = await UserApi.getAllCountries(token: token);
      print(
        '🔍 getAllCountries: status=${res.success}, count=${res.data?.length ?? 0}',
      );
      if (res.success && res.data != null) {
        setState(() {
          _countries = res.data!;
        });
      }
    } catch (_) {}
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<Map<String, dynamic>?> _reverseGeocode(double lat, double lon) async {
    try {
      final uri = Uri.parse('https://nominatim.openstreetmap.org/reverse')
          .replace(
            queryParameters: {
              'format': 'jsonv2',
              'lat': lat.toString(),
              'lon': lon.toString(),
            },
          );
      print('🌐 Reverse geocoding: $lat, $lon');
      final res = await http.get(
        uri,
        headers: {
          'User-Agent': 'MozzFood-Vuba-Mobile-App/1.0',
          'Accept': 'application/json',
          'Referer': 'https://delivery.apis.ivas.rw',
        },
      );
      print('🌐 Geocode response: ${res.statusCode}');
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        print('🌐 Geocode data: $data');
        return data;
      }
    } catch (e) {
      print('❌ Geocode error: $e');
    }
    return null;
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search',
      ).replace(queryParameters: {'q': query, 'format': 'json', 'limit': '10'});
      final res = await http
          .get(
            uri,
            headers: {
              'User-Agent': 'MozzFood-Vuba-Mobile-App/1.0',
              'Accept': 'application/json',
              'Referer': 'https://delivery.apis.ivas.rw',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final results = json.decode(res.body) as List<dynamic>;
        if (mounted) {
          setState(() {
            _searchResults = results
                .cast<Map<String, dynamic>>()
                .where((r) => r['lat'] != null && r['lon'] != null)
                .toList();
            _showSearchResults = _searchResults.isNotEmpty;
            _isSearching = false;
          });
        }
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    } catch (e) {
      print('Search error: $e');
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _selectSearchResult(Map<String, dynamic> result) async {
    final lat = double.tryParse(result['lat'].toString()) ?? 0.0;
    final lon = double.tryParse(result['lon'].toString()) ?? 0.0;

    setState(() {
      _center = ll.LatLng(lat, lon);
      _searchController.clear();
      _showSearchResults = false;
      _searchResults = [];
    });

    try {
      _mapController.move(_center, 16.0);
    } catch (_) {}

    await _fetchAddressForCenter();
  }

  Future<http.Response?> _createAddressOnBackend(
    Map<String, String> params,
  ) async {
    // Delegate to UserApi.createAddresses which already handles the
    // multipart + query parameter contract expected by the backend.
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final customerIdRaw = prefs.get('customer_id');
      int customerId = 0;
      if (customerIdRaw is int) customerId = customerIdRaw;
      if (customerIdRaw is String)
        customerId = int.tryParse(customerIdRaw) ?? 0;

      final cityId = int.tryParse(params['cityId'] ?? '');
      final latitude = double.tryParse(params['latitude'] ?? '') ?? 0.0;
      final longitude = double.tryParse(params['longitude'] ?? '') ?? 0.0;
      final addressType = int.tryParse(params['addressType'] ?? '0') ?? 0;

      final apiResp = await UserApi.createAddresses(
        token: token,
        customerId: customerId,
        cityId: cityId,
        street: params['street'] ?? '',
        areaName: params['areaName'] ?? '',
        houseNumber: params['houseNumber'] ?? '',
        localContactNumber: params['localContactNumber'] ?? '',
        latitude: latitude,
        longitude: longitude,
        addressType: addressType,
        usageOption: params['usageOption'] ?? 'Permanent',
        isDefault: (params['isDefault'] ?? 'true') == 'true',
      );

      // Convert ApiResponse to http.Response-like object to keep callers
      // compatibility with existing code paths.
      final fakeBody = jsonEncode({
        'success': apiResp.success,
        'message': apiResp.message,
        'data': apiResp.data,
      });
      final status = apiResp.success ? 200 : 400;
      return http.Response(fakeBody, status);
    } catch (e) {
      return null;
    }
  }

  Future<void> _fetchAddressForCenter() async {
    setState(() {
      _addressLoading = true;
    });
    try {
      final geocode = await _reverseGeocode(
        _center.latitude,
        _center.longitude,
      );
      final displayName = geocode != null && geocode['display_name'] != null
          ? geocode['display_name'] as String
          : null;
      setState(() {
        _displayAddress = displayName;
      });
    } catch (_) {
      // ignore
    } finally {
      if (mounted) {
        setState(() {
          _addressLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _recenterToDevice() async {
    try {
      setState(() {
        _addressLoading = true;
      });
      final pos = await _determinePosition();
      if (!mounted) return;
      _center = ll.LatLng(pos.latitude, pos.longitude);
      try {
        _mapController.move(_center, 16.0);
      } catch (_) {}
      await _fetchAddressForCenter();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get device location')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _addressLoading = false;
        });
      }
    }
  }

  Future<int?> _resolveCityId(
    String areaName,
    Map<String, dynamic>? geocode, {
    bool showPickerOnFail = false,
  }) async {
    try {
      // Ensure we have countries loaded
      if (_countries.isEmpty) {
        await _loadCountries();
      }

      String? detectedCountry = geocode != null && geocode['address'] is Map
          ? (geocode['address']['country'] as String?)
          : null;
      print('🔎 Detected country from geocode: $detectedCountry');

      // Try to find country by name
      Map<String, dynamic>? country;
      if (detectedCountry != null) {
        final nameLower = detectedCountry.toLowerCase();
        country = _countries.firstWhere((c) {
          final n = (c['name'] ?? c['countryName'] ?? c['country'] ?? '')
              .toString()
              .toLowerCase();
          return n == nameLower ||
              n.contains(nameLower) ||
              nameLower.contains(n);
        }, orElse: () => <String, dynamic>{});
        if (country.isEmpty) country = null;
      }

      int? countryId;
      if (country != null) {
        print('🔎 Matched backend country: ${country}');
        final cid =
            country['id'] ?? country['countryId'] ?? country['country_id'];
        if (cid != null) {
          if (cid is int) countryId = cid;
          if (cid is String) countryId = int.tryParse(cid);
        }
      }

      // If we have a country id, get cities
      List<Map<String, dynamic>> cities = [];
      // Get auth token for protected endpoints
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (countryId != null) {
        if (_citiesCache.containsKey(countryId)) {
          cities = _citiesCache[countryId]!;
        } else {
          final resp = await UserApi.getCitiesByCountry(
            countryId: countryId,
            token: token,
          );
          print(
            '🔍 getCitiesByCountry for countryId=$countryId: success=${resp.success}, count=${resp.data?.length ?? 0}',
          );
          if (resp.success && resp.data != null) {
            cities = resp.data!;
            _citiesCache[countryId] = cities;
          }
        }
      }

      // Build candidate names from many possible address components and display_name
      final List<String> candidates = [];
      if (geocode != null && geocode['address'] is Map) {
        final addr = Map<String, dynamic>.from(geocode['address']);
        for (final key in [
          'city',
          'town',
          'village',
          'county',
          'state',
          'region',
          'municipality',
          'city_district',
          'state_district',
        ]) {
          final v = addr[key];
          if (v != null && v.toString().trim().isNotEmpty)
            candidates.add(v.toString().toLowerCase());
        }
      }
      if (areaName.isNotEmpty) candidates.add(areaName.toLowerCase());
      final display = geocode != null && geocode['display_name'] != null
          ? geocode['display_name'].toString().toLowerCase()
          : '';
      if (display.isNotEmpty) {
        // add comma-separated parts as candidates
        for (final part in display.split(',')) {
          final p = part.trim();
          if (p.isNotEmpty) candidates.add(p.toLowerCase());
        }
      }
      print('🔎 Candidate city name parts: $candidates');

      // Try matching within detected-country cities first
      for (final c in cities) {
        final cname =
            (c['name'] ?? c['cityName'] ?? c['label'] ?? c['title'] ?? '')
                .toString()
                .toLowerCase();
        if (cname.isEmpty) continue;
        for (final cand in candidates) {
          if (cand.isEmpty) continue;
          if (cname == cand || cname.contains(cand) || cand.contains(cname)) {
            print('✅ Candidate matched city: $cname');
            final idRaw = c['id'] ?? c['cityId'] ?? c['city_id'];
            if (idRaw is int) return idRaw;
            if (idRaw is String) return int.tryParse(idRaw);
          }
        }
      }

      // Heuristic fallback when backend cities are unavailable or empty.
      try {
        final detectedCountryLower =
            detectedCountry?.toString().toLowerCase() ?? '';
        final isRwanda =
            detectedCountryLower.contains('rwanda') ||
            detectedCountryLower.contains('rwa');
        final isMoz =
            detectedCountryLower.contains('mozambique') ||
            detectedCountryLower.contains('moz');

        if (isRwanda) {
          for (final cand in candidates) {
            if (cand.contains('kigali') ||
                cand.contains('kicukiro') ||
                cand.contains('nyarugenge') ||
                cand.contains('gasabo')) {
              print('🛠️ Heuristic: mapping "$cand" -> Kigali (cityId=1)');
              return 1;
            }
            if (cand.contains('rwamagana') ||
                cand.contains('kayonza') ||
                cand.contains('kibungo')) {
              print(
                '🛠️ Heuristic: mapping "$cand" -> Rwamagana/Eastern (cityId=3)',
              );
              return 3;
            }
            if (cand.contains('musanze') ||
                cand.contains('ruhengeri') ||
                cand.contains('gakenke')) {
              print(
                '🛠️ Heuristic: mapping "$cand" -> Musanze/Northern (cityId=4)',
              );
              return 4;
            }
            if (cand.contains('rubavu') ||
                cand.contains('gisenyi') ||
                cand.contains('karongi') ||
                cand.contains('kibuye')) {
              print(
                '🛠️ Heuristic: mapping "$cand" -> Rubavu/Western (cityId=5)',
              );
              return 5;
            }
            if (cand.contains('huy' /* huye */) ||
                cand.contains('butare') ||
                cand.contains('nyanza')) {
              print(
                '🛠️ Heuristic: mapping "$cand" -> Huye/Southern (cityId=6)',
              );
              return 6;
            }
          }
        }

        if (isMoz) {
          for (final cand in candidates) {
            if (cand.contains('maputo') ||
                cand.contains('matola') ||
                cand.contains('zona sul') ||
                cand.contains('zona norte') ||
                cand.contains('zona') ||
                cand.contains('central')) {
              const defaultMaputoCityId = 2;
              print(
                '🛠️ Heuristic: mapping "$cand" -> Maputo (cityId=$defaultMaputoCityId)',
              );
              return defaultMaputoCityId;
            }
          }
        }
      } catch (_) {}

      // removed extensive fallback loop over ALL countries to prevent UI hang

      // If no match but showPickerOnFail is true, present a picker.
      if (showPickerOnFail && mounted) {
        print(
          '🛠️ Fallback: No city matched, trying to populate picker. Countries count: ${_countries.length}',
        );

        // Try to fetch cities if cache is empty
        if (_citiesCache.isEmpty) {
          print('🛠️ Fallback: Cache empty, attempting fetch...');
          for (final countryItem in _countries) {
            final cidRaw =
                countryItem['id'] ??
                countryItem['countryId'] ??
                countryItem['country_id'];
            int? cid;
            if (cidRaw is int) cid = cidRaw;
            if (cidRaw is String) cid = int.tryParse(cidRaw);
            if (cid != null) {
              final resp = await UserApi.getCitiesByCountry(
                countryId: cid,
                token: token,
              );
              if (resp.success && resp.data != null) {
                _citiesCache[cid] = resp.data!;
              }
            }
          }
        }

        List<Map<String, dynamic>> pickerCities = _citiesCache.values
            .expand((e) => e)
            .toList();

        // OFFLINE FALLBACK: If still empty (e.g. 404), use hardcoded list
        if (pickerCities.isEmpty) {
          print('🛠️ Fallback: API failed, using hardcoded offline cities.');
          pickerCities = [
            {'id': 1, 'name': 'Kigali (Rwanda)'},
            {'id': 3, 'name': 'Rwamagana (Rwanda)'},
            {'id': 4, 'name': 'Musanze (Rwanda)'},
            {'id': 5, 'name': 'Rubavu (Rwanda)'},
            {'id': 6, 'name': 'Huye (Rwanda)'},
            {'id': 2, 'name': 'Maputo (Mozambique)'},
          ];
        }

        print('🛠️ Picker cities total count: ${pickerCities.length}');

        if (pickerCities.isNotEmpty) {
          final picked = await showModalBottomSheet<int?>(
            context: context,
            builder: (ctx) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Select City / Province',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        itemCount: pickerCities.length,
                        itemBuilder: (context, index) {
                          final city = pickerCities[index];
                          final name =
                              (city['name'] ??
                                      city['cityName'] ??
                                      city['label'] ??
                                      city['title'] ??
                                      '')
                                  .toString();
                          return ListTile(
                            title: Text(name),
                            trailing: const Icon(Icons.chevron_right, size: 16),
                            onTap: () {
                              final idRaw =
                                  city['id'] ??
                                  city['cityId'] ??
                                  city['city_id'];
                              int? id;
                              if (idRaw is int) id = idRaw;
                              if (idRaw is String) id = int.tryParse(idRaw);
                              Navigator.of(ctx).pop(id);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
          return picked;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _onConfirm() async {
    setState(() => _loading = true);
    final lat = _center.latitude;
    final lon = _center.longitude;

    final geocode = await _reverseGeocode(lat, lon);

    String displayName = geocode != null && geocode['display_name'] != null
        ? geocode['display_name'] as String
        : 'Selected location';
    final address = geocode != null && geocode['address'] is Map
        ? Map<String, dynamic>.from(geocode['address'])
        : <String, dynamic>{};

    final prefs = await SharedPreferences.getInstance();
    final customerIdRaw = prefs.get('customer_id');
    String customerId = '0';
    if (customerIdRaw is int) {
      customerId = customerIdRaw.toString();
    } else if (customerIdRaw is String) {
      customerId = customerIdRaw;
    } else {
      customerId = prefs.getInt('customerId')?.toString() ?? '0';
    }

    final localPhone =
        prefs.getString('phone') ?? prefs.getString('localContactNumber') ?? '';

    final areaName =
        address['city'] ??
        address['town'] ??
        address['county'] ??
        address['state'] ??
        '';

    // Try to resolve city id automatically via backend. If unresolved,
    // show the picker so the user can select the correct city before
    // attempting to create the address (backend requires `cityId`).
    int? resolvedCityId = await _resolveCityId(
      areaName,
      geocode,
      showPickerOnFail: false,
    );

    if (resolvedCityId == null) {
      // Ask the user to pick from backend-provided cities
      resolvedCityId = await _resolveCityId(
        areaName,
        geocode,
        showPickerOnFail: true,
      );
      if (resolvedCityId == null) {
        // Could not resolve a city id — abort and inform the user.
        setState(() => _loading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a city before creating the address.'),
          ),
        );
        return;
      }
    }

    final params = <String, String>{
      'customerId': customerId,
      'cityId': resolvedCityId.toString(),
      'street': displayName,
      'areaName': areaName,
      'houseNumber': '',
      'localContactNumber': localPhone,
      'latitude': lat.toString(),
      'longitude': lon.toString(),
      'addressType': '0',
      'usageOption': 'Permanent',
      'isDefault': 'true',
    };

    final resp = await _createAddressOnBackend(params);
    setState(() => _loading = false);

    print('🌐 Create address response: ${resp?.statusCode}');
    print('🌐 Response body: ${resp?.body}');

    if (resp != null && resp.statusCode >= 200 && resp.statusCode < 300) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // Return result to trigger refresh
      Navigator.pop(context, {
        'lat': lat,
        'lon': lon,
        'address': displayName,
        'success': true,
      });
    } else {
      if (!mounted) return;
      final details = resp == null
          ? 'No response (network or timeout).'
          : 'Status ${resp.statusCode}: ${resp.body}';

      // If server returned 400 (city id not found) allow the user to enter a
      // numeric cityId and retry as a quick client-side workaround.
      if (resp != null && resp.statusCode == 400) {
        // Try resolving a city id by showing backend-provided cities first.
        final pickedCityId = await _resolveCityId(
          areaName,
          geocode,
          showPickerOnFail: true,
        );
        if (pickedCityId != null) {
          final newParams = Map<String, String>.from(params);
          newParams['cityId'] = pickedCityId.toString();
          setState(() => _loading = true);
          final retryResp = await _createAddressOnBackend(newParams);
          setState(() => _loading = false);
          if (retryResp != null &&
              retryResp.statusCode >= 200 &&
              retryResp.statusCode < 300) {
            if (!mounted) return;
            print('✅ Address created successfully with picked city');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Address created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, {
              'lat': lat,
              'lon': lon,
              'address': displayName,
              'success': true,
            });
            return;
          }
        }

        // If backend cities are unavailable, prompt the user to enter a numeric
        // cityId manually (useful when server-side static resources are missing).
        final manualId = await _promptForNumericCityId();
        if (manualId != null) {
          final newParams = Map<String, String>.from(params);
          newParams['cityId'] = manualId.toString();
          setState(() => _loading = true);
          final retryResp = await _createAddressOnBackend(newParams);
          setState(() => _loading = false);
          if (retryResp != null &&
              retryResp.statusCode >= 200 &&
              retryResp.statusCode < 300) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Address created successfully')),
            );
            Navigator.pop(context, {
              'lat': lat,
              'lon': lon,
              'address': displayName,
            });
            return;
          }
        }

        // If we still couldn't resolve, show an informative error.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to resolve city — address not created.'),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create address. $details')),
      );
    }
  }

  // Unused - kept for backward compatibility reference
  // Future<bool> _promptForCityIdAndRetry(
  //   Map<String, String> params,
  //   double lat,
  //   double lon,
  //   String displayName,
  // ) async {
  //   final manualId = await _promptForNumericCityId();
  //   if (manualId == null) return false;
  //   try {
  //     setState(() => _loading = true);
  //     final newParams = Map<String, String>.from(params);
  //     newParams['cityId'] = manualId.toString();
  //     final retryResp = await _createAddressOnBackend(newParams);
  //     setState(() => _loading = false);
  //     return (retryResp != null &&
  //         retryResp.statusCode >= 200 &&
  //         retryResp.statusCode < 300);
  //   } catch (_) {
  //     setState(() => _loading = false);
  //     return false;
  //   }
  // }

  Future<int?> _promptForNumericCityId() async {
    final TextEditingController ctl = TextEditingController();
    final result = await showDialog<int?>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Enter City ID'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'The server city list is unavailable. Please enter the numeric city ID provided by the admin or backend so we can create this address.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'e.g. 12'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final v = int.tryParse(ctl.text.trim());
                Navigator.of(ctx).pop(v);
              },
              child: const Text('Use ID'),
            ),
          ],
        );
      },
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: 15.0,
                  onPositionChanged: (pos, hasGesture) {
                    if (pos.center.latitude == _center.latitude &&
                        pos.center.longitude == _center.longitude) {
                      return;
                    }
                    setState(() {
                      _center = pos.center;
                    });
                    // debounce reverse geocode while user moves the map
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 700), () {
                      _fetchAddressForCenter();
                    });
                  },
                  onTap: (tapPosition, point) {
                    setState(() {
                      _center = point;
                    });
                    _mapController.move(point, _mapController.camera.zoom);
                    _fetchAddressForCenter();
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'mozzfood.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _center,
                        width: 60,
                        height: 60,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 48,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Top bar with search
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            cursorColor: Colors.black,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            onChanged: (value) {
                              _debounce?.cancel();
                              _debounce = Timer(
                                const Duration(milliseconds: 300),
                                () {
                                  _searchLocation(value);
                                },
                              );
                            },
                            decoration: InputDecoration(
                              hintText: 'Search location...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchResults = [];
                                          _showSearchResults = false;
                                        });
                                      },
                                      child: const Icon(
                                        Icons.clear,
                                        color: Colors.grey,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Search results dropdown
                  if (_showSearchResults && _searchResults.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 250),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final result = _searchResults[index];
                            final displayName =
                                result['display_name'] as String? ?? '';
                            return ListTile(
                              leading: const Icon(
                                Icons.location_on_outlined,
                                size: 20,
                                color: Colors.grey,
                              ),
                              title: Text(
                                displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                              ),
                              onTap: () {
                                _selectSearchResult(result);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  if (_isSearching && _searchController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: SizedBox(
                        height: 30,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Recenter button (fetch device location and move map)
            Positioned(
              top: 72,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                heroTag: 'recenter_btn',
                backgroundColor: AppColors.primary,
                tooltip: 'Recenter to my location',
                onPressed: _recenterToDevice,
                child: const Icon(
                  Icons.my_location,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),

            // Compact bottom confirm sheet
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isInitializingLocation)
                              const Text(
                                'Getting your location...',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            else
                              Text(
                                _displayAddress ??
                                    '${_center.latitude.toStringAsFixed(6)}, ${_center.longitude.toStringAsFixed(6)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (_addressLoading && !_isInitializingLocation)
                              const Padding(
                                padding: EdgeInsets.only(top: 6.0),
                                child: SizedBox(
                                  height: 12,
                                  width: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            if (_isInitializingLocation)
                              const Padding(
                                padding: EdgeInsets.only(top: 6.0),
                                child: SizedBox(
                                  height: 12,
                                  width: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: (_loading || _isInitializingLocation)
                            ? null
                            : _onConfirm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: (_loading || _isInitializingLocation)
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Confirm'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
