import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:slider_button/slider_button.dart'; // Import slider_button package
import 'package:printee/pages/outletsSelection.dart';
import 'package:dart_pdf_reader/dart_pdf_reader.dart' as pdf;


class CartPage extends StatefulWidget {
  final List<Map<String, Object>> cartItems; // Accept cart items from parent
  final Function(int) onDelete; // Callback for item deletion
  
  final Future<bool?> Function() onCheckout; // Callback for checkout actio
  const CartPage({
    super.key,
    required this.cartItems,
    required this.onDelete,
    required this.onCheckout,
  });

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isLoading = false; // Track loading state
  double progress = 0.0;
  String progressText = "0%";
  void handleDelete(int index, String filePath) async {
    if (index >= 0 && index < widget.cartItems.length) {
      setState(() {
        isLoading = true; // Show loading animation
      });

      await Future.delayed(const Duration(seconds: 1)); // Simulate delay (optional)

      // Delete the file
      try {
        final file = File(filePath); // Create a File object from the file path
        if (await file.exists()) {
          await file.delete(); // Delete the file
          print("Deleted file: $filePath");
        } else {
          print("File does not exist: $filePath");
        }
      } catch (e) {
        print("Error deleting file: $e");
      }

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
  Future<int> getPdfPageCount(String path) async {
      final stream = pdf.FileStream(File(path).openSync());
      final doc = await pdf.PDFParser(stream).parse();
      final catalog = await doc.catalog;
      final pages = await catalog.getPages();
      return pages.pageCount;
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
                                onPressed: () async {
                                  // Open the file using open_file package
                                  print(files.first);
                                  final dir = await getApplicationDocumentsDirectory();
                                  OpenFile.open("${dir.path}/${files.first}"); // Open the first file (you can customize this)
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
                            Text("Files: $files"),
                            
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
                                      onPressed: () async {
                                        Navigator.pop(context); // Close the dialog
                                        final path = await getApplicationDocumentsDirectory();
                                        final String fileToDelete =
                                            "${path.path}/${files.first}";
                                        handleDelete(index, fileToDelete); // Delete item
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
onPressed: () async {
  try {
    // Fun text messages to show during loading
    List<String> funMessages = [
      "Tom is getting files...",
      "Hold on, we're getting those pages ready...",
      "Making your print job as awesome as you are!",
      "Paper... Ink... Magic!",
      "We're printing dreams into reality!",
      "Your print is taking shape...",
      "Patience, great prints come to those who wait!",
      "Almost there... Like a wizard casting a spell on your prints!"
    ];

    // Function to get a random fun message
    String getRandomMessage() {
      // Randomly select a message from the list
      return funMessages[DateTime.now().millisecondsSinceEpoch % funMessages.length];
    }

    // Show the loading dialog with a circular progress indicator and fun text
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing the dialog
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),  // Circular loader
                const SizedBox(height: 20),
                // Display random fun message
                Text(getRandomMessage(), style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        );
      },
    );

    String filename = (widget.cartItems[0]["files"] as List<String>?)?.join(', ') ?? "No files available";
    final filepath = await getApplicationDocumentsDirectory();
    String path = "${filepath.path}/$filename";

    // Assuming getPdfPageCount is defined and works correctly
    int pageCount = await getPdfPageCount(path);
    print(pageCount);

    // Prepare cart items for JSON encoding
    final serializableCart = widget.cartItems.map((item) {
      return {
        "copies": item["copies"],
        "instructions": item["instructions"],
        "printService": item["printService"],
        "colorOption": item["colorOption"],
        "files": item["files"], // Assuming 'files' is a List<String>
        "numberofpages": pageCount, // Pass the number of pages here
      };
    }).toList();

    final cartJson = jsonEncode(serializableCart);

    // Simulate processing (optional delay for demonstration)
    await Future.delayed(const Duration(seconds: 2));

    // Close the loading dialog
    Navigator.pop(context);

    // Navigate to the ShopListPage with cart data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShopListPage(cartJson: cartJson), // Pass cartJson
      ),
    );
  } catch (e) {
    print("Error: $e");

    // Close the loading dialog in case of error
    Navigator.pop(context);
  }
},






          child: const Text("View Shops"),
        ),
      )
    : null,

    );
  }
}
