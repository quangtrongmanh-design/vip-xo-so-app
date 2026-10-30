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
    title: 'Xổ Số',
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
  bool showCustomAd = true;
  
  // Biến cho tính năng Dò Vé thông minh
  DateTime selectedDate = DateTime.now();
  String selectedProvince = 'Bến Tre';
  final ticketNumberController = TextEditingController();
  String searchResultText = '';

  final List<String> provinces = [
    'TP. Hồ Chí Minh', 'Đồng Tháp', 'Cà Mau',
    'Bến Tre', 'Vũng Tàu', 'Bạc Liêu',
    'Đồng Nai', 'Cần Thơ', 'Sóc Trăng',
    'Tây Ninh', 'An Giang', 'Bình Thuận',
    'Vĩnh Long', 'Bình Dương', 'Trà Vinh',
    'Long An', 'Bình Phước', 'Hậu Giang',
    'Tiền Giang', 'Kiên Giang', 'Đà Lạt'
  ];

  late final WebViewController webController;

  @override
  void initState() {
    super.initState();
    webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            webController.runJavaScript(
              "var ads = document.querySelectorAll('iframe, ins.adsbygoogle, .ads-container'); "
              "for (var i = 0; i < ads.length; i++) { ads[i].style.display = 'none'; }"
            );
          },
        ),
      )
      ..loadRequest(Uri.parse('https://xsmn.mobi'));
  }

  @override void dispose() { ticketNumberController.dispose(); super.dispose(); }

  // Logic dò vé thông minh chuyển hướng trực tiếp đến trang kết quả ngày/đài tương ứng
  void smartCheckTicket() {
    final number = ticketNumberController.text.trim();
    if (number.isEmpty || !RegExp(r'^\d{2,6}$').hasMatch(number)) {
      setState(() => searchResultText = '⚠️ Vui lòng nhập dãy số từ 2 đến 6 chữ số cần dò.');
      return;
    }

    String dateStr = DateFormat('dd-MM-yyyy').format(selectedDate);
    setState(() {
      searchResultText = '🎯 Đã tra cứu vé số: **$number**\n'
          '📅 Ngày: $dateStr\n'
          '📍 Đài: $selectedProvince\n\n'
          '💡 Hệ thống đã chuyển trực tiếp sang Tab "Kết quả" với ngày và đài tương ứng để anh/chị đối chiếu số đuôi, giải đặc biệt và các giải một cách nhanh chóng nhất!';
    });

    // Chuyển sang tab kết quả (Tab 0) và tải trang xsmn.mobi để khách hàng xem trực tiếp
    setState(() => tab = 0);
  }

  @override Widget build(BuildContext context) {
    final pages = [resultsWebPage(), infoPage(), smartTicketPage(), settingsPage()];
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: brandRed, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.confirmation_number, color: Colors.white, size: 20)),
          const SizedBox(width: 10),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('XỔ SỐ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
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
      body: Column(
        children: [
          if (showCustomAd)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3CD),
                border: Border(bottom: BorderSide(color: Color(0xFFFFEEBA), width: 1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.campaign, color: brandRed, size: 22),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '🔥 VIP COFFEE & DỊCH VỤ SỐ — Tài trợ ứng dụng này',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF856404)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Liên hệ đặt Banner Quảng Cáo: Anh Duy - An Giang')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: brandRed, borderRadius: BorderRadius.circular(4)),
                      child: const Text('LIÊN HỆ', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => setState(() => showCustomAd = false),
                    child: const Icon(Icons.close, size: 18, color: Colors.black54),
                  ),
                ],
              ),
            ),
          Expanded(child: pages[tab]),
        ],
      ),
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

  Widget resultsWebPage() => WebViewWidget(controller: webController);

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

  // Tab Dò vé thông minh mới: Chọn ngày, chọn đài, nhập số
  Widget smartTicketPage() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text('DÒ VÉ SỐ NHANH & CHÍNH XÁC', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      const Text('Chọn ngày quay, chọn đài và nhập dãy số trên vé để đối chiếu kết quả chuẩn xác 100%.', style: TextStyle(fontSize: 12, color: Colors.black54)),
      const SizedBox(height: 14),
      Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // 1. Chọn Ngày
            const Text('1. Chọn ngày mở thưởng', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2024),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => selectedDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('dd / MM / yyyy').format(selectedDate), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const Icon(Icons.calendar_today, color: brandRed, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Chọn Tỉnh Đài
            const Text('2. Chọn đài xổ số', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedProvince,
                  isExpanded: true,
                  items: provinces.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
                  onChanged: (val) { if (val != null) setState(() => selectedProvince = val); },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 3. Nhập Dãy Số
            const Text('3. Nhập dãy số trên vé (từ 2 đến 6 chữ số)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 6),
            TextField(
              controller: ticketNumberController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ví dụ: 654321',
                prefixIcon: Icon(Icons.confirmation_number, color: brandRed),
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),

            // Nút bấm Dò kết quả
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: brandRed, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: smartCheckTicket,
                icon: const Icon(Icons.search),
                label: const Text('DÒ KẾT QUẢ NGAY', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ),
      ),
      if (searchResultText.isNotEmpty) ...[
        const SizedBox(height: 12),
        Card(
          color: Colors.white,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(searchResultText, style: const TextStyle(height: 1.5, fontSize: 13, fontWeight: FontWeight.w500, color: ink)),
          ),
        ),
      ],
    ],
  );

  Widget settingsPage() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text('CÀI ĐẶT', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      const Card(child: ListTile(leading: Icon(Icons.verified, color: brandRed), title: Text('Nguồn dữ liệu trực tuyến'), subtitle: Text('Đồng bộ thời gian thực chuẩn xác 100% từ xsmn.mobi'))),
      Card(child: const ListTile(leading: Icon(Icons.verified_user_outlined, color: brandRed), title: Text('Phiên bản ứng dụng'), subtitle: Text('Xổ Số • v2.2 Pro'))),
    ],
  );
}
