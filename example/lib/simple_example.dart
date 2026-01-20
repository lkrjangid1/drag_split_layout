import 'package:drag_split_layout/drag_split_layout.dart';
import 'package:flutter/material.dart';

/// A minimal example showing the simplest usage of drag_split_layout
void main() {
  runApp(const SimpleExampleApp());
}

class SimpleExampleApp extends StatelessWidget {
  const SimpleExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Drag Split Layout',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SimpleExample(),
    );
  }
}

class SimpleExample extends StatefulWidget {
  const SimpleExample({super.key});

  @override
  State<SimpleExample> createState() => _SimpleExampleState();
}

class _SimpleExampleState extends State<SimpleExample> {
  bool _editMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Example'),
        actions: [
          Switch(
            value: _editMode,
            onChanged: (v) => setState(() => _editMode = v),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SimpleEditableLayout(
        editMode: _editMode,
        initialAxis: SplitAxis.horizontal,
        children: [
          _buildPanel('Panel 1', Colors.blue),
          _buildPanel('Panel 2', Colors.green),
          _buildPanel('Panel 3', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildPanel(String title, Color color) {
    return Container(
      color: color.withValues(alpha: 0.2),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.widgets, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Drag to rearrange',
              style: TextStyle(color: color.withValues(alpha: 0.7)),
            ),
          ],
        ),
      ),
    );
  }
}
