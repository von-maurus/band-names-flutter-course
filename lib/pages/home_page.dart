import 'dart:io';
import 'package:band_names/services/socket.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:band_names/models/band.dart';
import 'package:band_names/pages/socket_status_widget.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleBands);
    super.initState();
  }

  _handleBands(dynamic payload) {
    bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        child: const Icon(Icons.add),
        onPressed: () => _addBandDialog(context),
      ),
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: const Text(
          'Band Names',
          style: TextStyle(color: Colors.black87),
        ),
        actions: const [
          SocketStatusWidget(),
        ],
      ),
      body: Column(
        children: [
          _showPieChart(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              itemCount: bands.length,
              itemBuilder: (context, index) => _bandElement(bands[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bandElement(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        padding: const EdgeInsets.only(right: 8),
        child: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Delete',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      onDismissed: (dir) => socketService.socket.emit('remove-band', {'id': band.id}),
      child: ListTile(
        title: Text(band.name),
        trailing: Text('${band.votes}', style: const TextStyle(fontSize: 20)),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0, 4)),
        ),
        onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),
      ),
    );
  }

  void _addBandDialog(BuildContext context) {
    final newBandTextCtrl = TextEditingController();
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('New band name'),
          content: TextField(
            controller: newBandTextCtrl,
          ),
          actions: [
            MaterialButton(
              elevation: 5,
              textColor: Colors.blue,
              child: const Text('Add'),
              onPressed: () => _addBand(newBandTextCtrl),
            )
          ],
        ),
      );
      return;
    }
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('New band name'),
        content: CupertinoTextField(
          controller: newBandTextCtrl,
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Add'),
            onPressed: () => _addBand(newBandTextCtrl),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Dismiss'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  void _addBand(TextEditingController ctrl) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    if (ctrl.text.isNotEmpty) {
      socketService.socket.emit('add-band', Band(id: '', name: ctrl.text, votes: 0).toJson());
    }
    Navigator.of(context).pop();
  }

  Widget _showPieChart() {
    Map<String, double> dataMap = {};

    for (final band in bands) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    }

    final List<Color> colorList = [Colors.blue.shade200, Colors.red[200]!];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 3.2,
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 32,
        centerText: "BANDS",
        legendOptions: const LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          legendShape: BoxShape.circle,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
          decimalPlaces: 1,
        ),
        // gradientList: ---To add gradient colors---
        // emptyColorGradient: ---Empty Color gradient---
      ),
    );
  }
}
