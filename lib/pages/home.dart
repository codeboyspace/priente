import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:printee/pages/cartPage.dart';
import 'package:stroke_text/stroke_text.dart';
import 'package:printee/pages/setLocation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  static const Color accentBlue = Color(0xFF7E8ABE);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFF44336);

  final TextEditingController _copiesController = TextEditingController();
  final PageController _pageController = PageController();
  List<Map<String, Object?>> _cartItems = [];
  int _currentPage = 0;
  int _selectedTabIndex = 0;
  bool _isLocationSet = false;
  String? _locationCoordinates;
  bool _isButtonEnabled = false;
  final TextEditingController _instructionsController = TextEditingController();

  final List<String> _printServices = [
    'Single-sided Printing\t\t2rs/page',
    'Double-sided Printing\t\t2rs/page',
    'Calico\t\t2rs/page',
    'Spiral\t\t2rs/page',
    'Bond Sheet Printing\t\t10rs/page',
    'Others',
  ];
  final List<String> _printcolorselection = [
    'Color',
    'Black and White',
    'Both(Refer Instructions)',
  ];

  String? _selectedPrintService;
  String? _selectedColorOption;
  final List<PlatformFile> _selectedFiles = [];

  String _getTotalFileSize() {
    if (_selectedFiles.isEmpty) return "0";
    int totalSizeInBytes =
        _selectedFiles.fold(0, (sum, file) => sum + file.size);
    double totalSizeInMB = totalSizeInBytes / (1024 * 1024);
    return totalSizeInMB.toStringAsFixed(2);
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc', 'png'],
        allowMultiple: false,
        withReadStream: true,
        withData: false,
      );

      if (result != null) {
        final file = result.files.first;
        final newfail = await savefilepermanently(file);
        print("From path${file.path!}");
        print("To path${newfail.path}");
        _selectedFiles.add(file);
      } else {
        _showSnackBar('File Selection Cancelled', backgroundColor: errorRed);
      }
    } catch (e) {
      _showSnackBar('Error picking file', backgroundColor: errorRed);
    }
  }
  
Future<File> savefilepermanently(PlatformFile file) async{
  final appstorage = await getApplicationDocumentsDirectory();
  final newFile=File('${appstorage.path}/${file.name}');

  return File(file.path!).copy(newFile.path);
}


  void _checkIfFieldsAreFilled() {
    setState(() {
      _isButtonEnabled = _copiesController.text.isNotEmpty ||
          _instructionsController.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();

    _copiesController.addListener(_checkIfFieldsAreFilled);
    _instructionsController.addListener(_checkIfFieldsAreFilled);
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: backgroundColor ?? accentBlue,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      ),
    );
  }

  @override
  void _nextPage() {
    if (_currentPage < 1) {
      setState(() {
        _currentPage++;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void _prevPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
    }
  }

  void _navigateToLocationPage(BuildContext context) async {
    final coordinates = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapScreen(),
      ),
    );

    if (coordinates != null) {
      _updateLocation(coordinates);
    }
  }

  void _updateLocation(String coordinates) {
    setState(() {
      _isLocationSet = true;
      _locationCoordinates = coordinates;
    });
  }

  @override
  void _clearAllFields() {
    _copiesController.clear();
    _instructionsController.clear();
    setState(() {
      _selectedPrintService = null;
      _selectedColorOption = null;
      _selectedFiles?.clear();
    });
    _showSnackBar('All selections cleared!', backgroundColor: errorRed);
  }

  @override
  void _validateAndProceed() {
    if (_selectedFiles == null || _selectedFiles.isEmpty) {
      _showSnackBar('Please select files to print', backgroundColor: errorRed);
      return;
    }

    if (_copiesController.text.isEmpty) {
      _showSnackBar('Please enter number of copies', backgroundColor: errorRed);
      return;
    }

    if (_selectedPrintService == null) {
      _showSnackBar('Please select a printing service',
          backgroundColor: errorRed);
      return;
    }
  }

  @override
  void dispose() {
    _copiesController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _addToCart() {
    if (_copiesController.text.isEmpty ||
        _instructionsController.text.isEmpty ||
        _selectedPrintService == null ||
        _selectedColorOption == null ||
        (_selectedFiles?.isEmpty ?? true)) {
      _showSnackBar('Please complete all fields before adding to cart.',
          backgroundColor: errorRed);
      return;
    }

    final cartItem = {
      'copies': _copiesController.text,
      'instructions': _instructionsController.text,
      'printService': _selectedPrintService!,
      'colorOption': _selectedColorOption!,
      'files': _selectedFiles?.map((file) => file.name).toList() ?? [],
    };

    setState(() {
      _cartItems.add(cartItem);
    });

    _showSnackBar('Item added to cart!', backgroundColor: successGreen);
    _clearAllFields();
  }

  void _showCartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cart Items"),
          content: _cartItems.isNotEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _cartItems.map((item) {
                    final files = item['files'] as List<String>;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Copies: ${item['copies']}"),
                        Text("Instructions: ${item['instructions']}"),
                        Text("Print Service: ${item['printService']}"),
                        Text("Color Option: ${item['colorOption']}"),
                        Text("Files: ${files.join(", ")}"),
                        const Divider(),
                      ],
                    );
                  }).toList(),
                )
              : const Text("Your cart is empty."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _checkout() {
    setState(() {
      _cartItems.clear();
    });
    Navigator.pop(context);
    _showSnackBar('Checkout successful!', backgroundColor: successGreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        actions: [
          if (true)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartPage(
                      cartItems: _cartItems
                          .map((item) => item.cast<String, Object>())
                          .toList(),
                      onDelete: (index) {
                        setState(() {
                          _cartItems.removeAt(index);
                        });

                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CartPage(
                              cartItems: List<Map<String, Object>>.from(_cartItems), // Ensure type safety
                              onDelete: (index) {
                                setState(() {
                                  _cartItems.removeAt(index); // Update parent's cart list
                                });
                              },
                              onCheckout: () {
                                _checkout();
                              },
                            ),
                          ),
                        );
                      },
                      onCheckout: () {
                        _checkout();
                      },
                    ),
                  ),
                );
              },
              onLongPress: () {
                _showCartDialog();
              },
              child: IconButton(
  icon: const Icon(Icons.shopping_cart),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(
          cartItems: _cartItems.map((item) => item.cast<String, Object>()).toList(),
          onDelete: (index) {
            setState(() {
              _cartItems.removeAt(index); // Update parent cart items
            });
          },
          onCheckout: () {
            _checkout();
          },
        ),
      ),
    );
  },
),

            )
        ],
      ),
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundWhite,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: successGreen,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
            child: GNav(
              gap: 8,
              activeColor: Colors.white,
              color: Colors.white,
              tabBorderRadius: 65,
              tabBackgroundColor: const Color.fromRGBO(111, 221, 116, 0.548),
              padding: const EdgeInsets.all(16),
              tabs: const [
                GButton(icon: Icons.print, text: "Print"),
                GButton(icon: Icons.delivery_dining_outlined, text: "Track"),
                GButton(icon: Icons.history, text: "History"),
                GButton(icon: Icons.settings, text: "Settings"),
              ],
              onTabChange: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
            ),
          ),
        ),
      ),
      body: _selectedTabIndex == 1
          ? const Center(
              child: SizedBox(
                height: 500,
                width: 400,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: StrokeText(
                      text: "Tracking Feature yet to release soon",
                      textStyle: TextStyle(fontSize: 18),
                      strokeColor: Colors.white,
                      strokeWidth: 1,
                    ),
                  ),
                ),
              ),
            )
          : PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Center(
                  child: Container(
                    height: 650,
                    width: 400,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 90.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.redAccent,
                                ),
                                Expanded(
                                  child: Text(
                                    _isLocationSet
                                        ? (_locationCoordinates != null &&
                                                !_locationCoordinates!
                                                    .contains(','))
                                            ? _locationCoordinates!
                                            : "Current Location"
                                        : "Select Location",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _isLocationSet
                                          ? Colors.green
                                          : Colors.blueGrey.withOpacity(0.7),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    PermissionStatus location =
                                        await Permission.location.request();
                                    if (location == PermissionStatus.granted) {
                                      _navigateToLocationPage(context);
                                    }
                                    if (location == PermissionStatus.denied) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text("This Permission is Recommended")));
                                    }
                                    if (location ==
                                        PermissionStatus.permanentlyDenied) {
                                      openAppSettings();
                                    }
                                  },
                                  child: Text(
                                    _isLocationSet ? "Change" : "Set",
                                    style: const TextStyle(
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextField(
                            controller: _copiesController,
                            decoration: InputDecoration(
                              labelText: 'Number of Copies',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.blueAccent, width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon:
                                  const Icon(Icons.copy, color: Colors.blue),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Select Print Service:',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.grey,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedPrintService,
                              hint: const Text('Choose a Service'),
                              icon: const Icon(Icons.arrow_drop_down),
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: _printServices.map((String service) {
                                final parts = service.split('\t\t');
                                final serviceName = parts[0];
                                final servicePrice =
                                    parts.length > 1 ? parts[1] : '';

                                return DropdownMenuItem<String>(
                                  value: service,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(serviceName),
                                      Text(
                                        servicePrice,
                                        style: TextStyle(
                                          color:
                                              Colors.blueGrey.withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedPrintService = newValue;
                                });
                              },
                            ),
                          ),
                          if (_selectedPrintService != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                value: _selectedColorOption,
                                hint: const Text('Choose an Option'),
                                icon: const Icon(Icons.arrow_drop_down),
                                isExpanded: true,
                                underline: const SizedBox(),
                                items:
                                    _printcolorselection.map((String option) {
                                  return DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(option),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedColorOption = newValue;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                'Selected Service and Color: $_selectedPrintService , $_selectedColorOption ',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.blueAccent),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          TextField(
                            controller: _instructionsController,
                            decoration: InputDecoration(
                              labelText: 'Instructions for Printing',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.blueAccent, width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon:
                                  const Icon(Icons.print, color: Colors.blue),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _pickFiles,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              _selectedFiles!.isNotEmpty
                                  ? '${_selectedFiles.length} Files Selected , Total Size: ${_getTotalFileSize()} MB'
                                  : 'Select Files to Upload',
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _addToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              'Add to Cart',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed:
                                _isButtonEnabled ? _clearAllFields : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isButtonEnabled ? errorRed : Colors.grey,
                              foregroundColor: Colors.white.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    height: 500,
                    width: 400,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Page 2 - No Contents',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _prevPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Previous'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
