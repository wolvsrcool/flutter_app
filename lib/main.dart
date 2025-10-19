import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Lab 1',
    theme: ThemeData(useMaterial3: true),
    home: const MyHomePage(title: 'Flutter - Lab 1'),
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, super.key});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _c = TextEditingController();
  final _hex = RegExp(r'^#?([A-Fa-f0-9]{6})$');
  int _count = 0;
  Color _bg = Colors.white;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Color _fromHex(String s) =>
      Color(int.parse('FF${s.replaceFirst('#', '')}', radix: 16));

  void _apply() {
    final s = _c.text.trim();
    if (s.isEmpty) return;

    if (s.toLowerCase() == 'avada kedavra') {
      setState(() {
        _count = 0;
        _bg = Colors.white;
        _c.text = '';
      });
      return;
    }

    final v = num.tryParse(s.replaceAll(',', '.'));
    if (v != null) {
      setState(() {
        _count += v.round();
      });
      return;
    }

    if (_hex.hasMatch(s)) {
      setState(() {
        _bg = _fromHex(s);
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = ThemeData.estimateBrightnessForColor(_bg) == Brightness.dark;
    final fg = dark ? Colors.white : Colors.black87;

    // Calculate contrast colors
    final borderColor = dark
        ? Colors.white.withOpacity(0.4)
        : Colors.black.withOpacity(0.4);
    final buttonBg = dark
        ? Colors.white.withOpacity(0.9)
        : Colors.black.withOpacity(0.8);
    final buttonFg = dark ? Colors.black87 : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black87,
      ),
      body: Container(
        color: _bg,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Text(
                  '$_count',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _c,
                        onSubmitted: (_) => _apply(),
                        style: TextStyle(color: fg),
                        cursorColor: fg,
                        decoration: InputDecoration(
                          hintText: 'пім-пум-пум',
                          hintStyle: TextStyle(color: fg.withOpacity(0.6)),
                          prefixIcon: Icon(Icons.auto_awesome, color: fg),
                          filled: true,
                          fillColor: dark ? Colors.white10 : Colors.black12,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: borderColor,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: borderColor,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: borderColor,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: _apply,
                        style: FilledButton.styleFrom(
                          backgroundColor: buttonBg,
                          foregroundColor: buttonFg,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('OK'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
