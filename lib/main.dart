import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

const Color brandRed = Color(0xFFC62828);
const Color ink = Color(0xFF202124);
const Color goldAccent = Color(0xFFFFB300);

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
  int tab = 0; // 0: Dò ngay, 1: Trực tiếp Web, 2: Lịch quay
  bool showCustomAd = true;
  
  DateTime selectedDate = DateTime.now();
  String selectedProvince = 'An Giang';
  bool hasSearched = false;

  List<String> getProvincesForDate(DateTime date) {
    int weekday = date.weekday;
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

  String getProvinceSlug(String province) {
    switch (province) {
      case 'TP. Hồ Chí Minh': return 'tp-hcm';
      case 'Đồng Tháp': return 'dong-thap';
      case 'Cà Mau': return 'ca-mau';
      case 'Bến Tre': return 'ben-tre';
      case 'Vũng Tàu': return 'vung-tau';
      case 'Bạc Liêu': return 'bac-lieu';
      case 'Đồng Nai': return 'dong-nai';
      case 'Cần Thơ': return 'can-tho';
      case 'Sóc Trăng': return 'soc-trang';
      case 'Tây Ninh': return 'tay-ninh';
      case 'An Giang': return 'an-giang';
      case 'Bình Thuận': return 'binh-thuan';
      case 'Vĩnh Long': return 'vinh-long';
      case 'Bình Dương': return 'binh-duong';
      case 'Trà Vinh': return 'tra-vinh';
      case 'Long An': return 'long-an';
      case 'Bình Phước': return 'binh-phuoc';
      case 'Hậu Giang': return 'hau-giang';
      case 'Tiền Giang': return 'tien-giang';
      case 'Kiên Giang': return 'kien-giang';
      case 'Đà Lạt': return 'da-lat';
      default: return 'an-giang';
    }
  }

  late final WebViewController webController;
  late final WebViewController tabWebController;

  @override
  void initState() {
    super.initState();
    List<String> currentProvinces = getProvincesForDate(selectedDate);
    selectedProvince = currentProvinces.isNotEmpty ? currentProvinces[0] : '';
    
    webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white);

    tabWebController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white);

    updateWebUrls();
  }

  void updateWebUrls() {
    String dateSlug = DateFormat('dd-MM-yyyy').format(selectedDate);
    String provSlug = getProvinceSlug(selectedProvince);
    String url = 'https://xsmn.mobi/ngay-$dateSlug-$provSlug.html';
    webController.loadRequest(Uri.parse(url));
    tabWebController.loadRequest(Uri.parse(url));
  }

  @override Widget build(BuildContext context) {
    final pages = [smartCheckPage(), webViewPage(), infoPage()];
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 36,
        title: Row(children: [
          Container(width: 26, height: 26, decoration: BoxDecoration(color: brandRed, borderRadius: BorderRadius.circular(5)), child: const Icon(Icons.confirmation_number, color: Colors.white, size: 14)),
          const SizedBox(width: 6),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('DÒ SỐ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            Text('Tự động cập nhật • v5.3 Pro', style: TextStyle(fontSize: 8, color: Colors.black54))
          ])),
        ]),
        actions: [
          IconButton(onPressed: () { updateWebUrls(); setState(() {}); }, icon: const Icon(Icons.refresh, size: 16), tooltip: 'Làm mới')
        ],
      ),
      body: Column(
        children: [
          if (showCustomAd)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3CD),
                border: Border(bottom: BorderSide(color: Color(0xFFFFEEBA), width: 1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.campaign, color: brandRed, size: 14),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      '🔥 VIP COFFEE — Liên hệ QC: 0819914199',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF856404)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Liên hệ QC: 0819914199')));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: brandRed, borderRadius: BorderRadius.circular(3)),
                      child: const Text('LIÊN HỆ', style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => setState(() => showCustomAd = false),
                    child: const Icon(Icons.close, size: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          Expanded(child: pages[tab]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 48,
        selectedIndex: tab > 2 ? 0 : tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search_outlined, size: 16), selectedIcon: Icon(Icons.search, size: 16), label: 'Dò ngay'),
          NavigationDestination(icon: Icon(Icons.public_outlined, size: 16), selectedIcon: Icon(Icons.public, size: 16), label: 'Trực tiếp Web'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined, size: 16), label: 'Lịch quay'),
        ],
      ),
    );
  }

  // TAB 1: DÒ NGAY (Đã bỏ nhập số vé, tối ưu gọn gàng 1 màn hình)
  Widget smartCheckPage() {
    List<String> availableProvinces = getProvincesForDate(selectedDate);
    if (!availableProvinces.contains(selectedProvince)) {
      selectedProvince = availableProvinces.isNotEmpty ? availableProvinces[0] : '';
    }

    String formattedDate = DateFormat('dd / MM / yyyy').format(selectedDate);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // DÒNG 1: Chọn Ngày và Đài mở thưởng
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('1. Ngày mở thưởng', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 2),
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
                            hasSearched = false;
                            updateWebUrls();
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('dd/MM/yyyy').format(selectedDate), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            const Icon(Icons.calendar_today, color: brandRed, size: 12),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('2. Đài mở thưởng', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 2),
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: availableProvinces.contains(selectedProvince) ? selectedProvince : (availableProvinces.isNotEmpty ? availableProvinces[0] : null),
                          isExpanded: true,
                          style: const TextStyle(fontSize: 11, color: ink, fontWeight: FontWeight.w600),
                          items: availableProvinces.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                          onChanged: (val) { 
                            if (val != null) {
                              setState(() {
                                selectedProvince = val;
                                hasSearched = false;
                                updateWebUrls();
                              });
                            } 
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // DÒNG 2: Nút DÒ NGAY
          SizedBox(
            width: double.infinity,
            height: 34,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: brandRed, 
                foregroundColor: Colors.white, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
              ),
              onPressed: () {
                setState(() {
                  hasSearched = true;
                  updateWebUrls();
                });
              },
              child: const Text('DÒ NGAY KẾT QUẢ', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 6),

          // Đường gạch vàng thứ nhất
          Container(height: 2.5, width: double.infinity, decoration: BoxDecoration(color: goldAccent, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 4),

          // Khung thông báo trạng thái
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE3F2FD), Colors.white, Color(0xFFE3F2FD)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF90CAF9), width: 1.5),
            ),
            child: Text(
              !hasSearched 
                  ? '📅 NGÀY: $formattedDate | 📍 ĐÀI: $selectedProvince\n💡 HÃY BẤM "DÒ NGAY KẾT QUẢ" ĐỂ XEM NHANH.' 
                  : '🔥 ĐANG HIỂN THỊ KẾT QUẢ CHÍNH THỐNG: $selectedProvince ($formattedDate)',
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: brandRed, height: 1.3),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),

          // Đường gạch vàng thứ hai
          Container(height: 2.5, width: double.infinity, decoration: BoxDecoration(color: goldAccent, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 5),

          Text('📊 Bảng kết quả XSKT $selectedProvince ($formattedDate):', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: ink)),
          const SizedBox(height: 3),

          // Khung hiển thị trực tiếp WebView thu gọn chuẩn xác không cần trượt
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(5), 
                border: Border.all(color: Colors.grey.shade300)
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: WebViewWidget(controller: webController),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 2: TRỰC TIẾP WEB
  Widget webViewPage() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          color: const Color(0xFFFFF8E1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.public, size: 14, color: brandRed),
              const SizedBox(width: 4),
              Text('Trang nhà đài trực tiếp: $selectedProvince (${DateFormat('dd/MM/yyyy').format(selectedDate)})', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: ink)),
            ],
          ),
        ),
        Expanded(
          child: WebViewWidget(controller: tabWebController),
        ),
      ],
    );
  }

  Widget infoPage() => ListView(
    padding: const EdgeInsets.all(8),
    children: [
      const Text('LỊCH QUY ĐÀI XỔ SỐ MIỀN NAM', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      _scheduleCard('Thứ Hai', 'Thứ 2', ['TP. Hồ Chí Minh', 'Đồng Tháp', 'Cà Mau']),
      _scheduleCard('Thứ Ba', 'Thứ 3', ['Bến Tre', 'Vũng Tàu', 'Bạc Liêu']),
      _scheduleCard('Thứ Tư', 'Thứ 4', ['Đồng Nai', 'Cần Thơ', 'Sóc Trăng']),
      _scheduleCard('Thứ Năm', 'Thứ 5', ['Tây Ninh', 'An Giang', ' Bình Thuận']),
      _scheduleCard('Thứ Sáu', 'Thứ 6', ['Vĩnh Long', 'Bình Dương', 'Trà Vinh']),
      _scheduleCard('Thứ Bảy', 'Thứ 7', ['TP. Hồ Chí Minh', 'Long An', 'Bình Phước', 'Hậu Giang']),
      _scheduleCard('Chủ Nhật', 'CN', ['Tiền Giang', 'Kiên Giang', 'Đà Lạt']),
    ],
  );

  Widget _scheduleCard(String day, String badge, List<String> provinces) => Card(
    margin: const EdgeInsets.only(bottom: 4),
    child: ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 12,
        backgroundColor: const Color(0xFFFFE5E5), 
        child: Text(badge, style: const TextStyle(color: brandRed, fontWeight: FontWeight.bold, fontSize: 9))
      ),
      title: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      subtitle: Text('Đài: ${provinces.join(', ')}', style: const TextStyle(fontSize: 9, color: Colors.black87)),
    ),
  );
}
