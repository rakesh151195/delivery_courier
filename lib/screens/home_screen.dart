import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Sendimformationtosql extends StatefulWidget {
  const Sendimformationtosql({Key? key}) : super(key: key);

  @override
  State<Sendimformationtosql> createState() => _SendimformationtosqlState();
}

class _SendimformationtosqlState extends State<Sendimformationtosql> {
  String location = 'Null, Press Button';
  String? address;

  final List<bool> _selections = List.generate(2, (_) => false);
  TimeOfDay selectedTime = TimeOfDay.now();
  late List<bool> isSelected;
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 15);
  int selectedCard = -1;
  late int _totalbill = 5;
  @override
  void initState() {
    isSelected = [true, false];

    super.initState();
  }

  void _selectTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (newTime != null) {
      setState(() {
        _time = newTime;
      });
    }
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> GetAddressFromLatLong(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    Placemark place = placemarks[0];
    address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Details",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          _buildcustomtextfield(),
          _builddestinationfield(),
          const Text(
            "Pick up",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          _buildpickuptime(),
          const Text(
            "Item information",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          _builditeminformation(),
          _calculatetotalprice(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
          ),
        ],
      ),
    );
  }

  _buildcustomtextfield() {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        //color: Colors.orange,
        border: Border.all(
            color: Colors.grey, // Set border color
            width: 1.0), // Set border width
        borderRadius: const BorderRadius.all(
            Radius.circular(15.0)), // Set rounded corner radius
      ),
      child: Row(
        children: [
          const Flexible(
            flex: 1,
            child: Icon(
              Icons.location_pin,
              color: Colors.green,
            ),
          ),
          Flexible(
            flex: 7,
            child: Text(
              "$address",
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
          ),
          Flexible(
            flex: 1,
            child: InkWell(
              child: const Icon(
                Icons.keyboard_arrow_right,
              ),
              // the method which is called
              // when button is pressed
              onTap: () async {
                Position position = await _getGeoLocationPosition();
                location =
                    'Lat: ${position.latitude} , Long: ${position.longitude}';
                GetAddressFromLatLong(position);
              },
            ),
          )
        ],
      ),
    );
  }

  _builddestinationfield() {
    return const TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.flag,
          color: Colors.red,
        ),
        suffixIcon: Icon(Icons.keyboard_arrow_right, color: Colors.green),
        //icon: Icon(Icons.search),
        labelText: "Enter you destination",
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.green),
        ),
      ),
    );
  }

  _buildpickuptime() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Time",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 10,
        ),
        togglebutton(),
        Container(
            width: 132,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(15),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              //color: Colors.orange,
              border: Border.all(
                  color: Colors.grey, // Set border color
                  width: 1.0), // Set border width
              borderRadius: const BorderRadius.all(
                  Radius.circular(15.0)), // Set rounded corner radius
            ),
            child: Row(
              children: [
                Text(
                  "${selectedTime.hour}:${selectedTime.minute}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  " - ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${selectedTime.hour}:${selectedTime.minute}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            )),
      ],
    );
  }

  selectTime() async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (timeOfDay != null && timeOfDay != selectedTime) {
      setState(() {
        selectedTime = timeOfDay;
      });
    }
  }

  togglebutton() {
    return ToggleButtons(
      borderColor: Colors.black,
      fillColor: Colors.blue,
      borderWidth: 1,
      selectedBorderColor: Colors.black,
      selectedColor: Colors.white,
      borderRadius: BorderRadius.circular(10),
      children: <Widget>[
        GestureDetector(
          onTap: () {
            setState(() {
              _selectTime();
            });
          },
          child: const Text(
            'AM',
            style: TextStyle(fontSize: 12),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _selectTime();
            });
          },
          child: const Text(
            'PM',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
      onPressed: (int index) {
        setState(() {
          for (int i = 0; i < isSelected.length; i++) {
            isSelected[i] = i == index;
          }
        });
      },
      isSelected: isSelected,
    );
  }

  final List<Map> myProducts =
      List.generate(10, (index) => {"id": index, "name": "Product $index"})
          .toList();

  _builditeminformation() {
    return FutureBuilder(
        future: CategoriesService().getCategories(1),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.error != null) {
              print('error ${snapshot.error}');
              return Text(snapshot.error.toString());
            }

            return GridView.builder(
              // physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 3 / 1,
                mainAxisSpacing: 6.0,
                crossAxisSpacing: 6.0,
              ),
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                Category category = snapshot.data[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      // ontap of each card, set the defined int to the grid view index
                      selectedCard = index;
                      _totalbill = selectedCard * 10;
                    });
                  },
                  child: Card(
                      color: selectedCard == index ? Colors.blue : Colors.grey,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          category.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: selectedCard == index
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      )),
                );
              },
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

  _calculatetotalprice() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Total bill",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Expanded(child: SizedBox()),
        Text(
          "\u0024 ${_totalbill}",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class CategoriesService {
  Future<List<Category>> getCategories(int value) async {
    return <Category>[
      Category(
        name: 'Daily necessities',
      ),
      Category(
        name: 'Food',
      ),
      Category(
        name: 'Document',
      ),
      Category(
        name: 'Clothing',
      ),
      Category(
        name: 'Digital product',
      ),
      Category(
        name: 'Other',
      ),
    ];
  }
}

class Category {
  String name;

  Category({
    required this.name,
  });
}
