
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoScreen extends StatefulWidget {
  final DateTime? selectedDate;

  const MemoScreen({super.key, this.selectedDate});

  @override
  MemoScreenState createState() => MemoScreenState();
}

class MemoScreenState extends State<MemoScreen> {
  final TextEditingController _controller = TextEditingController();
  late SharedPreferences _prefs;
  late DateTime _selectedDay;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDate ?? DateTime.now();
    _loadMemo();
  }

  @override
  void dispose() {
    _controller.dispose(); // Properly dispose the controller
    super.dispose();
  }

  Future<void> _loadMemo() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      // Check if the widget is still mounted before calling setState
      if (!mounted) return;

      final memo = _prefs.getString(_selectedDay.toString()) ?? '';
      setState(() {
        _controller.text = memo;
        _isLoading = false;
      });
    } catch (e, s) {
      if (kDebugMode) {
        print('Error loading memo: $e\n$s');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load memo.')),
        );
      }
    }
  }

  void _saveMemo(String text) {
    // Add error handling for the save operation
    _prefs.setString(_selectedDay.toString(), text).catchError((error, stackTrace) {
      if (kDebugMode) {
        print('Failed to save memo: $error\n$stackTrace');
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_selectedDay.month}/${_selectedDay.day} Memo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Enter your memo...',
                  border: InputBorder.none,
                ),
                onChanged: _saveMemo,
              ),
      ),
    );
  }
}
