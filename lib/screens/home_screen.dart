import 'dart:io';

import 'package:bands_app/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bands_app/models/models.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Band> bands = [
    // Band(id: "1", name: "Metalica", votes: 5),
    // Band(id: "2", name: "Queen", votes: 3),
    // Band(id: "3", name: "Angeles del infierno", votes: 2),
    // Band(id: "4", name: "Bon Jovi", votes: 5),
  ];

  @override
  void initState() {
    final socket = Provider.of<SocketService>(context, listen: false);
    socket.client.on('bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(payload) {
    bands = (payload as List).map((band) => Band.fromJson(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socket = Provider.of<SocketService>(context, listen: false);
    socket.client.off('bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serverSocket = Provider.of<SocketService>(context);
    final serverStatus = serverSocket.serverStatus;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bands Name'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: serverStatus == ServerStatus.online
                ? Icon(
                    Icons.check_circle_rounded,
                    color: Colors.blue[300],
                  )
                : const Icon(
                    Icons.offline_bolt_rounded,
                    color: Colors.red,
                  ),
          )
        ],
      ),
      body: Column(
        children: [
          _showBandsPieChart(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (_, i) => _bandTile(bands[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        onPressed: () => addNewBand(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTile(Band band) {
    final SocketService socketService =
        Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (DismissDirection direction) {
        socketService.client.emit('delete-band', {'id': band.id});
      },
      background: Container(
        padding: const EdgeInsets.only(left: 40),
        child: const Align(
            alignment: Alignment.centerLeft,
            child: Icon(Icons.delete, color: Colors.blue)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0, 2)),
        ),
        title: Text(band.name),
        trailing: Text(
          band.votes.toString(),
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        onTap: () {
          socketService.client.emit('vote-band', {'id': band.id});
        },
      ),
    );
  }

  addNewBand() {
    final TextEditingController textController = TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text("New band name"),
              content: TextField(
                controller: textController,
              ),
              actions: [
                MaterialButton(
                  onPressed: () => addBandtoList(textController.text),
                  elevation: 5,
                  textColor: Colors.blue,
                  child: const Text("Add"),
                ),
              ],
            );
          });
      return;
    }

    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: const Text("New band name"),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => addBandtoList(textController.text),
                child: const Text("Add"),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          );
        });
  }

  addBandtoList(String name) {
    final SocketService socketService =
        Provider.of<SocketService>(context, listen: false);
    if (name.isNotEmpty) {
      // Agregar
      socketService.client.emit('add-band', {'name': name});
    }
    Navigator.pop(context);
  }

  Widget _showBandsPieChart() {
    Map<String, double> dataMap = {};

    for (Band band in bands) {
      dataMap[band.name] = band.votes.toDouble();
    }

    return dataMap.isEmpty
        ? Container()
        : Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: pieChart(dataMap));
    //return PieChart(dataMap: dataMap);
  }

  PieChart pieChart(Map<String, double> dataMap) {
    final colorList = [
      Colors.lightBlue,
      Colors.lightGreen,
      Colors.limeAccent,
      Colors.pinkAccent,
      Colors.purpleAccent,
      Colors.redAccent,
      Colors.yellowAccent,
      Colors.orangeAccent,
      Colors.greenAccent,
    ];
    return PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 800),
        chartRadius: MediaQuery.of(context).size.width / 2.5,
        initialAngleInDegree: 0,
        colorList: colorList,
        chartType: ChartType.ring,
        ringStrokeWidth: 32,
        legendOptions: const LegendOptions(
          showLegendsInRow: false,
          showLegends: true,
          legendTextStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: false,
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
          decimalPlaces: 0,
        )
        // gradientList: ---To add gradient colors---
        // emptyColorGradient: ---Empty Color gradient---
        );
  }
}
