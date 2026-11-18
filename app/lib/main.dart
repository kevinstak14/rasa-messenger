import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(const RasaApp());

class RasaApp extends StatelessWidget {
  const RasaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'رسا',
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff3390ec)), useMaterial3: true),
    home: const StartupPage(),
  );
}

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});
  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  bool checking = true;
  int attempts = 0;
  Future<void> checkServer() async {
    setState(() { checking = true; attempts = 0; });
    for (var i = 0; i < 15; i++) {
      if (!mounted) return;
      try {
        final response = await http.get(Uri.parse('http://127.0.0.1:3000/api/health')).timeout(const Duration(seconds: 2));
        if (response.statusCode == 200) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MessengerPage()));
          return;
        }
      } catch (_) {}
      setState(() => attempts = i + 1);
      await Future.delayed(const Duration(seconds: 1));
    }
    if (mounted) setState(() => checking = false);
  }
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => checkServer()); }
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xff3390ec),
    body: Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 94, height: 94, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)), child: const Center(child: Text('ر', style: TextStyle(color: Color(0xff3390ec), fontSize: 60, fontWeight: FontWeight.bold)))),
      const SizedBox(height: 18), const Text('رسا', style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12), if (checking) ...[const CircularProgressIndicator(color: Colors.white), const SizedBox(height: 12), Text('در حال اتصال… $attempts/15', style: const TextStyle(color: Colors.white))] else ...[
        const Text('سرور روشن نیست. Termux را باز کن و\nbash start.sh بزن', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, height: 1.8)),
        const SizedBox(height: 18), FilledButton(onPressed: checkServer, style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xff3390ec)), child: const Text('تلاش دوباره'))
      ]
    ]))),
  );
}

class MessengerPage extends StatefulWidget { const MessengerPage({super.key}); @override State<MessengerPage> createState() => _MessengerPageState(); }
class _MessengerPageState extends State<MessengerPage> {
  late final WebViewController controller;
  DateTime? lastBack;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xff3390ec))
      ..setNavigationDelegate(NavigationDelegate(onWebResourceError: (e) {}))
      ..loadRequest(Uri.parse('http://127.0.0.1:3000'));
  }
  Future<bool> handleBack() async {
    if (await controller.canGoBack()) { await controller.goBack(); return false; }
    final now = DateTime.now();
    if (lastBack == null || now.difference(lastBack!) > const Duration(seconds: 2)) { lastBack = now; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('برای خروج دوباره دکمه بازگشت را بزنید'))); return false; }
    return true;
  }
  @override
  Widget build(BuildContext context) => PopScope(canPop: false, onPopInvoked: (didPop) async { if (!didPop && await handleBack()) { SystemNavigator.pop(); } }, child: Scaffold(body: SafeArea(top: false, child: WebViewWidget(controller: controller))));
}
