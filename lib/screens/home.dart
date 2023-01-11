import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../constants/theme.dart';
import '../screens/import.dart';

class HomeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kBackgroundColor,
      endDrawerEnableOpenDragGesture: false,
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(
                height: 40.0,
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text("Help "),
              ),
              const SizedBox(
                height: 40.0,
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text("Info "),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          // ignore: sized_box_for_whitespace
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 20, top: 20),
                  child: Builder(builder: (context) {
                    return InkWell(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: SvgPicture.asset(
                          'assets/icons/menu.svg',
                          color: kPrimaryColor,
                        ),
                      ),
                    );
                  }),
                ),
                const Center(
                  child: Text(
                    'All In One App',
                    style:
                        TextStyle(fontSize: titleFontSize, color: kTextColor),
                  ),
                ),
                Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ImportScreen()));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: const Icon(Icons.arrow_forward,
                          size: 40, color: kTextColor),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(width: 2, color: kTextColor)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
