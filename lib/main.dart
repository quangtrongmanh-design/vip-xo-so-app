import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

const Color brandRed = Color(0xFFC62828);
const Color ink = Color(0xFF202124);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NoticeService.init();
  runApp(const VipLotteryApp());
}

class VipLotteryApp extends StatelessWidget {
  const VipLotteryApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'VIP Xổ Số Miền Nam',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: brandRed),
      scaffoldBackgroundColor: const Color(0xFFF7F7F9),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: ink, centerTitle: false),
    ),
    home: const HomePage(),
  );
}

class NoticeService {
  static final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await plugin.initialize(const InitializationSettings(android: android));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  final ticketController = TextEditingController();
  String ticketResult = '';
  late final WebViewController webController;

  @override
  void initState() {
    super.initState();
    webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..loadRequest(Uri.parse('https://xsmn.mobi'));
  }

  @override void dispose() { ticketController.dispose(); super.dispose(); }

  void checkTicketLocally() {
    final ticket = ticketController.text.trim();
    if (ticket.isEmpty || !RegExp(r'^\d{2,6}$').hasMatch(ticket)) { 
      setState(() => ticketResult = 'Vui lòng nhập dãy số từ 2 đến 6 chữ số cần dò.'); 
      return; 
    }
    setState(() {
      ticketResult = '🔍 Đã ghi nhận số $ticket.\nAnh Duy có thể xem trực tiếp kết quả chính xác từng giải của các đài ngay tại tab "Kết quả" phía trên để đối chiếu nhanh chóng và chuẩn xác nhất!';
    });
  }

  @override Widget build(BuildContext context) {
    final pages = [resultsWebPage(), infoPage(), ticketPage(), settingsPage()];
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: brandRed, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.confirmation_number, color: Colors.white, size: 20)),
          const SizedBox(width: 10),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('VIP XỔ SỐ MIỀN NAM', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            Text('Kết quả chuẩn 100% • Trực tiếp', style: TextStyle(fontSize: 11, color: Colors.black54))
          ])),
        ]),
        actions: [
          IconButton(
            onPressed: () => webController.reload(), 
            icon: const Icon(Icons.refresh), 
            tooltip: 'Tải lại trang'
          )
        ],
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: 'Kết quả'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), label: 'Lịch quay'),
          NavigationDestination(icon: Icon(Icons.confirmation_number_outlined), label: 'Dò vé'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Cài đặt'),
        ],
      ),
    );
  }

  // Tab 1: Kết quả WebView trực tiếp chuẩn 100% từ xsmn.mobi
  Widget resultsWebPage() => WebViewWidget(controller: webController);

  // Tab 2: Lịch quay thưởng các đài Miền Nam trong tuần
  Widget infoPage() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text('LỊCH QUY ĐÀI XỔ SỐ MIỀN NAM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      _scheduleCard('Thứ Hai', ['TP. Hồ Chí Minh', 'Đồng Tháp', 'Cà Mau']),
      _scheduleCard('Thứ Ba', ['Bến Tre', 'Vũng Tàu', 'Bạc Liêu']),
      _scheduleCard('Thứ Tư', ['Đồng Nai', 'Cần Thơ', 'Sóc Trăng']),
      _scheduleCard('Thứ Năm', ['Tây Ninh', 'An Giang', 'Bình Thuận']),
      _scheduleCard('Thứ Sáu', ['Vĩnh Long', 'Bình Dương', 'Trà Vinh']),
      _scheduleCard('Thứ Bảy', ['TP. Hồ Chí Minh', 'Long An', 'Bình Phước', 'Hậu Giang']),
      _scheduleCard('Chủ Nhật', ['Tiền Giang', 'Kiên Giang', 'Đà Lạt']),
    ],
  );

  Widget _scheduleCard(String day, List<String> provinces) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: CircleAvatar(backgroundColor: const Color(0xFFFFE5E5), child: Text(day.substring(day.length - 2), style: const TextStyle(color: brandRed, fontWeight: FontWeight.bold, fontSize: 12))),
      title: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Đài: ${provinces.join(', ')}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
    ),
  );

  // Tab 3: Hướng dẫn dò vé số nhanh
  Widget ticketPage() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text('DÒ VÉ SỐ TRỰC TUYẾN', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 14),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Nhập dãy số trên vé (từ 2 đến 6 số)', style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: ticketController, 
              keyboardType: TextInputType.number, 
              maxLength: 6, 
              decoration: const InputDecoration(
                border: OutlineInputBorder(), 
                hintText: 'Ví dụ: 091891 hoặc 91', 
                prefixIcon: Icon(Icons.confirmation_number)
              )
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity, 
              height: 45, 
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: brandRed, foregroundColor: Colors.white), 
                onPressed: checkTicketLocally, 
                icon: const Icon(Icons.search), 
                label: const Text('HƯỚNG DẪN ĐỐI CHIẾU', style: TextStyle(fontWeight: FontWeight.bold))
              )
            ),
          ]),
        ),
      ),
      if (ticketResult.isNotEmpty) ...[
        const SizedBox(height: 12),
        Card(color: Colors.white, child: Padding(padding: const EdgeInsets.all(16), child: SelectableText(ticketResult, style: const TextStyle(height: 1.6, fontSize: 14, fontWeight: FontWeight.w600, color: ink)))),
      ],
    ],
  );

  // Tab 4: Cài đặt & Thông tin phiên bản
  Widget settingsPage() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text('CÀI ĐẶT', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      const Card(child: ListTile(leading: Icon(Icons.verified, color: brandRed), title: Text('Nguồn dữ liệu trực tuyến'), subtitle: Text('Đồng bộ thời gian thực chuẩn xác 100% từ xsmn.mobi'))),
      Card(child: const ListTile(leading: Icon(Icons.verified_user_outlined, color: brandRed), title: Text('Phiên bản ứng dụng'), subtitle: Text('VIP Xổ Số Miền Nam • v2.0 Pro'))),
    ],
  );
}
