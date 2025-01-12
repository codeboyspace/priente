import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:printee/constraints.dart';
import 'package:printee/pages/shopdetails.dart';
class ShopListPage extends StatefulWidget {
  final String cartJson; // Accept cart data as JSON

  const ShopListPage({Key? key, required this.cartJson}) : super(key: key);

  @override
  State<ShopListPage> createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage> {
  late Future<List<Map<String, dynamic>>> shopData;
  late List<Map<String, Object>> cartItems; // Change to Object here

  @override
  void initState() {
    super.initState();
    shopData = fetchShops();

    // Decode cart JSON and assign it to cartItems
    try {
      print(jsonDecode(widget.cartJson));
    } catch (e) {
      debugPrint("Error decoding cart JSON: $e");
      cartItems = [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchShops() async {
    const String mongoUri = MONGOURL;
    const String collectionName = COLLECTION_NAME;

    try {
      var db = await mongo.Db.create(mongoUri);
      await db.open();
      var collection = db.collection(collectionName);
      var shops = await collection.find().toList();
      await db.close();
      return shops;
    } catch (e) {
      debugPrint("Error fetching shops: $e");
      throw Exception("Failed to fetch data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Vendor",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 98, 171, 184),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: shopData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No shops found"));
          } else {
            final List<Map<String, dynamic>> shops = snapshot.data!;
            return ListView.builder(
              itemCount: shops.length,
              itemBuilder: (context, index) {
                final shop = shops[index];
                final rates = shop['rates'] as Map<String, dynamic>;

                return GestureDetector(
                  onTap: () {
  // Decode the raw JSON string into List<Map<String, dynamic>>
  List<Map<String, dynamic>> decodedCartItems = [];
  try {
    decodedCartItems = List<Map<String, dynamic>>.from(jsonDecode(widget.cartJson));
  } catch (e) {
    print("Error decoding cart JSON: $e");
  }

  // Navigate to ShopDetailsPage and pass the decoded cart items
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ShopDetailsPage(
        shop: shop,
        cartJson: widget.cartJson, // Pass the raw JSON string to ShopDetailsPage
      ),
    ),
  );
},

                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Shop Icon
                          CircleAvatar(
                            radius: 35,
                            backgroundColor:
                                const Color.fromARGB(150, 98, 171, 184),
                            child: const Icon(
                              Icons.store,
                              size: 40,
                              color: Color.fromARGB(255, 98, 171, 184),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Shop Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shop['shop_name'] ?? "Unknown Shop",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Color.fromARGB(255, 98, 171, 184),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Distance: ${shop['distance_from_point_km']} km",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Rates:",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                    "  - Single Page Print: ₹${rates['single_page_print']}"),
                                Text(
                                    "  - Double Side Print: ₹${rates['double_side_print']}"),
                                Text(
                                    "  - Calico Print: ₹${rates['calico_print']}"),
                                Text(
                                    "  - Spiral Binding: ₹${rates['spiral_binding']}"),
                                Text("  - Binding: ₹${rates['bond_sheet']}"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
