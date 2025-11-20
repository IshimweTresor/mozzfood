import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
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

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      // If an initial country was provided, center the map on that country
      if (widget.initialCountry != null) {
        final c = widget.initialCountry!.toLowerCase();
        if (c.contains('rwanda')) {
          // Kigali, Rwanda
          _center = ll.LatLng(-1.9441, 30.0619);
        } else if (c.contains('mozambique')) {
          // Maputo, Mozambique
          _center = ll.LatLng(-25.9653, 32.5832);
        }
      } else {
        final pos = await _determinePosition();
        _center = ll.LatLng(pos.latitude, pos.longitude);
      }

      setState(() {});
      // move the map to the center if controller is ready
      try {
        _mapController.move(_center, 15.0);
      } catch (_) {}
      // load countries for city resolution
      _loadCountries();
    } catch (e) {
      // ignore - keep default center
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
      final res = await http.get(
        uri,
        headers: {'User-Agent': 'mozzfood/1.0 (contact: support@example.com)'},
      );
      if (res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      // ignore errors silently for now
    }
    return null;
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
    super.dispose();
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

      // If not matched, iterate all countries and try to find a city match
      for (final countryItem in _countries) {
        final cidRaw =
            countryItem['id'] ??
            countryItem['countryId'] ??
            countryItem['country_id'];
        int? cid;
        if (cidRaw is int) cid = cidRaw;
        if (cidRaw is String) cid = int.tryParse(cidRaw);
        if (cid == null) continue;
        if (!_citiesCache.containsKey(cid)) {
          final resp = await UserApi.getCitiesByCountry(
            countryId: cid,
            token: token,
          );
          print(
            '🔍 getCitiesByCountry for countryId=$cid: success=${resp.success}, count=${resp.data?.length ?? 0}',
          );
          if (resp.success && resp.data != null) {
            _citiesCache[cid] = resp.data!;
          } else {
            _citiesCache[cid] = [];
          }
        }
        final list = _citiesCache[cid] ?? [];
        for (final c in list) {
          final cname =
              (c['name'] ?? c['cityName'] ?? c['label'] ?? c['title'] ?? '')
                  .toString()
                  .toLowerCase();
          if (cname.isEmpty) continue;
          for (final cand in candidates) {
            if (cand.isEmpty) continue;
            if (cname == cand ||
                cname.contains(cand) ||
                cand.contains(cname) ||
                display.contains(cname) ||
                display.contains(cand)) {
              final idRaw = c['id'] ?? c['cityId'] ?? c['city_id'];
              if (idRaw is int) return idRaw;
              if (idRaw is String) return int.tryParse(idRaw);
            }
          }
        }
      }

      // Heuristic fallback when backend cities are unavailable or empty.
      // Map common Rwanda place names to Kigali (cityId=1) so users in
      // Kigali/Kicukiro/Nyarugenge can create addresses even when
      // `getCitiesByCountry` fails on the server.
      try {
        final detectedCountryLower =
            detectedCountry?.toString().toLowerCase() ?? '';
        if ((detectedCountryLower.contains('rwanda') ||
            detectedCountryLower.contains('rwa'))) {
          for (final cand in candidates) {
            if (cand.contains('kigali') ||
                cand.contains('kicukiro') ||
                cand.contains('nyarugenge') ||
                cand.contains('gasabo')) {
              print('🛠️ Heuristic: mapping "$cand" -> Kigali (cityId=1)');
              return 1;
            }
          }
        }
        // Heuristic: map common Maputo / Mozambique place names to a default
        // backend cityId so the client behaves like the Rwanda flow
        // (which maps Kigali -> cityId=1). We choose `2` as the default
        // Maputo cityId here; change if your backend uses a different id.
        if (detectedCountryLower.contains('mozambique') ||
            detectedCountryLower.contains('moz')) {
          for (final cand in candidates) {
            if (cand.contains('maputo') ||
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

      // If no match but showPickerOnFail is true, present a picker. Prefer
      // the detected-country cities, but if those are empty use the union
      // of all fetched cities from `_citiesCache` so the user can still
      // select a city even when the automatic detection couldn't pick one.
      if (showPickerOnFail && mounted) {
        final List<Map<String, dynamic>> pickerCities = (cities.isNotEmpty)
            ? cities
            : _citiesCache.values.expand((e) => e).toList();

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
                        'Select City',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 300,
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
    final customerId =
        prefs.getString('customer_id') ??
        prefs.getInt('customerId')?.toString() ??
        '0';
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
    if (resp != null && resp.statusCode >= 200 && resp.statusCode < 300) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address created successfully')),
      );
      Navigator.pop(context, {'lat': lat, 'lon': lon, 'address': displayName});
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

  Future<bool> _promptForCityIdAndRetry(
    Map<String, String> params,
    double lat,
    double lon,
    String displayName,
  ) async {
    // Manual numeric city id entry removed. We rely on the backend country/city
    // This function was previously a placeholder. We now prefer the
    // interactive prompt implemented in _promptForNumericCityId. Keep this
    // method for backward-compatibility by delegating to that prompt and
    // performing the retry here when called by legacy callers.
    final manualId = await _promptForNumericCityId();
    if (manualId == null) return false;
    try {
      setState(() => _loading = true);
      final newParams = Map<String, String>.from(params);
      newParams['cityId'] = manualId.toString();
      final retryResp = await _createAddressOnBackend(newParams);
      setState(() => _loading = false);
      return (retryResp != null &&
          retryResp.statusCode >= 200 &&
          retryResp.statusCode < 300);
    } catch (_) {
      setState(() => _loading = false);
      return false;
    }
  }

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
                    setState(() {
                      _center = pos.center;
                    });
                    // debounce reverse geocode while user moves the map
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 700), () {
                      _fetchAddressForCenter();
                    });
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

            // Top bar
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Move the map to pick location',
                        style: TextStyle(color: Colors.black.withOpacity(0.8)),
                      ),
                    ),
                  ),
                ],
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
                            if (_addressLoading)
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
                        onPressed: _loading ? null : _onConfirm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _loading
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
