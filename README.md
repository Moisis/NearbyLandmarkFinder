# Nearby LandMark Tracker App

A project about using  Shared Prefs and Geolocator .


## Features

1.	Permission Handling: Check and request permissions for location access using the permission_handler package. 
2.	Fetch Current Location: Use GPS to retrieve the user's current latitude and longitude and display them in the app. 
3.	Geocoding: Convert the retrieved coordinates into a human-readable address (e.g., city, street) and display it in the app. 
4.	Persist Data: Save the user's current location and address as a favorite locally using SharedPreferences, ensuring the saved data is retained after restarting the app. 
5.	Display Saved Locations: Show a list of all saved locations on a separate screen.


## Packages Used 

    permission_handler: ^11.3.1
    geolocator: ^13.0.2
    shared_preferences: ^2.3.3
    geocoding: ^3.0.0