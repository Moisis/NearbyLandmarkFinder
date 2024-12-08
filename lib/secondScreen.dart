import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  int _selectedIndex = 1;
  List<String> _landmarks = [];

  @override
  void initState() {
    super.initState();
    _loadSavedLandmarks();
  }


  Future<void> deleteLocation(String locationName) async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve the list of saved locations
    List<String> locations = prefs.getStringList('locations') ?? [];

    // Remove the specified location
    locations.remove(locationName);

    // Save the updated list back to SharedPreferences
    await prefs.setStringList('locations', locations);
  }

  Future<void> _loadSavedLandmarks() async {
    List<String> savedLandmarks = await getSavedLocations();
    setState(() {
      _landmarks = savedLandmarks;
    });
  }

  Future<List<String>> getSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('locations') ?? [];
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
        child: FutureBuilder<List<String>>(
          future: getSavedLocations(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            List<String> landmarks = snapshot.data ?? [];

            return landmarks.isNotEmpty
                ? ListView.builder(
              itemCount: landmarks.length,
              itemBuilder: (context, index) {
                final landmark = landmarks[index];
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
                          landmark,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                await deleteLocation(landmark);  // Call deleteLocation when delete icon is tapped
                                setState(() {});  // Refresh the UI after deletion
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            )

                : Center(
                    child: Text(
                      'No landmarks found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
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
