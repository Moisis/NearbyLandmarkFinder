import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandmarkFinder extends StatefulWidget {
  @override
  _LandmarkFinderState createState() => _LandmarkFinderState();
}

class _LandmarkFinderState extends State<LandmarkFinder> {
  String location = 'Unknown location';
  String status = 'Idle';
  Position? mypos;
  double? latitude;
  double? longitude;

  int _selectedIndex = 0;

  List<Placemark> _landmarks = [];
  Set<String> _savedLocations = {};

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
    _loadSavedLocations();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/screen2');
        break;
    }
  }

  Future<void> _loadSavedLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLocation = prefs.getString('lastLocation');
    if (savedLocation != null) {
      setState(() {
        location = savedLocation;
      });
    }
  }

  Future<void> _loadSavedLocations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> locations = prefs.getStringList('locations') ?? [];
    setState(() {
      _savedLocations = locations.toSet();
    });
  }

  Future<void> _saveLocation(String location) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastLocation', location);
  }

  Future<void> addLocationToList(String address) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> locations = prefs.getStringList('locations') ?? [];

    // Add the address if it's not already there
    if (!locations.contains(address)) {
      locations.add(address);
      prefs.setStringList('locations', locations);
      setState(() {
        _savedLocations.add(address);
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Landmark saved successfully!'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future<void> removeLocationFromList(String address) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> locations = prefs.getStringList('locations') ?? [];

    // Remove the address if it exists
    if (locations.contains(address)) {
      locations.remove(address);
      prefs.setStringList('locations', locations);
      setState(() {
        _savedLocations.remove(address);
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Landmark deleted successfully!'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future<void> getaddress(double latitude, double longitude) async {
    try {
      List<Placemark> addresses =
          await placemarkFromCoordinates(latitude, longitude);

      if (addresses.isNotEmpty) {
        Placemark myaddress = addresses[0];
        String fetchedLocation =
            '${myaddress.street}, ${myaddress.locality}, ${myaddress.administrativeArea}, ${myaddress.country}';

        setState(() {
          status = 'Address fetched';
          location = fetchedLocation;
          _landmarks = addresses.sublist(1);
        });
        _saveLocation(fetchedLocation);
      } else {
        setState(() {
          location = 'Address not found';
        });
      }
    } catch (e) {
      setState(() {
        location = 'Error fetching address: $e';
      });
    }
  }

  Future<void> getcurrentlocation() async {
    if (await _requestPermission(Permission.location)) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          mypos = position;
          latitude = position.latitude; // Set latitude
          longitude = position.longitude; // Set longitude
          status = 'Fetching address...';
          getaddress(position.latitude, position.longitude);
        });
      } catch (e) {
        setState(() {
          status = 'Error getting location: $e';
        });
      }
    } else {
      setState(() {
        status = 'Permission denied';
        return;
      });
    }
  }


  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      return result == PermissionStatus.granted;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Landmark Locator',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location Title
                      Center(
                        child: Text(
                          'Location: $location',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),

                      // Latitude and Longitude Display
                      if (latitude != null && longitude != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Lat: $latitude',
                                  style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Long: $longitude',
                                  style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],

                      // Status Information
                      Center(
                        child: Text(
                          'Status: $status',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),


            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getcurrentlocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Get Current Location',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _landmarks.isNotEmpty
                  ? ListView.builder(
                      itemCount: _landmarks.length,
                      itemBuilder: (context, index) {
                        final landmark = _landmarks[index];
                        final address =
                            '${landmark.street} , ${landmark.locality ?? ''}, ${landmark.administrativeArea ?? ''}, ${landmark.country ?? ''}';
                        final isSaved = _savedLocations.contains(address);

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${landmark.name}, ${landmark.street}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${landmark.locality ?? ''}, ${landmark.administrativeArea ?? ''}, ${landmark.country ?? ''}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    isSaved
                                        ? ElevatedButton(
                                            onPressed: () {
                                              removeLocationFromList(address);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: Icon(Icons.delete,
                                                color: Colors.white),
                                          )
                                        : ElevatedButton(
                                            onPressed: () {
                                              addLocationToList(address);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                            ),
                                            child: Icon(Icons.add,
                                                color: Colors.white),
                                          ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'No landmarks found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Fav',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
