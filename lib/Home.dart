import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _mapStyle;
  Completer<GoogleMapController> _controller = Completer();

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(
      controller..setMapStyle(_mapStyle)
    );
  }

  _movimentarCamera() async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        cameraPosition,
      ),
    );
  }

  Set<Marker> _marcadores = {};
  Set<Polygon> _polygons = {};
  Set<Polyline> _polylines = {};

  _carregarMarcadores() {
    Set<Marker> marcadoresLocal = {};
    Marker marcadoMercearia = Marker(
        markerId: MarkerId("mercearia"),
        position: LatLng(-8.063256, -34.890201),
        infoWindow: InfoWindow(title: "Mercearia "),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        ),
        onTap: () {
          print("Mercearia");
        });
    Marker marcadoPortoSocial = Marker(
        markerId: MarkerId("porto_social"),
        position: LatLng(-8.063275, -34.891452),
        infoWindow: InfoWindow(title: "Porto Social "),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        ),
        rotation: 45,
        onTap: () {
          print("Porto");
        });
    marcadoresLocal.add(marcadoMercearia);
    marcadoresLocal.add(marcadoPortoSocial);
    //?----------------------------------
    //*----------------------------------
    // Set<Polygon> listPolygon = {};
    // Polygon polygon1 = Polygon(
    //   polygonId: PolygonId("polygon1"),
    //   fillColor: Colors.transparent,
    //   strokeColor: Colors.cyan,
    //   strokeWidth: 10,
    //   points: [
    //     LatLng(-8.062647, -34.892033),
    //     LatLng(-8.064175, -34.891982),
    //     LatLng(-8.064106, -34.889270),
    //     LatLng(-8.062533, -34.889226),
    //   ],
    //   onTap: (){
    //     print("Clicou na Área");
    //   },
    //   zIndex: 1,
    // );
    // Polygon polygon2 = Polygon(
    //   polygonId: PolygonId("polygon2"),
    //   fillColor: Colors.greenAccent,
    //   strokeColor: Colors.deepOrange,
    //   strokeWidth: 10,
    //   points: [
    //     LatLng(-8.061769, -34.890770),
    //     LatLng(-8.063910, -34.892422),
    //     LatLng(-8.063910, -34.889219),
    //   ],
    //   onTap: (){
    //     print("Clicou na Área");
    //   },
    //   zIndex: 0,
    // );
    // listPolygon.add(polygon1);
    // listPolygon.add(polygon2);
    Set<Polyline> listPolyline = {};
    Polyline polyline = Polyline(
      polylineId: PolylineId("polyline"),
      color: Colors.deepPurple,
      width: 10,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
      points: [
        LatLng(-8.063885, -34.890763),
        LatLng(-8.063196, -34.890087),
        LatLng(-8.062622, -34.890808),
      ],
    );
    listPolyline.add(polyline);

    setState(() {
      _marcadores = marcadoresLocal;
      _polylines = listPolyline;
    });
  }

  //*----------------------------------------
  //?----------------------------------------
  CameraPosition cameraPosition = CameraPosition(
    target: LatLng(-8.008288, -34.873813),
    zoom: 17,
  );

  _recuperarLocalizacao() async {
    Position position = await Geolocator().getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      cameraPosition = CameraPosition(
        target: LatLng(
          position.latitude,
          position.longitude,
        ),
        zoom: 17,
      );
    });
    _movimentarCamera();
  }

  _adicionarListenerLocalizacao() {
    final geolocator = Geolocator();
    final locationOptions = LocationOptions(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    geolocator.getPositionStream(locationOptions).listen((Position position) {
      Marker markerNowLocation = Marker(
        markerId: MarkerId("Now Local"),
        position: LatLng(
          position.latitude,
          position.longitude,
        ),
        infoWindow: InfoWindow(title: "Meu Local "),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        ),
      );
      setState(() {
        _marcadores.add(markerNowLocation);
        cameraPosition = CameraPosition(
          target: LatLng(
            position.latitude,
            position.longitude,
          ),
          zoom: 17,
        );
      });
      _movimentarCamera();
    });
  }

  _recuperarLocalParaEndereco() async {

    List<Placemark> listEndereco = await  Geolocator()
      .placemarkFromAddress("R. Jornalista Guerra de Holanada, PE - Olinda, 675");
    
    if(listEndereco.length > 0){
      print("LIST = ${listEndereco.length} \n");
      Placemark endereco = listEndereco[0];
      String resultado;
      resultado = " -------------------------- \n";
      resultado += "\n administrativeArea: " + endereco.administrativeArea;
      resultado += "\n subAdministrativeArea: " + endereco.subAdministrativeArea;
      resultado += "\n locality: " + endereco.locality;
      resultado += "\n subLocality: " + endereco.subLocality;
      resultado += "\n thoroughfar: " + endereco.thoroughfare;
      resultado += "\n subThoroughfar: " + endereco.subThoroughfare;
      resultado += "\n postalCod: " + endereco.postalCode;
      resultado += "\n country: " + endereco.country;
      resultado += "\n isoCountryCode: " + endereco.isoCountryCode;
      resultado += "\n position: " + endereco.position.toString();
      print(resultado);
    }
    else{
      print("Local não encontrado!");
    }
  }

  _recuperarLocalParaLatLong() async {
    List<Placemark> listEndereco = await Geolocator()
      .placemarkFromCoordinates(-8.005017, -34.871946);
    
    if(listEndereco.length > 0){
      print("LIST = ${listEndereco.length} \n");
      Placemark endereco = listEndereco[0];
      String resultado;
      resultado = " -------------------------- \n";
      resultado += "\n administrativeArea: " + endereco.administrativeArea;
      resultado += "\n subAdministrativeArea: " + endereco.subAdministrativeArea;
      resultado += "\n locality: " + endereco.locality;
      resultado += "\n subLocality: " + endereco.subLocality;
      resultado += "\n thoroughfar: " + endereco.thoroughfare;
      resultado += "\n subThoroughfar: " + endereco.subThoroughfare;
      resultado += "\n postalCod: " + endereco.postalCode;
      resultado += "\n country: " + endereco.country;
      resultado += "\n isoCountryCode: " + endereco.isoCountryCode;
      resultado += "\n position: " + endereco.position.toString();
      print(resultado);
    }
    else{
      print("Local não encontrado!");
    }
  }

  @override
  void initState() {
    super.initState();
    //_carregarMarcadores();
    //_recuperarLocalizacao();
    // _adicionarListenerLocalizacao();
    // _recuperarLocalParaEndereco();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    _recuperarLocalParaLatLong();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mapas e Geolocalização")),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: FloatingActionButton(
        onPressed: _movimentarCamera,
        child: Icon(Icons.done),
      ),
      body: Container(
        child: GoogleMap(

          initialCameraPosition: cameraPosition,
          mapType: MapType.normal,
          onMapCreated: _onMapCreated,
          myLocationEnabled: true,
          markers: _marcadores,
          // polygons: _polygons,
          // polylines: _polylines,
        ),
      ),
    );
  }
}
