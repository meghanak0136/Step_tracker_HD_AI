import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';

void main() {
  runApp(const StepTrackerApp());
}

class StepTrackerApp extends StatelessWidget {
  const StepTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Step Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const StepTrackerPage(),
    );
  }
}

class StepTrackerPage extends StatefulWidget {
  const StepTrackerPage({super.key});

  @override
  State<StepTrackerPage> createState() => _StepTrackerPageState();
}

class _StepTrackerPageState extends State<StepTrackerPage> {
  StreamSubscription<StepCount>? _stepSubscription;
  StreamSubscription<PedestrianStatus>? _statusSubscription;

  int _steps = 0;
  int _initialSteps = 0;

  String _status = 'Unknown';
  String _error = '';

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  void _startTracking() {
    try {
      _stepSubscription = Pedometer.stepCountStream.listen(
        (StepCount event) {
          if (_initialSteps == 0) {
            _initialSteps = event.steps;
          }

          if (!mounted) return;

          setState(() {
            _steps = event.steps - _initialSteps;
          });
        },
        onError: (error) {
          if (!mounted) return;

          setState(() {
            _error = 'Step sensor error: $error';
          });
        },
      );

      _statusSubscription =
          Pedometer.pedestrianStatusStream.listen(
        (PedestrianStatus event) {
          if (!mounted) return;

          setState(() {
            _status = event.status;
          });
        },
        onError: (error) {
          if (!mounted) return;

          setState(() {
            _error = 'Activity sensor error: $error';
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    _statusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step Tracker'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.directions_walk,
                size: 100,
                color: Colors.blue,
              ),

              const SizedBox(height: 30),

              const Text(
                'Steps Taken',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                '$_steps',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              Text(
                'Activity: $_status',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 30),

              if (_error.isNotEmpty)
                Text(
                  _error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),

              const SizedBox(height: 30),

              const Text(
                'Walk with your phone to test the step counter.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}