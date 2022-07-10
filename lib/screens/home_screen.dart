import 'dart:io';

import 'package:bands_app/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bands_app/models/models.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Band> bands = [
    Band(id: "1", name: "Metalica", votes: 5),
    Band(id: "2", name: "Queen", votes: 3),
    Band(id: "3", name: "Angeles del infierno", votes: 2),
    Band(id: "4", name: "Bon Jovi", votes: 5),
  ];

  @override
  void initState() {
    final socket = Provider.of<SocketService>(context, listen: false);
    socket.client.on('bands', (data) {
      print(data);
    });
    super.initState();
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
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (_, i) => _bandTile(bands[i]),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        onPressed: () => addNewBand(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (DismissDirection direction) {
        print("direction: $direction");
        print('id ${band.id}');
        //TODO delete band BACKEND
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
          print(band.name);
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
    if (name.isNotEmpty) {
      // Agregar
      bands.add(Band(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          votes: 0));
      setState(() {});
    }
    Navigator.pop(context);
  }
}
