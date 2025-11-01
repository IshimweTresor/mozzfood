import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';
import 'location_details_page.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MapLocationPickerPage extends StatefulWidget {
  const MapLocationPickerPage({super.key});

  @override
  State<MapLocationPickerPage> createState() => _MapLocationPickerPageState();
}

class _MapLocationPickerPageState extends State<MapLocationPickerPage> {
  final TextEditingController _searchController = TextEditingController();

  // Mock location data
  final List<Map<String, dynamic>> _locations = [
    {'name': 'Demarrage Top Care', 'type': 'pharmacy', 'color': Colors.pink},
    {'name': 'Karisimbi Cave', 'type': 'restaurant', 'color': Colors.pink},
    {'name': 'Angelus Center', 'type': 'center', 'color': Colors.red},
    {
      'name': 'La maison Léonard & Rosine',
      'type': 'house',
      'color': Colors.grey,
    },
    {'name': 'Divam bar', 'type': 'bar', 'color': Colors.orange},
    {'name': 'Whatsapp Bar', 'type': 'bar', 'color': Colors.orange},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Map Background (simulated with dark container)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFF1A1A1A),
              child: Stack(
                children: [
                  // Simulated map lines
                  Positioned.fill(
                    child: CustomPaint(painter: MapLinesPainter()),
                  ),

                  // Location markers
                  ..._locations.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> location = entry.value;

                    // Position markers at different locations
                    double top = 300 + (index * 80.0) % 400;
                    double left = 50 + (index * 120.0) % 300;

                    return Positioned(
                      top: top,
                      left: left,
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: location['color'],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              location['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            // Top Section with Search
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: Colors.white),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      hintText: 'Search Address/Location',
                                      hintStyle: TextStyle(
                                        color: Colors.white70,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.more_horiz,
                              color: Colors.black,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Pick Delivery location',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Section with Confirm Button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomButton(
                      text: 'Confirm Location',
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            // Controllers for each field
                            final customerIdController = TextEditingController();
                            final cityIdController = TextEditingController();
                            final streetController = TextEditingController();
                            final areaNameController = TextEditingController();
                            final houseNumberController = TextEditingController();
                            final localContactController = TextEditingController();
                            final latitudeController = TextEditingController();
                            final longitudeController = TextEditingController();
                            final usageOptionController = TextEditingController();
                            int addressTypeInt = 0;
                            bool isDefault = false;
                            String? imagePath;
                            File? imageFile;
                            final ImagePicker picker = ImagePicker();

                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom,
                                left: 20,
                                right: 20,
                                top: 20,
                              ),
                              child: SingleChildScrollView(
                                child: StatefulBuilder(
                                  builder: (context, setModalState) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Add Location Details',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        TextField(
                                          decoration: InputDecoration(
                                            labelText: 'Customer ID',
                                          ),
                                          keyboardType: TextInputType.number,
                                          controller: customerIdController,
                                        ),
                                        TextField(
                                          decoration: InputDecoration(
                                            labelText: 'City ID',
                                          ),
                                          keyboardType: TextInputType.number,
                                          controller: cityIdController,
                                        ),
                                        TextField(
                                          decoration: InputDecoration(
                                            labelText: 'Street',
                                          ),
                                          controller: streetController,
                                        ),
                                        TextField(
                                          decoration: InputDecoration(
                                            labelText: 'Area Name',
                                          ),
                                          controller: areaNameController,
                                        ),
                                        TextField(
                                          decoration: InputDecoration(
                                            labelText: 'House Number',
                                          ),
                                          controller: houseNumberController,
                                        ),
                                        TextField(
                                          decoration: InputDecoration(
                                            labelText: 'Local Contact Number',
                                          ),
                                          keyboardType: TextInputType.phone,
                                          controller: localContactController,
                                        ),
                                        TextField(
                                          decoration: InputDecoration(
                                            labelText: 'Latitude',
                                          ),
                                          keyboardType: TextInputType.number,
                                          controller: latitudeController,
                                        ),
                                        TextField(
                                          decoration: InputDecoration(
                                            labelText: 'Longitude',
                                          ),
                                          keyboardType: TextInputType.number,
                                          controller: longitudeController,
                                        ),
                                        DropdownButtonFormField<int>(
                                          decoration: InputDecoration(
                                            labelText: 'Address Type',
                                          ),
                                          value: addressTypeInt,
                                          items: [
                                            DropdownMenuItem(
                                                value: 0,
                                                child: Text('HOME (0)')),
                                            DropdownMenuItem(
                                                value: 1,
                                                child: Text('WORK (1)')),
                                            DropdownMenuItem(
                                                value: 2,
                                                child: Text('OTHER (2)')),
                                          ],
                                          onChanged: (val) {
                                            setModalState(() {
                                              addressTypeInt = val ?? 0;
                                            });
                                          },
                                        ),
                                        TextField(
                                          decoration: InputDecoration(
                                            labelText: 'Usage Option',
                                          ),
                                          controller: usageOptionController,
                                        ),
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: isDefault,
                                              onChanged: (val) {
                                                setModalState(() {
                                                  isDefault = val ?? false;
                                                });
                                              },
                                            ),
                                            Text('Is Default'),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        ElevatedButton.icon(
                                          icon: Icon(Icons.image),
                                          label: Text(imageFile == null ? 'Pick Image' : 'Image Selected'),
                                          onPressed: () async {
                                            final picked = await picker.pickImage(source: ImageSource.gallery);
                                            if (picked != null) {
                                              setModalState(() {
                                                imageFile = File(picked.path);
                                                imagePath = picked.path;
                                              });
                                            }
                                          },
                                        ),
                                        if (imageFile != null)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                            child: Image.file(imageFile!, height: 80),
                                          ),
                                        SizedBox(height: 16),
                                        CustomButton(
                                          text: 'Submit',
                                          onPressed: () async {
                                            final customerId =
                                                int.tryParse(
                                                    customerIdController.text);
                                            final cityId =
                                                int.tryParse(cityIdController.text);
                                            final street = streetController.text;
                                            final areaName = areaNameController.text;
                                            final houseNumber = houseNumberController.text;
                                            final localContact = localContactController.text;
                                            final latitude =
                                                double.tryParse(latitudeController.text);
                                            final longitude =
                                                double.tryParse(longitudeController.text);
                                            final usageOption = usageOptionController.text;
                                            // TODO: Replace with your actual token
                                            final token = 'token';
                                            if (customerId == null || cityId == null || latitude == null || longitude == null) {
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all required fields correctly.')));
                                              return;
                                            }
                                            final queryParams = {
                                              'customerId': customerId.toString(),
                                              'cityId': cityId.toString(),
                                              'street': street,
                                              'areaName': areaName,
                                              'houseNumber': houseNumber,
                                              'localContactNumber': localContact,
                                              'latitude': latitude.toString(),
                                              'longitude': longitude.toString(),
                                              'addressType': addressTypeInt.toString(),
                                              'usageOption': usageOption,
                                              'isDefault': isDefault.toString(),
                                            };
                                            final uri = Uri.parse('http://129.151.188.8:8085/api/locations/createAddresses').replace(queryParameters: queryParams);
                                            final request = http.MultipartRequest('POST', uri);
                                            request.headers.addAll({'Authorization': 'Bearer $token'});
                                            if (imagePath != null && imagePath!.isNotEmpty) {
                                              final imageMultipart = await http.MultipartFile.fromPath('image', imagePath!);
                                              request.files.add(imageMultipart);
                                            }
                                            final streamedResponse = await request.send();
                                            final response = await http.Response.fromStream(streamedResponse);
                                            print('🌐 Create Address Response:');
                                            print('   - Status Code: [32m${response.statusCode}[0m');
                                            print('   - Body: ${response.body}');
                                            Navigator.pop(context);
                                          },
                                        ),
                                        SizedBox(height: 16),
                                      ],
                                    );
                                  },
                                ),
                              )
                              );
                            },
                          );
                        },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            'Google',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.my_location,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              // Center on user location
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..strokeWidth = 1;

    // Draw some random lines to simulate map roads
    for (int i = 0; i < 20; i++) {
      double startX = (i * 50.0) % size.width;
      double startY = (i * 30.0) % size.height;
      double endX = startX + 100;
      double endY = startY + 50;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }

    // Draw curved lines
    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.3,
      size.width,
      size.height * 0.7,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
