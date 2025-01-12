import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'animatedprogressbar.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:printee/pages/cartPage.dart';
import 'package:stroke_text/stroke_text.dart';
import 'package:printee/pages/setLocation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'profile.dart';
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
  final Map<String, LinearGradient> _colorOptionGradients = {
    'Color': const LinearGradient(
      colors: [
        Colors.blue,
        Colors.purple,
        Colors.pink,
        Colors.orange,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'Black & White': LinearGradient(
      colors: [
        Colors.black87,
        Colors.grey.shade600,
        Colors.grey.shade400,
        Colors.grey.shade200,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  };

  final TextEditingController _copiesController = TextEditingController();
  final PageController _pageController = PageController();
  final List<Map<String, Object?>> _cartItems = [];
  int _currentPage = 0;
  int _selectedTabIndex = 0;
  bool _showcoloroption = true;
  bool _isLocationSet = false;
  String? _locationCoordinates;
  bool _isButtonEnabled = false;
  final TextEditingController _instructionsController = TextEditingController();

  final List<String> _printServices = [
    'Single-sided Printing\t\t2rs/page',
    'Double-sided Printing\t\t2rs/page',
    'Calico-type Printing\t\t2rs/page',
    'Spiral-type Printing\t\t2rs/page',
    'Bond Sheet Printing\t\t10rs/page',
  ];
  final List<String> _printcolorselection = [
    'Color',
    'Black and White',
  ];
  final List<Color> _serviceColors = [
    Colors.lightBlue.shade100,
    Colors.pink.shade100,
    Colors.green.shade100,
    Colors.amber.shade100,
    Colors.purple.shade100,
    Colors.teal.shade100,
    Colors.orange.shade100,
    Colors.indigo.shade100,
  ];

  final List<String> _printServiceIcons = [
    'assets/icons/singlesheet.png', // Icon for Service 1
    'assets/icons/doublesheet.png', // Icon for Service 2
    'assets/icons/calico.png', // Icon for Service 3
    'assets/icons/spiral.png', // Icon for Service 4
    'assets/icons/bondsheet.png', // Icon for Service 5
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
        setState(() {
          _selectedFiles.add(file);
        });
        print("From path${file.path!}");
        print("To path${newfail.path}");
      } else {
        _showSnackBar('File Selection Cancelled', backgroundColor: errorRed);
      }
    } catch (e) {
      _showSnackBar('Error picking file', backgroundColor: errorRed);
    }
  }

  Future<File> savefilepermanently(PlatformFile file) async {
    final appstorage = await getApplicationDocumentsDirectory();
    final newFile = File('${appstorage.path}/${file.name}');

    return File(file.path!).copy(newFile.path);
  }

  void _checkIfFieldsAreFilled() {
    print("Copies: ${_copiesController.text.isNotEmpty}");
    print("Instructions: ${_instructionsController.text.isNotEmpty}");
    print("Service selected: ${_selectedPrintService != null}");
    setState(() {
      _isButtonEnabled = (_copiesController.text.isNotEmpty ||
              _instructionsController.text.isNotEmpty) ||
          _selectedPrintService != null;
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
        content: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Display message and button if the message is "Item added to cart!"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    message.toUpperCase(), // Make text uppercase

                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          16, // Optional: increase font size for better readability
                    ),
                  ),
                ),
                if (message == "Item added to cart!")
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      // Navigate to the CartPage
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
                            },
                            onCheckout: () async {
                              _checkout();
                              return null;
                            },
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 106, 175, 231), // Button background color
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16), // Adjust padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            8), // Rounded corners for button
                      ),
                    ),
                    child: const Text(
                      "VIEW CART",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold, // Make text bold
                        fontSize: 14, // Optional: Adjust text size for button
                      ),
                    ),
                  ),
              ],
            ),
            // Animated progress bar at the bottom
            const Positioned(
              bottom: -6, // Adjust position to align at the bottom
              left: 0,
              right: 0,
              child: AnimatedProgressBar(duration: Duration(seconds: 3)),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? Colors.blue,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rectangular Snackbar
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
      _showcoloroption = true;
      _selectedFiles.clear();
    });
  }

  @override
  void _validateAndProceed() {
    if (_selectedFiles.isEmpty) {
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
    if (!_isLocationSet) {
      _showSnackBar('Set Your Location');
      return;
    }
    if (_copiesController.text.isEmpty ||
        _selectedPrintService == null ||
        _selectedColorOption == null ||
        _isLocationSet == false ||
        (_selectedFiles.isEmpty ?? true)) {
      _showSnackBar('complete all fields', backgroundColor: errorRed);
      return;
    }

    final cartItem = {
      'copies': _copiesController.text,
      'instructions': _instructionsController.text,
      'printService': _selectedPrintService!,
      'colorOption': _selectedColorOption!,
      'files': _selectedFiles.map((file) => file.name).toList() ?? [],
    };

    setState(() {
      _cartItems.add(cartItem);
    });

    _showSnackBar('Item added to cart!', backgroundColor: Colors.blue);
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
        backgroundColor: Colors.white,
        elevation: 0,
        title: GestureDetector(
          onTap: () async {
            PermissionStatus location = await Permission.location.request();
            if (location == PermissionStatus.granted) {
              _navigateToLocationPage(context);
            }
            if (location == PermissionStatus.denied) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("This Permission is Recommended")),
              );
            }
            if (location == PermissionStatus.permanentlyDenied) {
              openAppSettings();
            }
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _isLocationSet
                      ? Icons.location_on
                      : Icons.help_outline, // Change icon based on condition
                  color: _isLocationSet
                      ? Colors.blue
                      : Colors.grey, // Blue for location set, grey otherwise
                  size: 20, // Slightly larger size
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Location',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isLocationSet
                          ? (_locationCoordinates != null &&
                                  !_locationCoordinates!.contains(','))
                              ? _locationCoordinates!
                              : "Current Location"
                          : "Choose Delivery Location",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _isLocationSet
                            ? Colors.blue // Current location in blue color
                            : Colors.red, // Default color for "Select Location"
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Cart Icon
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
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
                          },
                          onCheckout: () async {
                            _checkout();
                            return null;
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shopping_cart,
                      color: Colors.blue,
                      size: 23, // Larger icon for better touch target
                    ),
                  ),
                ),
                if (_cartItems.isNotEmpty)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _cartItems.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Profile Icon
          const SizedBox(width: 6), // Gap between the icons
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.blue,
                  size: 23, // Larger icon for better touch target
                ),
              ),
            ),
          ),
          const SizedBox(width: 12), // Gap between the icons
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
    color: Colors.white, // White background for the bottom bar
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Border on top like a rectangular line
        Container(
          height: 2, 
          color: Colors.grey.shade300, // Light gray border color
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: GNav(
            gap: 8,
            activeColor: Colors.blue, // Blue color for selected tab
            color: Colors.grey, // Gray color for unselected tabs
            iconSize: 30, // Larger icons for better touch
            tabBorderRadius: 50, // Rounded corners for each tab
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 300), // Smooth transition for active tab
            tabs: [
              GButton(
                icon: Icons.home,
                text: "Home",
                iconColor: Colors.grey, // Gray for unselected icons
                textColor: Colors.grey, // Gray for unselected text
iconActiveColor: Colors.blue, // Blue for selected icon
  textStyle: TextStyle(
    color: Colors.blue, 
    fontWeight: FontWeight.bold,  // Making text bold
    fontFamily: 'RobotoSlab',  // Using the custom font
  ), // Blue text fo
                onPressed: () {
                  // Animation or transition here when tapped
                },
              ),
              GButton(
                icon: Icons.delivery_dining,
                text: "Track",
                iconColor: Colors.grey, // Gray for unselected icons
                textColor: Colors.grey, // Gray for unselected text
                iconActiveColor: Colors.blue, // Blue for selected icon
                
  textStyle: TextStyle(
    color: Colors.blue, 
    fontWeight: FontWeight.bold,  // Making text bold
    fontFamily: 'RobotoSlab',  // Using the custom font
  ), // Blue text fo// Blue text for selected item
                onPressed: () {
                  // Animation or transition here when tapped
                },
              ),
              GButton(
  icon: Icons.history,
  text: "History",
  iconColor: Colors.grey, // Gray for unselected icons
  textColor: Colors.grey, // Gray for unselected text
  iconActiveColor: Colors.blue, // Blue for selected icon
  textStyle: TextStyle(
    color: Colors.blue, 
    fontWeight: FontWeight.bold,  // Making text bold
    fontFamily: 'RobotoSlab',  // Using the custom font
  ), // Blue text for selected item
  onPressed: () {
    // Animation or transition here when tapped
  },
),

              GButton(
                icon: Icons.settings,
                text: "Settings",
                iconColor: Colors.grey, // Gray for unselected icons
                textColor: Colors.grey, // Gray for unselected text
              iconActiveColor: Colors.blue, // Blue for selected icon
  textStyle: TextStyle(
    color: Colors.blue, 
    fontWeight: FontWeight.bold,  // Making text bold
    fontFamily: 'RobotoSlab',  // Using the custom font
  ), // Blue text fo
                onPressed: () {
                  // Animation or transition here when tapped
                },
              ),
            ],
            onTabChange: (index) {
              setState(() {
                _selectedTabIndex = index;
              });
            },
          ),
        ),
      ],
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
                    width: 600,
                    padding: const EdgeInsets.all(7.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Print Service Selection
                          Text(
                            'Select Print Type',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Horizontal Scrollable Service Grid
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _printServices.length,
                              itemBuilder: (context, index) {
                                final service = _printServices[index];
                                final parts = service.split('\t\t');
                                final serviceName = parts[0];
                                final servicePrice =
                                    parts.length > 1 ? parts[1] : '';
                                final isSelected =
                                    _selectedPrintService == service;

                                // Get the icon path for this service
                                final iconPath = _printServiceIcons[index];

                                // Cycle through the colors using the index
                                final backgroundColor = isSelected
                                    ? Colors.blue.shade700
                                    : _serviceColors[
                                        index % _serviceColors.length];
                                final textColor = isSelected
                                    ? Colors.white
                                    : Colors.grey.shade800;

                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedPrintService = service;
                                        _selectedColorOption =
                                            null; // Reset color option when service changes
                                        _showcoloroption = true;
                                      });
                                      _checkIfFieldsAreFilled();
                                    },
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          width: 110,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: backgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.blue
                                                  : Colors.grey.shade200,
                                              width: isSelected ? 2 : 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.1),
                                                spreadRadius: 0,
                                                blurRadius: 10,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                iconPath, // Use the custom icon
                                                height: 28,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.grey.shade600,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                serviceName,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: textColor,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                servicePrice,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          Positioned(
                                            top: -4,
                                            right: -4,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size:
                                                    18, // Small size for the tick mark
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Color Option Selection (shows only when service is selected)
                          if (_selectedPrintService != null) ...[
                            const SizedBox(height: 14),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeOutExpo,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                                opacity: _showcoloroption ? 1.0 : 0.0,
                                child: Container(
                                  height: _showcoloroption ? null : 0,
                                  padding: _showcoloroption
                                      ? const EdgeInsets.all(16)
                                      : EdgeInsets.zero,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey.shade200),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.05),
                                        spreadRadius: 0,
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),
                                      Row(
                                        children:
                                            _printcolorselection.map((option) {
                                          final isSelected =
                                              _selectedColorOption == option;
                                          final isColor =
                                              option.toLowerCase() == 'color';

                                          return Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedColorOption = option;
                                                  _showcoloroption = false;
                                                });
                                              },
                                              child: Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4),
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  gradient: isSelected
                                                      ? _colorOptionGradients[
                                                          option]
                                                      : null,
                                                  color: isSelected
                                                      ? null
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? Colors.transparent
                                                        : Colors.grey.shade300,
                                                    width: isSelected ? 2 : 1,
                                                  ),
                                                  boxShadow: isSelected
                                                      ? [
                                                          BoxShadow(
                                                            color: (isColor
                                                                    ? Colors
                                                                        .blue
                                                                    : const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        0,
                                                                        0,
                                                                        0))
                                                                .withOpacity(
                                                                    0.8),
                                                            spreadRadius: 0,
                                                            blurRadius: 0,
                                                            offset:
                                                                const Offset(
                                                                    0, 2),
                                                          ),
                                                        ]
                                                      : null,
                                                ),
                                                child: Column(
                                                  children: [
                                                    Icon(
                                                      isColor
                                                          ? Icons.palette
                                                          : Icons.gradient,
                                                      color: isSelected
                                                          ? Colors.white
                                                          : Colors
                                                              .grey.shade600,
                                                      size: 24,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      option,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isSelected
                                                            ? Colors.white
                                                            : Colors
                                                                .grey.shade700,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    if (isSelected) ...[
                                                      const SizedBox(height: 4),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 8,
                                                          vertical: 2,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white
                                                              .withOpacity(0.3),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child: const Text(
                                                          'Selected',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],

                          if (_selectedPrintService != null &&
                              _selectedColorOption != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      gradient: _selectedColorOption != null &&
                                              _colorOptionGradients.containsKey(
                                                  _selectedColorOption)
                                          ? _colorOptionGradients[
                                              _selectedColorOption]
                                          : LinearGradient(
                                              colors: [
                                                Colors.grey.shade400,
                                                Colors.grey.shade600
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),

                                  const SizedBox(width: 8),
                                  Text(
                                    '${_selectedPrintService!.split('\t\t')[0]} • $_selectedColorOption',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  // Cross IconButton to clear the selected color option
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedColorOption =
                                            null; // Clear the color selection
                                        _selectedPrintService = null;
                                        _showcoloroption = true;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    padding: const EdgeInsets.only(
                                      right: 1, // Adjust padding dynamically
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

// Number of Copies Input
                          TextField(
                            controller: _copiesController,
                            decoration: InputDecoration(
                              labelText: 'Number of Copies',
                              labelStyle: TextStyle(
                                color: Colors.blueGrey.shade800,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: Colors.blueGrey.shade200, width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: Colors.blueGrey.shade200, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: Colors.blue.shade400, width: 1.5),
                              ),
                              prefixIcon: Container(
                                padding: const EdgeInsets.all(
                                    8), // Reduced padding for smaller icon

                                child: Icon(Icons.copy,
                                    color: Colors.blue.shade600,
                                    size: 20), // Smaller icon
                              ),
                              filled: true,
                              fillColor: Colors
                                  .blue.shade50, // Custom background color
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              hintText: 'Enter number of copies',
                              hintStyle:
                                  TextStyle(color: Colors.blueGrey.shade300),
                            ),
                            keyboardType: TextInputType.number,
                          ),

                          const SizedBox(height: 20),

// Instructions TextField
                          TextField(
                            controller: _instructionsController,
                            maxLines: 3,
                            textInputAction: TextInputAction
                                .done, // This replaces the Enter key with Done (tick)
                            decoration: InputDecoration(
                              labelText: 'Special Instructions',
                              labelStyle: TextStyle(
                                color: Colors.blueGrey.shade800,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: Colors.purple.shade200, width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: Colors.purple.shade200, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: Colors.purple.shade400, width: 1.5),
                              ),
                              prefixIcon: Container(
                                padding: const EdgeInsets.all(
                                    8), // Reduced padding for smaller icon
                                child: Icon(Icons.description_outlined,
                                    color: Colors.purple.shade600,
                                    size: 20), // Smaller icon
                              ),
                              filled: true,
                              fillColor: Colors
                                  .purple.shade50, // Custom background color
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              hintText: 'Any Special Instruction...',
                              hintStyle:
                                  TextStyle(color: Colors.purple.shade300),
                            ),
                          ),

                          const SizedBox(height: 24),

// File Selection Button with Clear Icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _pickFiles,
                                  icon: const Icon(Icons.attach_file, size: 20),
                                  label: Text(
                                    _selectedFiles.isNotEmpty
                                        ? '${_selectedFiles.length} Files • ${_getTotalFileSize()} MB'
                                        : 'Select Files',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade50,
                                    foregroundColor: Colors.blue.shade700,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                              if (_selectedFiles.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedFiles
                                            .clear(); // Clear the selected files
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.grey,
                                      size: 24,
                                    ),
                                    padding: EdgeInsets
                                        .zero, // Optional: to remove default padding
                                    constraints:
                                        const BoxConstraints(), // Optional: to remove extra spacing
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      _isButtonEnabled ? _clearAllFields : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade50,
                                    foregroundColor: Colors.red.shade700,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Clear All',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: _addToCart,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Add to Cart',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
