import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mechconnect/user/complaint.dart';
import 'package:mechconnect/user/feedback.dart';
import 'package:mechconnect/user/home.dart';
import 'package:mechconnect/user/register.dart';

class Report extends StatefulWidget {
  final String? sid;
  final double? latitude;
  final double? longitude;
  final String serviceid;

  Report({
    super.key,
    required this.sid,
    required this.latitude,
    required this.longitude,
    required this.serviceid,
  });

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  TextEditingController reportController = TextEditingController();
  TextEditingController locationController = TextEditingController(); // New location field
  final formKey = GlobalKey<FormState>();
  File? image;
  final ImagePicker picker = ImagePicker();
  bool isLoading = false;
  bool isLoadingVehicles = true;

  List<Map<String, dynamic>> vehicles = [];
  String? selectedVehicleId;
  String? selectedVehicleDisplay;

  @override
  void initState() {
    super.initState();
    getVehicles(context);
    // Pre-fill location with coordinates if available
    if (widget.latitude != null && widget.longitude != null) {
      locationController.text = "${widget.latitude!.toStringAsFixed(6)}, ${widget.longitude!.toStringAsFixed(6)}";
    }
  }

  // Pick image using camera
  Future<void> pickImage() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  // Fetch vehicles from API
  Future<void> getVehicles(BuildContext context) async {
    try {
      final response = await dio.get('$baseurl/api/vehicle/$obid');

      print(response.data);

      if (response.statusCode == 200) {
        setState(() {
          vehicles = List<Map<String, dynamic>>.from(response.data["data"] ?? []);
          isLoadingVehicles = false;
        });
      } else {
        setState(() => isLoadingVehicles = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to fetch vehicles"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("❌ Error fetching vehicles: $e");
      setState(() => isLoadingVehicles = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Post complaint/report
  Future<void> postComplaint() async {
    if (isLoading) return;

    if (selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select a vehicle"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (reportController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please describe the issue"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter your location"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final formData = FormData.fromMap({
        'type': 'servicecenter',
        'userId': obid,
        'problemDiscription': reportController.text,
        'serviceCenterId': widget.sid,
        'vehicleId': selectedVehicleId,
        'userLocation': {
          'lat': widget.latitude.toString(),
          'lng': widget.longitude.toString(),
        },
        'address': locationController.text, // Add location text to API
        'img': image != null
            ? await MultipartFile.fromFile(
                image!.path,
                filename: image!.path.split('/').last,
              )
            : null,
      });

      final response = await dio.post(
        '$baseurl/api/booking/create',
        data: formData,
      );

      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          reportController.clear();
          locationController.clear();
          image = null;
          selectedVehicleId = null;
          selectedVehicleDisplay = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ Report submitted successfully!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("❌ Submission error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error submitting report: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Show vehicle selection bottom sheet
  Future<void> _showVehicleSelectionDialog(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select Vehicle",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Divider(height: 0),
              Expanded(
                child: vehicles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_car_outlined,
                              size: 60,
                              color: Colors.grey.shade300,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "No vehicles found",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Add a vehicle first",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: vehicles.length,
                        itemBuilder: (context, index) {
                          final vehicle = vehicles[index];
                          final isSelected = selectedVehicleId == vehicle['_id'];

                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.blue.shade300
                                    : Colors.grey.shade200,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedVehicleId = vehicle['_id'];
                                  selectedVehicleDisplay =
                                      "${vehicle['brand']} ${vehicle['model']} - ${vehicle['vehicleNumber']}";
                                });
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.directions_car,
                                        color: Colors.blue.shade700,
                                        size: 22,
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${vehicle['brand']} ${vehicle['model']}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue.shade900,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            vehicle['vehicleNumber'] ?? "",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  vehicle['vehicleType'] ?? "",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.blue.shade700,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  vehicle['fuelType'] ?? "",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.green.shade700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 24,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Close",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade700,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Report Issue",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Describe your vehicle issue for service booking",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Main Form Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Camera Section
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  "Upload Vehicle Photo",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                SizedBox(height: 15),
                                InkWell(
                                  onTap: pickImage,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.blue.shade200,
                                        width: 3,
                                        style: BorderStyle.solid,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.1),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: image != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(17),
                                            child: Image.file(
                                              image!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.camera_alt,
                                                size: 40,
                                                color: Colors.blue.shade700,
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                "Tap to Capture",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                if (image != null)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 16,
                                          color: Colors.green,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          "Photo captured",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          SizedBox(height: 30),

                          // Vehicle Selection
                          Text(
                            "Select Vehicle *",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          SizedBox(height: 10),

                          if (isLoadingVehicles)
                            _buildLoadingContainer()
                          else if (vehicles.isEmpty)
                            _buildNoVehiclesContainer()
                          else
                            _buildVehicleDropdown(),

                          if (selectedVehicleId != null)
                            _buildSelectedVehicleIndicator(),

                          SizedBox(height: 30),

                          // Location Field (Added after vehicle selection)
                          Text(
                            "Service Location *",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextFormField(
                              controller: locationController,
                              
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(15),
                                hintText:
                                    "Enter your address or location where service is needed",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.location_on,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              style: TextStyle(fontSize: 16),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your location';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 8),
                          if (widget.latitude != null && widget.longitude != null)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.gps_fixed,
                                    size: 16,
                                    color: Colors.blue.shade700,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Coordinates auto-filled: ${widget.latitude!.toStringAsFixed(6)}, ${widget.longitude!.toStringAsFixed(6)}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          SizedBox(height: 30),

                          // Problem Description
                          Text(
                            "Describe the Issue *",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextFormField(
                              controller: reportController,
                              maxLines: 8,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(15),
                                hintText:
                                    "Describe the problem with your vehicle in detail...\n\nExample:\n• Engine noise when accelerating\n• Brakes feel soft\n• AC not cooling properly\n• Check engine light is on",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                              ),
                              style: TextStyle(fontSize: 16),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please describe the issue';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Tip: Be as detailed as possible for better service.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                          SizedBox(height: 40),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed:
                                  isLoading ? null : () => postComplaint(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                                shadowColor: Colors.blue.shade300,
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.send,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "SUBMIT REPORT",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 1.1,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          SizedBox(height: 30),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                  child: Divider(color: Colors.grey.shade300)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Text(
                                  "Other Actions",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Divider(color: Colors.grey.shade300)),
                            ],
                          ),

                          SizedBox(height: 25),

                          // Action Buttons Grid
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            children: [
                              // Complaint Button
                              _buildActionButton(
                                icon: Icons.report_problem,
                                title: "Complaint",
                                subtitle: "File a complaint",
                                color: Colors.orange,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Complaint(
                                          serviceid: widget.serviceid),
                                    ),
                                  );
                                },
                              ),

                              // Feedback Button
                              _buildActionButton(
                                icon: Icons.feedback,
                                title: "Feedback",
                                subtitle: "Share feedback",
                                color: Colors.green,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Feedbackpage(
                                          serviceid: widget.serviceid),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          SizedBox(height: 20),

                          // Required Fields Note
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "* Required fields for service booking",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildLoadingContainer() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(width: 15),
          Text(
            "Loading vehicles...",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      )
    );
  }

  Widget _buildNoVehiclesContainer() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber,
              color: Colors.orange.shade700, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "No vehicles found. Please add a vehicle first.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange.shade700,
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget _buildVehicleDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: () {
          _showVehicleSelectionDialog(context);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 16),
          child: Row(
            children: [
              Icon(Icons.directions_car, color: Colors.blue, size: 22),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  selectedVehicleDisplay ?? "Choose your vehicle",
                  style: TextStyle(
                    fontSize: 16,
                    color: selectedVehicleDisplay != null
                        ? Colors.blue.shade900
                        : Colors.grey.shade500,
                    fontWeight: selectedVehicleDisplay != null
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedVehicleIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade100),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Selected: $selectedVehicleDisplay",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}