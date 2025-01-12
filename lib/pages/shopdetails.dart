import 'dart:convert'; // To decode JSON
import 'package:flutter/material.dart';

class ShopDetailsPage extends StatelessWidget {
  final Map<String, dynamic> shop;
  final String cartJson; // This is the raw JSON string

  const ShopDetailsPage({
    Key? key,
    required this.shop,
    required this.cartJson, // Raw JSON passed from previous page
  }) : super(key: key);

  /// Decode the cart JSON string into a list of cart items
  List<Map<String, dynamic>> getCartItems() {
    try {
      List<dynamic> decodedCart = jsonDecode(cartJson); // Decode the raw JSON string
      return decodedCart.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      // Handle error if JSON is invalid
      print("Error decoding cart JSON: $e");
      return [];
    }
  }

  /// Calculate the total cost based on the cart items and the shop's rates.
/// Calculate the total cost based on the cart items and the shop's rates.
/// Calculate the total cost based on the cart items and the shop's rates.
double calculateTotalCost(List<Map<String, dynamic>> cartItems) {
  double totalCost = 0.0;
  final rates = shop['rates'] as Map<String, dynamic>;

  for (var item in cartItems) {
    // Safely cast 'copies' and ensure it's an integer
    int copies = int.tryParse(item['copies'].toString()) ?? 0; // Ensure it's a valid integer
    String printService = item['printService'] as String? ?? ''; // Safely cast with fallback value
    print(printService.trim());
    
    // Trim any leading/trailing spaces in the print service name and compare
    double itemCost = 0.0;  // Initialize item cost variable
    
    if (printService.trim().contains("Single-sided Printing")) {
      itemCost = copies.toDouble() * (rates['single_page_print'] ?? 0.0);
    } else if (printService.trim().contains("Double-sided Printing")) {
      itemCost = copies.toDouble() * (rates['double_side_print'] ?? 0.0);
    } else if (printService.trim().contains("Spiral")) {
      itemCost = copies.toDouble() * (rates['spiral_print'] ?? 0.0);
    } else if (printService.trim().contains("Calico")) {
      itemCost = copies.toDouble() * (rates['calico_print'] ?? 0.0);
    } else if (printService.trim().contains("Bond")) {
      itemCost = copies.toDouble() * (rates['bond_sheet'] ?? 0.0);
    }
    
    // Now multiply by numberofcopies (you get numberofcopies from your JSON)
    int numberOfpages = item['numberofpages'] as int? ?? 1;  // Default to 1 if not present
    totalCost += itemCost * numberOfpages;  // Multiply the item cost by numberofcopies
    print(totalCost); // Optionally print the total cost for debugging
  }

  return totalCost;
}

  /// A reusable method to create a stylized card widget
  Widget buildCard({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> cartItems = getCartItems(); // Decode cart items from JSON
    double totalCost = calculateTotalCost(cartItems); // Calculate total cost

    return Scaffold(
      appBar: AppBar(
        title: Text(
          shop['shop_name'] ?? "Shop Details",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 98, 171, 184),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Shop Name: ${shop['shop_name']}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Distance: ${shop['distance_from_point_km']} km",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Your Requirements:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (cartItems.isEmpty)
                    const Text("No items in the cart."),
                  ...cartItems.map((item) {
                    return Text(
                      "- ${item['copies']} copies of ${item['printService']} (${item['colorOption']})",
                      style: const TextStyle(fontSize: 16),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Cost Breakdown:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Printing Cost: ₹$totalCost",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Delivery Charges: ₹0",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Total Amount: ₹${totalCost + 0}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // You can handle any actions like placing an order here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Order Placed Successfully!"),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color.fromARGB(255, 98, 171, 184),
              ),
              child: const Text(
                "Place Order",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
