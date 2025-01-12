import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class CartPage extends StatefulWidget {
  final List<Map<String, Object>> cartItems; // Accept cart items from parent
  final Function(int) onDelete; // Callback for item deletion
  final VoidCallback onCheckout; // Callback for checkout action

  const CartPage({
    Key? key,
    required this.cartItems,
    required this.onDelete,
    required this.onCheckout,
  }) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isLoading = false; // Track loading state

  void handleDelete(int index) async {
    if (index >= 0 && index < widget.cartItems.length) {
      setState(() {
        isLoading = true; // Show loading animation
      });

      await Future.delayed(const Duration(seconds: 1)); // Simulate delay (optional)

      widget.onDelete(index); // Notify parent about the deletion

      setState(() {
        widget.cartItems.removeAt(index); // Update local cart items
        isLoading = false; // Hide loading animation
      });

      if (widget.cartItems.isEmpty) {
        Navigator.pop(context); // Close CartPage if no items are left
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart"),
      ),
      body: Stack(
        children: [
          widget.cartItems.isNotEmpty
              ? ListView.builder(
                  itemCount: widget.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = widget.cartItems[index];
                    final files = (item['files'] as List<String>?) ?? [];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: ListTile(
                        leading: files.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.insert_drive_file, color: Colors.blue),
                                onPressed: () {
                                  // Open the file using open_file package
                                  print(files.first);
                                  OpenFile.open("/data/user/0/com.example.printee/app_flutter/${files.first}"); // Open the first file (you can customize this)
                                },
                              )
                            : null, // Show the icon only if there are files
                        title: Text("Copies: ${item['copies']}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Instructions: ${item['instructions']}"),
                            Text("Print Service: ${item['printService']}"),
                            Text("Color Option: ${item['colorOption']}"),
                            Text("Files: ${files.join(", ")}"),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Confirm Deletion"),
                                  content: const Text(
                                      "Are you sure you want to remove this item from the cart?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context); // Close the dialog
                                      },
                                      child: const Text("No"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context); // Close the dialog
                                        handleDelete(index); // Delete item
                                      },
                                      child: const Text("Yes"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text("Your cart is empty."),
                ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5), // Semi-transparent background
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: widget.cartItems.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: widget.onCheckout,
                child: const Text("Checkout"),
              ),
            )
          : null,
    );
  }
}
