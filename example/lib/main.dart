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
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: Color(0xFFFAFAFA),
        appBar: AppBar(
          title: const Text('example'),
          actions: [
            // example0 menu
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
        body: Column(
          children: [
            // example1  text
            CustomPopup(
              barrierColor: Colors.green.withOpacity(0.1),
              backgroundColor: Colors.white,
              content: Text('George says everything looks fine'),
              child: Icon(Icons.help, color: Colors.grey),
            ),
            SizedBox(height: 20),

            // example2  slider
            CustomPopup(
              arrowColor: Colors.orange,
              content: _Slider(),
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.primaries[10],
                child: Text('slider'),
              ),
            ),
            SizedBox(height: 20),

            // example3  calendar
            CustomPopup(
              showArrow: false,
              content: SizedBox(
                width: 300,
                child: CalendarDatePicker(
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now(),
                  onDateChanged: (v) {},
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.primaries[10],
                child: Text('calendar'),
              ),
            ),

            SizedBox(height: 20),

            // example4  filter
            Container(
              decoration: BoxDecoration(color: Colors.white),
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomPopup(
                    showArrow: false,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    barrierColor: Colors.transparent,
                    contentDecoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    content: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          4,
                          (index) => Text('item$index'),
                        ),
                      ),
                    ),
                    child: Text('filter1'),
                  ),
                  Text('filter2'),
                  Text('filter3'),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text('data' * 100, maxLines: 20),
          ],
        ),
      ),
    );
  }
}

class _Slider extends StatefulWidget {
  const _Slider();

  @override
  State<_Slider> createState() => __SliderState();
}

class __SliderState extends State<_Slider> {
  double progress = 0.5;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 100,
      child: Slider(
        value: progress,
        onChanged: (value) {
          setState(() => progress = value);
        },
      ),
    );
  }
}
