import 'package:flutter/material.dart';
import 'package:mechconnect/user/home.dart';
import 'package:mechconnect/user/register.dart';
import 'package:mechconnect/user/viewvehicle.dart';

class Addvehicle extends StatefulWidget {
  const Addvehicle({super.key});

  @override
  State<Addvehicle> createState() => _AddvehicleState();
}

class _AddvehicleState extends State<Addvehicle> {
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController vehicleModelController = TextEditingController();
  final TextEditingController vehicleTypeController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController customBrandController = TextEditingController();

  String? selectedBrand;
  String? selectedFuelType;
  bool isLoading = false;

  final List<String> brands = [
    "Toyota",
    "Honda",
    "Suzuki",
    "Hyundai",
    "Ford",
    "BMW",
    "Mercedes",
    "Others",
  ];

  final List<String> fuelTypes = ["Petrol", "Diesel", "Electric", "Hybrid"];

  // -------------------------------------------------------------
  // 🚗 POST VEHICLE FUNCTION — with clear fields after success
  // -------------------------------------------------------------
  Future<void> postVehicle() async {
    if (isLoading) return;
    
    // Validate required fields
    if (vehicleNumberController.text.isEmpty ||
        vehicleModelController.text.isEmpty ||
        vehicleTypeController.text.isEmpty ||
        selectedBrand == null ||
        selectedFuelType == null ||
        yearController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (selectedBrand == "Others" && customBrandController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter custom brand name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    String brandToSave = selectedBrand == "Others" 
        ? customBrandController.text 
        : selectedBrand ?? "";

    try {
      final response = await dio.post(
        '$baseurl/api/vehicle/register',
        data: {
          'userId': obid,
          'brand': brandToSave,
          'model': vehicleModelController.text,
          'fuelType': selectedFuelType,
          'year': yearController.text,
          'vehicleNumber': vehicleNumberController.text,
          'vehicleType': vehicleTypeController.text,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🚗 Vehicle Added Successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // 🔥 CLEAR ALL FIELDS
        setState(() {
          vehicleNumberController.clear();
          vehicleModelController.clear();
          vehicleTypeController.clear();
          yearController.clear();
          customBrandController.clear();

          selectedBrand = null;
          selectedFuelType = null;
        });

        // Optional: Navigate to view page after successful addition
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => Viewvehicle()),
        // );
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add vehicle'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
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
                                "Add New Vehicle",
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
                          "Register your vehicle for service and tracking",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Form Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Icon
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.directions_car,
                                size: 40,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Vehicle Number
                          _buildInputField(
                            controller: vehicleNumberController,
                            label: "Vehicle Number *",
                            icon: Icons.confirmation_number,
                            hint: "e.g., KA01AB1234",
                          ),
                          SizedBox(height: 20),

                          // Vehicle Model
                          _buildInputField(
                            controller: vehicleModelController,
                            label: "Vehicle Model *",
                            icon: Icons.model_training,
                            hint: "e.g., Swift Dzire",
                          ),
                          SizedBox(height: 20),

                          // Vehicle Type
                          _buildInputField(
                            controller: vehicleTypeController,
                            label: "Vehicle Type *",
                            icon: Icons.category,
                            hint: "e.g., Sedan, SUV, Hatchback",
                          ),
                          SizedBox(height: 20),

                          // Brand Dropdown
                          _buildDropdown(
                            value: selectedBrand,
                            label: "Brand *",
                            icon: Icons.branding_watermark,
                            items: brands,
                            onChanged: (value) {
                              setState(() {
                                selectedBrand = value;
                              });
                            },
                          ),
                          SizedBox(height: 20),

                          // Custom Brand Field if "Others" selected
                          if (selectedBrand == "Others")
                            Column(
                              children: [
                                _buildInputField(
                                  controller: customBrandController,
                                  label: "Enter Brand Name *",
                                  icon: Icons.edit,
                                  hint: "Specify vehicle brand",
                                ),
                                SizedBox(height: 20),
                              ],
                            ),

                          // Fuel Type Dropdown
                          _buildDropdown(
                            value: selectedFuelType,
                            label: "Fuel Type *",
                            icon: Icons.local_gas_station,
                            items: fuelTypes,
                            onChanged: (value) {
                              setState(() {
                                selectedFuelType = value;
                              });
                            },
                          ),
                          SizedBox(height: 20),

                          // Year
                          _buildInputField(
                            controller: yearController,
                            label: "Manufacturing Year *",
                            icon: Icons.calendar_today,
                            hint: "e.g., 2020",
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 30),

                          // Add Button
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : postVehicle,
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
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_circle,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "ADD VEHICLE",
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

                          SizedBox(height: 25),

                          // Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade300)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Text(
                                  "View Existing Vehicles",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade300)),
                            ],
                          ),

                          SizedBox(height: 25),

                          // View Details Button
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Viewvehicle()),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.blue.shade700, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                backgroundColor: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.list_alt, color: Colors.blue.shade700),
                                  SizedBox(width: 10),
                                  Text(
                                    "VIEW ALL VEHICLES",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 20),

                          // Required Fields Note
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "* Required fields",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 30),

                  // Footer Note
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Your vehicle information will be used for service booking and tracking",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade900,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(icon, color: Colors.blue),
              ),
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade900,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(icon, color: Colors.blue),
              ),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
              dropdownColor: Colors.white,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue.shade900,
              ),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue.shade900,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              hint: Text(
                "Select $label",
                style: TextStyle(
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}