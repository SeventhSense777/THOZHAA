import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/model/place_details.dart';

class NearbyPoliceStationsScreen extends StatefulWidget {
  @override
  _NearbyPoliceStationsScreenState createState() => _NearbyPoliceStationsScreenState();
}

class _NearbyPoliceStationsScreenState extends State<NearbyPoliceStationsScreen> {
  GoogleMapController? _mapController;
  List<Marker> _markers = [];
  late Position _currentPosition;
  final String _googleMapsApiKey = 'AIzaSyCCmoyeW1MY7lZktmPJFosgIEquZd1qoyM';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _fetchNearbyPoliceStations(_currentPosition);
  }

  void _fetchNearbyPoliceStations(Position position) async {
    final places = GooglePlaces(_googleMapsApiKey);
    final response = await places.searchNearbyWithRadius(
      Location(lat: position.latitude, lng: position.longitude),
      5000,  // Search within 5 km radius
      type: 'police',
    );

    setState(() {
      _markers = response.results.map((result) {
        return Marker(
          markerId: MarkerId(result.placeId),
          position: LatLng(result.geometry.location.lat, result.geometry.location.lng),
          infoWindow: InfoWindow(title: result.name),
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Police Stations'),
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
          zoom: 14,
        ),
        markers: Set<Marker>.of(_markers),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
    );
  }
}
