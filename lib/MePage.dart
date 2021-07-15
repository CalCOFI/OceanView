import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  home:MePage(key: UniqueKey()),
));

class MePage extends StatelessWidget {
  const MePage({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Text('My Gallery'),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0.0,
      ),
      body:Padding(
        padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0,0.0),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin:EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              child: Center(
                child:Image.asset('assets/trout.png',
                height: 250,
                width: 180,
                ),
              ),
            ),
            Divider(

              color:Colors.black,
            ),
            Text(
              'Species Name:',
              style: TextStyle(
                color:Colors.grey,
                letterSpacing: 2.0,
              )
            ),
            Text(
                'Rainbow Trout',
                style: TextStyle(
                  color:Colors.black54,
                  letterSpacing: 2.0,
                  fontSize:18.0,
                  fontWeight: FontWeight.bold,
                )
            ),
            SizedBox(height:10.0),
            Text(
                'Length(feet):',
                style: TextStyle(
                  color:Colors.grey,
                  letterSpacing: 2.0,
                )
            ),
            Text(
                '1.2',
                style: TextStyle(
                  color:Colors.black54,
                  letterSpacing: 2.0,
                  fontSize:18.0,
                  fontWeight: FontWeight.bold,
                )
            ),
            SizedBox(height:10.0),
            Text(
                'Weight(lb):',
                style: TextStyle(
                  color:Colors.grey,
                  letterSpacing: 2.0,
                )
            ),
            Text(
                '  ',
                style: TextStyle(
                  color:Colors.black54,
                  letterSpacing: 2.0,
                  fontSize:18.0,
                  fontWeight: FontWeight.bold,
                )
            ),
            SizedBox(height:10.0),
            Text(
                'Quantity: ',
                style: TextStyle(
                  color:Colors.grey,
                  letterSpacing: 2.0,
                )
            ),
            Text(
                '3',
                style: TextStyle(
                  color:Colors.black54,
                  letterSpacing: 2.0,
                  fontSize:18.0,
                  fontWeight: FontWeight.bold,
                )
            ),
            SizedBox(height:10.0),
            Text(
                'Time:',
                style: TextStyle(
                  color:Colors.grey,
                  letterSpacing: 2.0,
                )
            ),
            Text(
                '11:08 AM, Sun 05/02/2021',
                style: TextStyle(
                  color:Colors.black54,
                  letterSpacing: 2.0,
                  fontSize:18.0,
                  fontWeight: FontWeight.bold,
                )
            ),
            SizedBox(height:10.0),
            Text(
                'Location: ',
                style: TextStyle(
                  color:Colors.grey,
                  letterSpacing: 2.0,
                )
            ),
            Text(
                'Wentang, Jiangxi, China',
                style: TextStyle(
                  color:Colors.black54,
                  letterSpacing: 2.0,
                  fontSize:18.0,
                  fontWeight: FontWeight.bold,
                )
            ),
            SizedBox(height:10.0),
            Text(
                'Released/Kept:',
                style: TextStyle(
                  color:Colors.grey,
                  letterSpacing: 2.0,
                )
            ),
            Text(
                'Kept',
                style: TextStyle(
                  color:Colors.black54,
                  letterSpacing: 2.0,
                  fontSize:18.0,
                  fontWeight: FontWeight.bold,
                )
            ),
          ],
        ),
      ),
    );
  }
}

