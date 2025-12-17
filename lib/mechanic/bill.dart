import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mechconnect/mechanic/home.dart';
import 'package:mechconnect/user/register.dart';

class BillPage extends StatefulWidget {
  final String taskid;
  const BillPage({super.key, required this.taskid});

  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  final TextEditingController mechanicController = TextEditingController();
  final TextEditingController serviceChargeController = TextEditingController();
  List<ProductItem> products = [];
  double totalAmount = 0.0;

  final Dio dio = Dio(); // Dio instance

  void calculateTotal() {
    double serviceCharge =
        double.tryParse(serviceChargeController.text.trim()) ?? 0.0;

    double productTotal = 0.0;
    for (var p in products) {
      double price = double.tryParse(p.priceController.text.trim()) ?? 0.0;
      int quantity = int.tryParse(p.quantityController.text.trim()) ?? 1;
      productTotal += price * quantity;
    }

    setState(() {
      totalAmount = productTotal + serviceCharge;
    });
  }

  // ✅ Submit bill to API
  Future<void> submitBill() async {
    if (mechanicController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter mechanic name")));
      return;
    }

    List<Map<String, dynamic>> productList = products
        .map(
          (p) => {
            "name": p.nameController.text.trim(),
            "price": double.tryParse(p.priceController.text.trim()) ?? 0,
            "quantity": int.tryParse(p.quantityController.text.trim()) ?? 1,
          },
        )
        .toList();

    final data = {
      "serviceCharge":
          double.tryParse(serviceChargeController.text.trim()) ?? 0,
      "replacedProducts": productList,
      "totalAmount": totalAmount,
    };

    try {
      final response = await dio.post(
        "$baseurl/api/booking/${widget.taskid}/generateBill", // replace with your API
        data: data,
        options: Options(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bill submitted successfully")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Homemechanic()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusMessage}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe6eef3),
      appBar: AppBar(
        backgroundColor: const Color(0xff4e6e88),
        title: const Text(
          "Billing",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 3,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff4e6e88),
        onPressed: () {
          setState(() {
            products.add(ProductItem());
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              formTitle("Mechanic Name"),
              buildInput(mechanicController),
              const SizedBox(height: 18),
              formTitle("Service Charge"),
              buildInput(
                serviceChargeController,
                number: true,
                onChanged: (_) => calculateTotal(),
              ),
              const SizedBox(height: 25),
              const Text(
                "Replaced Products",
                style: TextStyle(
                  color: Color(0xff4e6e88),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return productCard(index);
                },
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Amount",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "₹ ${totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Center(
                child: TextButton(
                  onPressed: submitBill,
                  child: const Text(
                    "Submit",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(100, 50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget productCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Product ${index + 1}",
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    products.removeAt(index);
                    calculateTotal();
                  });
                },
              ),
            ],
          ),
          formTitle("Product Name"),
          buildInput(products[index].nameController),
          const SizedBox(height: 10),
          formTitle("Price"),
          buildInput(
            products[index].priceController,
            number: true,
            onChanged: (_) => calculateTotal(),
          ),
          const SizedBox(height: 10),
          formTitle("Quantity"),
          buildInput(
            products[index].quantityController,
            number: true,
            onChanged: (_) => calculateTotal(),
          ),
        ],
      ),
    );
  }

  Widget formTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xff4e6e88),
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget buildInput(
    TextEditingController controller, {
    bool number = false,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      onChanged: onChanged,
    );
  }
}

class ProductItem {
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController(
    text: "1",
  ); // default quantity 1
}
