import 'package:flutter/material.dart';
import 'package:ocean_view/src/pin_information.dart';

class RegulationPage extends StatelessWidget {

  final PinInformation pinInformation;

  RegulationPage({required this.pinInformation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(pinInformation.locationName),
        )
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children:[
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Type: ${pinInformation.locationType}",
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(10),
              itemCount: pinInformation.exceptions.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: Text(
                    "${index+1}. ${pinInformation.exceptions[index]}",
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) => const Divider(),
            ),
          )
        ]
      )

    );
  }
}
