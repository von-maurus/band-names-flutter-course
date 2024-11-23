import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:band_names/models/band.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: "TRH001", name: 'Metallica', votes: 5),
    Band(id: "TRH002", name: 'Pantera', votes: 2),
    Band(id: "TRH003", name: 'Slayer', votes: 3),
    Band(id: "TRH004", name: 'Led Zeppelin', votes: 7),
    Band(id: "TRH005", name: 'Megadeth', votes: 10),
  ];

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
        title: const Text(
          'Band Names',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        itemCount: bands.length,
        itemBuilder: (context, index) => _bandElement(bands[index]),
      ),
    );
  }

  Widget _bandElement(Band band) {
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
      onDismissed: (dir) {
        setState(() {
          bands.removeWhere((i) => i.id == band.id);
        });
      },
      child: ListTile(
        title: Text(band.name),
        trailing: Text('${band.votes}', style: const TextStyle(fontSize: 20)),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0, 4)),
        ),
        onTap: () {},
      ),
    );
  }

  void _addBandDialog(BuildContext context) {
    final newBandTextCtrl = TextEditingController();
    if (Platform.isAndroid) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('New band name'),
              content: TextField(
                controller: newBandTextCtrl,
              ),
              actions: [
                MaterialButton(
                  elevation: 5,
                  textColor: Colors.blue,
                  child: Text('Add'),
                  onPressed: () => _addBand(newBandTextCtrl),
                )
              ],
            );
          });
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('New band name'),
            content: CupertinoTextField(
              controller: newBandTextCtrl,
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Add'),
                onPressed: () => _addBand(newBandTextCtrl),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text('Dismiss'),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        },
      );
    }
  }

  void _addBand(TextEditingController ctrl) {
    if (ctrl.text.isNotEmpty) {
      setState(() {
        bands.add(Band(id: DateTime.now().toIso8601String(), name: ctrl.text, votes: 0));
      });
    }
    Navigator.of(context).pop();
  }
}
