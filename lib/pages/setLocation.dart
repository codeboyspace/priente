import 'package:flutter/material.dart';
import 'package:mappls_gl/mappls_gl.dart';
import 'package:flutter/services.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Set Location',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapplsMapController? mapController;
  TextEditingController searchController = TextEditingController();
  LatLng currentLocation = const LatLng(11.0168, 76.9558); 
  List<String> placeSuggestions = []; 

  @override
  void initState() {
    super.initState();
    
    MapplsAccountManager.setMapSDKKey('ad737f26494439db4f769562326d583c');
    MapplsAccountManager.setRestAPIKey('ad737f26494439db4f769562326d583c');
    MapplsAccountManager.setAtlasClientId('96dHZVzsAut6fjmykVVwpAg3QVeeHEaVpqan1AvjZK_icv0Uui2Pu0pHbGwYdX1VG7Po0rfAWJ6HaSiMJWRLUg==');
    MapplsAccountManager.setAtlasClientSecret('lrFxI-iSEg8r1-6L8rUeZF9U6gPOVw-RgHeQNVKMXwvCDrLBbCXg0CjLPfJz2fG4VDR7oj5QXeqcy5-vGLHWQOtivTSUGJlr');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapplsMap(
            initialCameraPosition: CameraPosition(
              target: currentLocation,
              
              zoom: 14.0,
            ),
            myLocationEnabled: true,
            myLocationTrackingMode: MyLocationTrackingMode.tracking,
            onUserLocationUpdated: (location){
              mapController?.animateCamera(CameraUpdate.newLatLng(currentLocation));
              print("On user location updated: ${location.position.toJson()}");
              _updateMarker(location.position);
            },
          ),
          
          MapplsMap(
            initialCameraPosition: CameraPosition(
              target: currentLocation,
              zoom: 14.0,
            ),
            onMapCreated: (MapplsMapController map) {
              mapController = map;
            },
            onStyleLoadedCallback: _onMapStyleLoaded,
          ),
          
          
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(8),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search location',
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blueAccent, width: 3),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: _onSearchTextChanged,
              ),
            ),
          ),

          
          if (placeSuggestions.isNotEmpty)
            Positioned(
              top: 100,
              left: 16,
              right: 16,
              child: Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: placeSuggestions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(placeSuggestions[index]),
                        onTap: () {
                          _confirmPlace(placeSuggestions[index]);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),

          
          Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButton(
              onPressed: _getUserLocation,
              backgroundColor: Colors.blue, 
              child: Icon(
                Icons.my_location,
                color: Colors.white.withOpacity(0.8), 
              ),
              elevation: 5, 
              shape: RoundedRectangleBorder( 
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _confirmLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Confirm Location', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
callGeocode() async {
  try {
    // Add the podFilter parameter for filtering results by city
    GeocodeResponse? response = await MapplsGeoCoding(
      address: "Saket, New Delhi, Delhi, 110017",
      podFilter: "city", // Specify the filter type; adjust as needed
    ).callGeocoding();

    // Check if the response contains valid results
    if (response != null && response.results != null && response.results!.isNotEmpty) {
      var result = response.results!.first;

      // Extract latitude and longitude
      double latitude = result.latitude!;
      double longitude = result.longitude!;

      // Print formatted address and coordinates
      print("Formatted Address: ${result.formattedAddress}");
      print("Latitude: $latitude");
      print("Longitude: $longitude");

      // Create LatLng object for further use
      print(LatLng(latitude, longitude));
    } else {
      // Handle the case when no valid results are found
      print("No valid results found for the address: Saket, New Delhi, Delhi, 110017");
    }
  } catch (e) {
    // Handle platform-specific exceptions
    if (e is PlatformException) {
      print('Error: ${e.code} - ${e.message}');
    } else {
      // Handle unexpected errors
      print("An unexpected error occurred: $e");
    }
  }
}

 Future<LatLng?> _getLatLngFromPlace(String placeName) async {
  try {
    
    GeocodeResponse? response = await MapplsGeoCoding(address: placeName).callGeocoding();

    if (response != null && response.results != null && response.results!.isNotEmpty) {
      
      LatLng location = LatLng(
        response.results!.first.latitude!,
        response.results!.first.longitude!,
      );

      print("Geocoding successful: $placeName -> (${location.latitude}, ${location.longitude})");
      return location;
    } else {
      print("No results found for: $placeName");
    }
  } catch (e) {
    if (e is PlatformException) {
      print("${e.code} --- ${e.message}");
    } else {
      print("Error fetching geocoding data: $e");
    }
  }
  return null;
}




  void _updateMarker(LatLng newPosition) async {
    if (mapController != null) {
      setState(() {
        currentLocation = newPosition;
      });

      
      await mapController!.clearSymbols();

      
      await mapController!.addSymbol(SymbolOptions(
        geometry: newPosition,
      ));

      print("Marker updated to: $newPosition");
    }
  }
  
  void _onMapStyleLoaded() async {
    callGeocode();
    if (mapController != null) {
      try {
        
        await mapController!.addSymbol(SymbolOptions(
          geometry: currentLocation,
        ));
        print("Marker added successfully.");
      } catch (e) {
        print("Error adding marker: $e");
      }
    } else {
      print("Map controller is null.");
    }
  }

  

void _onSearchTextChanged(String query) async {
  try {
    
    AutoSuggestResponse? response = await MapplsAutoSuggest(query: query).callAutoSuggest();
    
    if (response?.suggestedLocations != null) {
      setState(() {
        
        placeSuggestions = response!.suggestedLocations!
            .map((location) => location.placeName ?? 'Unknown Location')
            .toList();
      });
    } else {
      setState(() {
        placeSuggestions = [];
      });
    }
  } catch (e) {
    print("Error during autosuggest: $e");
    setState(() {
      placeSuggestions = [];
    });
  }
}


  
  void _getUserLocation() async {
    
    mapController?.animateCamera(CameraUpdate.newLatLng(currentLocation));

  }

  
void _confirmLocation() {
  // Convert coordinates to a string
  final coordinates = "${currentLocation.latitude},${currentLocation.longitude}";
  
  print("Location confirmed: $coordinates");
  
  // Navigate back to the previous page and pass the coordinates as a string
  Navigator.pop(context, coordinates);
}

void _confirmPlace(String Place) {
  // Convert coordinates to a string
  
  print("Location confirmed: $Place");
  
  // Navigate back to the previous page and pass the coordinates as a string
  Navigator.pop(context, Place);
}

}