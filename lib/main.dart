import 'package:flutter/material.dart';
import 'package:subin_model_demo/pages/video_demo_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
  final _controller = PageController();
  final _total = 4;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Q${_controller.hasClients ? (_controller.page?.toInt() ?? 0) + 1 : ""}.'),
      ),
      body: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padEnds: true,
        itemCount: _total,
        controller: _controller,
        // onPageChanged: (int index) => setState(() {}),
        itemBuilder: (_, i) {
          return VideoDemoScreen(
            demoNum: i,
            onBackPressed: () {
              if (i > 0) {
                _controller.jumpToPage(i - 1);
                setState(() {});
              }
            },
            onNextPressed: () {
              if (i < _total - 1) {
                _controller.jumpToPage(i + 1);
                setState(() {});
              }
            },
          );
        },
      ),
    );
  }
}
