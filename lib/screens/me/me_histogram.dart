import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:ocean_view/models/observation.dart';
import 'package:ocean_view/shared/constants.dart';
import 'package:provider/provider.dart';

/*
 Widget for showing histogram of statistics
 */

class MeHistogram extends StatelessWidget {
  String field;
  Observation curObs;
  MeHistogram({required this.field, required this.curObs});

  List<dynamic> getHistogram(List<double> fieldList) {
    /* Calculate histogram for given list */
    double targetValue = curObs.map[field];

    // Calculate each bar in histogram
    int barNum = 9;
    double curBar = 0.0, nextBar = 0.0;
    double minNum = fieldList
        .reduce((current, next) => current < next ? current : next)
        .toDouble();
    double maxNum = fieldList
        .reduce((current, next) => current > next ? current : next)
        .toDouble();
    double stride = (maxNum - minNum) / barNum;
    List<int> counts = [];
    List<String> barLocations = [];
    List<OrdinalFields> data = [];
    double percentage = 0;
    charts.Color barColor;

    for (int i = 0; i < barNum; i++) {
      int count = 0;
      curBar = minNum + i * stride;
      nextBar = (i == barNum - 1) ? maxNum + 0.1 : curBar + stride;
      barLocations.add(i.toString());
      for (int j = 0; j < fieldList.length; j++) {
        if (curBar <= fieldList[j] && fieldList[j] < nextBar) {
          count += 1;
        }
      }
      counts.add(count);

      if (curBar <= targetValue && targetValue < nextBar) {
        double totalCounts = 0;
        // Calculate percentage
        for (int i_count = 0; i_count < counts.length - 1; i_count++) {
          totalCounts += counts[i_count];
        }
        percentage = totalCounts / fieldList.length * 100;

        // Decide bar color
        barColor = charts.ColorUtil.fromDartColor(Colors.red);
        print('Set bar ($curBar) to red');
      } else {
        barColor = charts.ColorUtil.fromDartColor(Colors.lightBlue);
      }

      data.add(OrdinalFields(curBar.toStringAsFixed(2), count, barColor));
    }

    // Create series list from given histogram
    List<charts.Series<OrdinalFields, String>> seriesList = [
      charts.Series<OrdinalFields, String>(
          id: field,
          colorFn: (OrdinalFields fields, __) => fields.barColor,
          domainFn: (OrdinalFields fields, _) => fields.field,
          measureFn: (OrdinalFields fields, _) => fields.count,
          data: data)
    ];

    List<dynamic> result = [];
    result.add(seriesList);
    result.add(percentage.toStringAsFixed(2));

    return result;
  }

  @override
  Widget build(BuildContext context) {
    List<Observation> observations =
        Provider.of<List<Observation>?>(context) ?? [];
    String strObs = '';
    int index = 0;
    List<double> fieldList = <double>[];
    List<dynamic> result = [];
    String description = '';

    print('--- $field ---');
    observations.forEach((observation) {
      print(
          '$index: ${observation.documentID}, ${observation.name}, ${observation.confidentiality}');
      strObs +=
          '$index: ${observation.documentID}, ${observation.name}, ${observation.confidentiality}\n';
      index += 1;

      // Add needed field from qualified observations to list
      fieldList.add(observation.map[this.field]);
    });

    if (fieldList.length == 0) {
      description = 'Loading';
    } else if (fieldList.length == 1) {
      description = 'You are the first one to upload this observation!';
    } else {
      print(fieldList);
      result = getHistogram(fieldList);
      description = '${curObs.map[field]} is ${descriptionMap[field]} than '
          '${result[1]}% of observations';
    }

    // return Text(field+":\n"+strObs);
    // TODO: Write in expanded version
    return Center(
        child: Container(
            height: 200,
            child: Card(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [
                      Text('Histogram of ${this.field}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 20),
                      (fieldList.length > 1)
                          ? Expanded(
                              child: SimpleBarChart(seriesList: result[0]),
                            )
                          : SizedBox(height: 10),
                      const SizedBox(height: 10),
                      Text(description,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                    ])))));
  }
}

class SimpleBarChart extends StatelessWidget {
  final List<charts.Series<OrdinalFields, String>> seriesList;
  final bool animate;

  SimpleBarChart({required this.seriesList, this.animate = false});

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      seriesList,
      animate: animate,
      defaultInteractions: false,
    );
  }
}

// Ordinal data type.
class OrdinalFields {
  final String field;
  final int count;
  final charts.Color barColor;

  OrdinalFields(this.field, this.count, this.barColor);
}
