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
    String brandToSave =
        selectedBrand == "Others" ? customBrandController.text : selectedBrand ?? "";

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
          'vehicleType':vehicleTypeController.text,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle Added successfully')),
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add vehicle')),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add your vehicles",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Vehicle Number
            TextFormField(
              controller: vehicleNumberController,
              decoration: InputDecoration(
                label: Text("Vehicle number"),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Vehicle Model
            TextFormField(
              controller: vehicleModelController,
              decoration: InputDecoration(
                label: Text("Vehicle model"),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Vehicle Type
            TextFormField(
              controller: vehicleTypeController,
              decoration: InputDecoration(
                label: Text("Vehicle type"),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Brand Dropdown
            DropdownButtonFormField<String>(
              value: selectedBrand,
              decoration: InputDecoration(
                label: Text("Brand"),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: brands
                  .map(
                    (brand) => DropdownMenuItem(
                      value: brand,
                      child: Text(brand),
                    ),
                  )
                  .toList(),
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
                  TextFormField(
                    controller: customBrandController,
                    decoration: InputDecoration(
                      label: Text("Enter Brand"),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),

            // Fuel Type
            DropdownButtonFormField<String>(
              value: selectedFuelType,
              decoration: InputDecoration(
                label: Text("Fuel Type"),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: fuelTypes
                  .map(
                    (fuel) => DropdownMenuItem(
                      value: fuel,
                      child: Text(fuel),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedFuelType = value;
                });
              },
            ),
            SizedBox(height: 20),

            // Year
            TextFormField(
              controller: yearController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                label: Text("Year"),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 30),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Add Button
                ElevatedButton(
                  onPressed: () {
                    postVehicle(); // 🔥 Calling API
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Add",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 10),

                // View Details Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Viewvehicle()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "View Details",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
