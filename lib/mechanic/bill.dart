import 'package:flutter/material.dart';
import 'package:mechconnect/mechanic/home.dart';

class BillPage extends StatefulWidget {
  const BillPage({super.key});

  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  final TextEditingController mechanicController = TextEditingController();
  final TextEditingController serviceChargeController = TextEditingController();
  List<ProductItem> products = [];
  double totalAmount = 0.0;

  void calculateTotal() {
    double serviceCharge =
        double.tryParse(serviceChargeController.text.trim()) ?? 0.0;

    double productTotal = 0.0;
    for (var p in products) {
      productTotal += double.tryParse(p.priceController.text.trim()) ?? 0.0;
    }

    setState(() {
      totalAmount = productTotal + serviceCharge;
    });
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
              /// Mechanic Name
              formTitle("Mechanic Name"),
              buildInput(mechanicController),

              const SizedBox(height: 18),

              /// Service Charge
              formTitle("Service Charge"),
              buildInput(
                serviceChargeController,
                number: true,
                onChanged: (_) => calculateTotal(),
              ),

              const SizedBox(height: 25),

              /// Replaced Products Title
              const Text(
                "Replaced Products",
                style: TextStyle(
                  color: Color(0xff4e6e88),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              /// Product List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return productCard(index);
                },
              ),

              const SizedBox(height: 25),

              /// Total Amount
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
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
                      "₹ $totalAmount",
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Homemechanic()),
                    );
                  },
                  child: Text(
                    "submit",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(100, 50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🟦 Product Card UI
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

          /// Product Name
          formTitle("Product Name"),
          buildInput(products[index].nameController),

          const SizedBox(height: 10),

          /// Product Price
          formTitle("Price"),
          buildInput(
            products[index].priceController,
            number: true,
            onChanged: (_) => calculateTotal(),
          ),
        ],
      ),
    );
  }

  /// Reusable Form Title
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

  /// Reusable TextField
  Widget buildInput(
    TextEditingController controller, {
    bool number = false,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xff4e6e88)),
        ),
      ),
    );
  }
}

class ProductItem {
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
}
