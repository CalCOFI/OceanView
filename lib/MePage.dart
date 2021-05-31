import 'package:flutter/material.dart';
import '../widgets/images_grid.dart';
class MePage extends StatefulWidget {
  const MePage({Key key}) : super(key: key);

  @override
  _MePageState createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ImagesGrid(),

    );
  }
}

<<<<<<< HEAD
=======
class FirstRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Gallery'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Image.asset('images/sea-slug.jpg'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SecondRoute()),
            );
          },
        ),
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Observation"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!!'),
          ),
        ),
    );
  }
  ListTile _tile(String title, String subtitle) => ListTile(
    title: Text(title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 20,
        )),
    subtitle: Text(subtitle),
  );
  Widget _buildList() => ListView(
    children: [
      _tile('CineArts at the Empire', '85 W Portal Ave'),
      _tile('The Castro Theater', '429 Castro St'),
      _tile('Alamo Drafthouse Cinema', '2550 Mission St'),
    ],
  );
}
>>>>>>> 68977d2055e1bfa1fedad386e27784c39fc884a6
