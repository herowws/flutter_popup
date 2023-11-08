import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double progress = 0.5;
  final GlobalKey _anchorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('example'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: CustomPopup(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) => Text('menu$index')),
              ),
              child: const Icon(Icons.add_circle_outline),
            ),
          ),
        ],
      ),
      body: DefaultTextStyle(
        style: const TextStyle(
          decoration: TextDecoration.none,
          fontSize: 16,
          color: Colors.black,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CustomPopup(
              content: Text(
                'George says everything looks fine',
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              child: Icon(Icons.help, color: Colors.grey),
            ),
            CustomPopup(
              anchorKey: _anchorKey,
              content: SizedBox(
                width: 100,
                height: 100,
                child: LayoutBuilder(
                  builder: (c, v) => Slider(
                    value: progress,
                    onChanged: (value) {
                      setState(() => progress = value);
                    },
                  ),
                ),
              ),
              child: const Icon(Icons.help, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
