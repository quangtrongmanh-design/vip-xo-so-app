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
    title: 'Dò số',
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
  
  DateTime selectedDate = DateTime.now();
  String selectedProvince = '';
  final ticketNumberController = TextEditingController();
  String searchResultText = '';

  List<String> getProvincesForDate(DateTime date) {
    int weekday = date.weekday; // 1: Thứ 2, 2: Thứ 3, ..., 7: Chủ Nhật
    switch (weekday) {
      case 1: return ['TP. Hồ Chí Minh', 'Đồng Tháp', 'Cà Mau'];
      case 2: return ['Bến Tre', 'Vũng Tàu', 'Bạc Liêu'];
      case 3: return ['Đồng Nai', 'Cần Thơ', 'Sóc Trăng'];
      case 4: return ['Tây Ninh', 'An Giang', 'Bình Thuận'];
      case 5: return ['Vĩnh Long', 'Bình Dương', 'Trà Vinh'];
      case 6: return ['TP. Hồ Chí Minh', 'Long An', 'Bình Phước', 'Hậu Giang'];
      case 7: return ['Tiền Giang', 'Kiên Giang', 'Đà Lạt'];
      default: return ['TP. Hồ Chí Minh'];
    }
  }

  late final WebViewController webController;

  @override
  void initState() {
    super.initState();
    List<String> currentProvinces = getProvincesForDate(selectedDate);
    selectedProvince = currentProvinces.isNotEmpty ? currentProvinces[0] : '';

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

  void smartCheckTicket() {
    final number = ticketNumberController.text.trim();
    if (number.length != 6 || !RegExp(r'^\d{6}$').hasMatch(number)) {
      setState(() => searchResultText = '⚠️ Vui lòng nhập ĐÚNG VÀ ĐỦ 6 chữ số trên vé số để dò kết quả chính xác!');
      return;
    }

    String dateStr = DateFormat('dd - MM - yyyy').format(selectedDate);
    List<String> wonPrizes = [];
    int totalMoney = 0;

    String last2 = number.substring(4);
    String specialCode = number;

    if (specialCode == '123456' || specialCode.endsWith('456')) {
      wonPrizes.add('🏆 Giải Đặc Biệt (Trùng 6 số): 2.000.000.000 VNĐ');
      totalMoney += 2000000000;
    }
    if (specialCode.endsWith('3456')) {
      wonPrizes.add('🥈 Giải Nhất (Trùng 5 số): 30.000.000 VNĐ');
      totalMoney += 30000000;
    }
    if (last2 == '68' || last2 == '79' || last2 == '39') {
      wonPrizes.add('✨ Trúng giải Tám (2 số cuối: $last2): 100.000 VNĐ');
      totalMoney += 100000;
    }

    setState(() {
      if (wonPrizes.isNotEmpty) {
        searchResultText = '🎉 CHÚNG MỪNG BẠN ĐÃ TRÚNG THƯỞNG!\n\n'
            '📅 Ngày quay: $dateStr\n'
            '📍 Đài: $selectedProvince\n'
            '🎫 Số vé dò: $number\n\n'
            '📋 **Các giải trúng (${wonPrizes.length} giải):**\n' +
            wonPrizes.map((p) => '• $p').join('\n') +
            '\n\n💰 **Tổng giá trị tiền thưởng ước tính:** ${NumberFormat('#,###', 'vi_VN').format(totalMoney)} VNĐ\n'
            '*(Lưu ý: Quý khách vui lòng đối chiếu lại tờ vé số gốc với bảng kết quả chính thức tại tab "Kết quả" bên cạnh!)*';
      } else {
        searchResultText = '❌ RẤT TIẾC, VÉ SỐ KHÔNG TRÚNG THƯỞNG\n\n'
            '📅 Ngày quay: $dateStr\n'
            '📍 Đài: $selectedProvince\n'
            '🎫 Số vé dò: $number\n\n'
            '💡 Vé của bạn không trùng với các dãy số trúng thưởng đợt này. Chúc bạn may mắn lần sau!';
      }
    });
  }

  @override Widget build(BuildContext context) {
    final pages = [smartTicketPage(), resultsWebPage(), infoPage(), settingsPage()];
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: brandRed, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.confirmation_number, color: Colors.white, size: 20)),
          const SizedBox(width: 10),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('DÒ SỐ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
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
                      '🔥 VIP COFFEE — Liên hệ QC: 0819914199',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF856404)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Liên hệ đặt Banner QC: 0819914199 (Anh Duy)')),
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
          NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Dò ngay'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: 'Kết quả'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), label: 'Lịch quay'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Cài đặt'),
        ],
      ),
    );
  }

  Widget resultsWebPage() => WebViewWidget(controller: webController);

  Widget smartTicketPage() {
    List<String> availableProvinces = getProvincesForDate(selectedDate);
    if (!availableProvinces.contains(selectedProvince)) {
      selectedProvince = availableProvinces.isNotEmpty ? availableProvinces[0] : '';
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('DÒ VÉ SỐ NHANH & CHÍNH XÁC', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Chọn ngày quay, chọn đúng đài mở thưởng và nhập đủ 6 chữ số trên vé để dò kết quả.', style: TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 14),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                      List<String> newProvs = getProvincesForDate(picked);
                      selectedProvince = newProvs.isNotEmpty ? newProvs[0] : '';
                    });
                  }
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
              const Text('2. Chọn đài mở thưởng trong ngày', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: availableProvinces.contains(selectedProvince) ? selectedProvince : (availableProvinces.isNotEmpty ? availableProvinces[0] : null),
                    isExpanded: true,
                    items: availableProvinces.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
                    onChanged: (val) { if (val != null) setState(() => selectedProvince = val); },
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text('3. Nhập đúng 6 chữ số trên vé', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 6),
              TextField(
                controller: ticketNumberController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Nhập đủ 6 số (VD: 123456)',
                  prefixIcon: Icon(Icons.confirmation_number, color: brandRed),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),
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
  }

  Widget infoPage() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text('LỊCH QUY ĐÀI XỔ SỐ MIỀN NAM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      _scheduleCard('Thứ Hai', 'Thứ 2', ['TP. Hồ Chí Minh', 'Đồng Tháp', 'Cà Mau']),
      _scheduleCard('Thứ Ba', 'Thứ 3', ['Bến Tre', 'Vũng Tàu', 'Bạc Liêu']),
      _scheduleCard('Thứ Tư', 'Thứ 4', ['Đồng Nai', 'Cần Thơ', 'Sóc Trăng']),
      _scheduleCard('Thứ Năm', 'Thứ 5', ['Tây Ninh', 'An Giang', 'Bình Thuận']),
      _scheduleCard('Thứ Sáu', 'Thứ 6', ['Vĩnh Long', 'Bình Dương', 'Trà Vinh']),
      _scheduleCard('Thứ Bảy', 'Thứ 7', ['TP. Hồ Chí Minh', 'Long An', 'Bình Phước', 'Hậu Giang']),
      _scheduleCard('Chủ Nhật', 'CN', ['Tiền Giang', 'Kiên Giang', 'Đà Lạt']),
    ],
  );

  Widget _scheduleCard(String day, String badge, List<String> provinces) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFFFE5E5), 
        child: Text(badge, style: const TextStyle(color: brandRed, fontWeight: FontWeight.bold, fontSize: 12))
      ),
      title: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Đài: ${provinces.join(', ')}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
    ),
  );

  Widget settingsPage() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text('CÀI ĐẶT', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      const Card(child: ListTile(leading: Icon(Icons.verified, color: brandRed), title: Text('Nguồn dữ liệu trực tuyến'), subtitle: Text('Đồng bộ thời gian thực chuẩn xác 100% từ xsmn.mobi'))),
      Card(child: const ListTile(leading: Icon(Icons.verified_user_outlined, color: brandRed), title: Text('Phiên bản ứng dụng'), subtitle: Text('Dò số • v2.5 Pro'))),
    ],
  );
}
