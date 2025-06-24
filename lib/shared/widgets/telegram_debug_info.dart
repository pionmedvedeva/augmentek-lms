import 'package:flutter/material.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

class TelegramDebugInfo extends StatefulWidget {
  const TelegramDebugInfo({super.key});

  @override
  State<TelegramDebugInfo> createState() => _TelegramDebugInfoState();
}

class _TelegramDebugInfoState extends State<TelegramDebugInfo> {
  late TelegramWebApp webApp;
  
  @override
  void initState() {
    super.initState();
    webApp = TelegramWebApp.instance;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '📱 Telegram WebApp Info',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Flutter Screen Size', '${screenSize.width.toInt()}x${screenSize.height.toInt()}'),
          _buildInfoRow('Telegram Viewport', '${(webApp.viewportHeight ?? 0).toInt()}px high'),
          _buildInfoRow('Window Inner Size', '${webApp.viewportStableHeight?.toInt() ?? "N/A"}px stable'),
          _buildInfoRow('Is Expanded', webApp.isExpanded.toString()),
          _buildInfoRow('Platform', webApp.platform ?? 'Unknown'),
          _buildInfoRow('Version', webApp.version ?? 'Unknown'),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  webApp.expand();
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('Expand', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('Refresh', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
} 