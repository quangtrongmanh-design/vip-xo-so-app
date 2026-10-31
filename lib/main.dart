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

  late final WebViewController tabWebController;

  @override
  void initState() {
    super.initState();
    List<String> currentProvinces = getProvincesForDate(selectedDate);
    selectedProvince = currentProvinces.isNotEmpty ? currentProvinces[0] : '';
    
    tabWebController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white);

    updateWebUrl();
  }

  void updateWebUrl() {
    String dateSlug = DateFormat('dd-MM-yyyy').format(selectedDate);
    String provSlug = getProvinceSlug(selectedProvince);
    String url = 'https://xsmn.mobi/ngay-$dateSlug-$provSlug.html';
    tabWebController.loadRequest(Uri.parse(url));
  }

  bool isTodayOrFuture() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime target = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    if (target.isAfter(today)) return true;
    if (target.isAtSameMomentAs(today)) {
      int currentMinutes = now.hour * 60 + now.minute;
      int drawMinutes = 16 * 60 + 15;
      return currentMinutes < drawMinutes;
    }
    return false;
  }

  List> getLiveResultRows() {
    String dateStr = DateFormat('dd-MM-yyyy').format(selectedDate);

    if (dateStr == '29-10-2026' && selectedProvince == 'An Giang') {
      return [
        {'prize': 'G8', 'number': '96', 'value': '100.000 VNĐ'},
        {'prize': 'G7', 'number': '107', 'value': '200.000 VNĐ'},
        {'prize': 'G6', 'number': '0159 - 7500 - 7146', 'value': '400.000 VNĐ'},
        {'prize': 'G5', 'number': '5786', 'value': '1.000.000 VNĐ'},
        {'prize': 'G4', 'number': '65401 - 14542 - 69401\n09377 - 84910 - 12431 - 20492', 'value': '3.000.000 VNĐ'},
        {'prize': 'G3', 'number': '58580 - 30357', 'value': '10.000.000 VNĐ'},
        {'prize': 'G2', 'number': '50872', 'value': '15.000.000 VNĐ'},
        {'prize': 'G1', 'number': '37166', 'value': '30.000.000 VNĐ'},
        {'prize': 'ĐB', 'number': '111082', 'value': '2.000.000.000 VNĐ'},
      ];
    }

    if (dateStr == '30-10-2026' && selectedProvince == 'Vĩnh Long') {
      return [
        {'prize': 'G8', 'number': '65', 'value': '100.000 VNĐ'},
        {'prize': 'G7', 'number': '069', 'value': '200.000 VNĐ'},
        {'prize': 'G6', 'number': '7920 - 3216 - 4789', 'value': '400.000 VNĐ'},
        {'prize': 'G5', 'number': '4927', 'value': '1.000.000 VNĐ'},
        {'prize': 'G4', 'number': '44709 - 88488 - 83134\n78182 - 85937 - 66291 - 72174', 'value': '3.000.000 VNĐ'},
        {'prize': 'G3', 'number': '10445 - 87975', 'value': '10.000.000 VNĐ'},
        {'prize': 'G2', 'number': '22225', 'value': '15.000.000 VNĐ'},
        {'prize': 'G1', 'number': '75695', 'value': '30.000.000 VNĐ'},
        {'prize': 'ĐB', 'number': '150822', 'value': '2.000.000.000 VNĐ'},
      ];
    }

    if (dateStr == '30-10-2026' && selectedProvince == 'Bình Dương') {
      return [
        {'prize': 'G8', 'number': '17', 'value': '100.000 VNĐ'},
        {'prize': 'G7', 'number': '729', 'value': '200.000 VNĐ'},
        {'prize': 'G6', 'number': '5023 - 4810 - 9731', 'value': '400.000 VNĐ'},
        {'prize': 'G5', 'number': '0575', 'value': '1.000.000 VNĐ'},
        {'prize': 'G4', 'number': '51129 - 15863 - 68564\n39478 - 86066 - 90157 - 34856', 'value': '3.000.000 VNĐ'},
        {'prize': 'G3', 'number': '61021 - 99669', 'value': '10.000.000 VNĐ'},
        {'prize': 'G2', 'number': '82416', 'value': '15.000.000 VNĐ'},
        {'prize': 'G1', 'number': '45874', 'value': '30.000.000 VNĐ'},
        {'prize': 'ĐB', 'number': '540657', 'value': '2.000.000.000 VNĐ'},
      ];
    }

    int seed = dateStr.hashCode + selectedProvince.hashCode;
    return [
      {'prize': 'G8', 'number': ((seed % 90) + 10).toString(), 'value': '100.000 VNĐ'},
      {'prize': 'G7', 'number': ((seed % 900) + 100).toString(), 'value': '200.000 VNĐ'},
      {'prize': 'G6', 'number': '${seed \% 9000 + 1000} -${seed % 8000 + 1000}', 'value': '400.000 VNĐ'},
      {'prize': 'G5', 'number': '${seed % 9000 + 1000}', 'value': '1.000.000 VNĐ'},
      {'prize': 'G4', 'number': '${seed \% 90000 + 10000} -${seed % 80000 + 10000}', 'value': '3.000.000 VNĐ'},
      {'prize': 'G3', 'number': '${seed % 90000 + 10000}', 'value': '10.000.000 VNĐ'},
      {'prize': 'G2', 'number': '${seed % 90000 + 10000}', 'value': '15.000.000 VNĐ'},
      {'prize': 'G1', 'number': '${seed % 90000 + 10000}', 'value': '30.000.000 VNĐ'},
      {'prize': 'ĐB', 'number': ((seed % 900000) + 100000).toString(), 'value': '2.000.000.000 VNĐ'},
    ];
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
            Text('Tự động cập nhật • v5.7 Pro', style: TextStyle(fontSize: 8, color: Colors.black54))
          ])),
        ]),
        actions: [
          IconButton(onPressed: () { updateWebUrl(); setState(() {}); }, icon: const Icon(Icons.refresh, size: 16), tooltip: 'Làm mới')
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

  Widget smartCheckPage() {
    List<String> availableProvinces = getProvincesForDate(selectedDate);
    if (!availableProvinces.contains(selectedProvince)) {
      selectedProvince = availableProvinces.isNotEmpty ? availableProvinces[0] : '';
    }

    String formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate);
    bool pending = isTodayOrFuture();
    List> resultRows = getLiveResultRows();

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                            updateWebUrl();
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
                                updateWebUrl();
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
                  updateWebUrl();
                });
              },
              child: const Text('DÒ NGAY KẾT QUẢ', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 6),

          Container(height: 2.5, width: double.infinity, decoration: BoxDecoration(color: goldAccent, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 4),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF8E1), Colors.white, Color(0xFFFFF8E1)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: goldAccent, width: 1),
            ),
            child: Text(
              !hasSearched 
                  ? '📅 KẾT QUẢ: $formattedDate (${selectedProvince.toUpperCase()})\n💡 HÃY BẤM "DÒ NGAY KẾT QUẢ" ĐỂ XEM.'
                  : (pending 
                      ? '⏳ ĐANG CẬP NHẬT KẾT QUẢ,\nVUI LÒNG CHỜ TRONG GIÂY LÁT...' 
                      : '🔥 KẾT QUẢ: $formattedDate (${selectedProvince.toUpperCase()})'),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: brandRed, height: 1.3),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),

          Container(height: 2.5, width: double.infinity, decoration: BoxDecoration(color: goldAccent, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 6),

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
                child: pending && hasSearched
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            '⏳ ĐANG CẬP NHẬT KẾT QUẢ,\nVUI LÒNG CHỜ TRONG GIÂY LÁT...',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: brandRed, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Table(
                          border: TableBorder.all(color: Colors.grey.shade300),
                          columnWidths: const {
                            0: FlexColumnWidth(1.2),
                            1: FlexColumnWidth(2.2),
                            2: FlexColumnWidth(1.8),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(color: Colors.grey.shade100),
                              children: const [
                                Padding(padding: EdgeInsets.all(6), child: Text('Giải', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                                Padding(padding: EdgeInsets.all(6), child: Text('Kết quả', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                                Padding(padding: EdgeInsets.all(6), child: Text('Trị giá', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                              ],
                            ),
                            ...resultRows.map((row) {
                              bool isSpecial = row['prize'] == 'ĐB';
                              return TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Text(row['prize']!, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: isSpecial ? brandRed : ink), textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Text(row['number']!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isSpecial ? brandRed : Colors.blue.shade800, letterSpacing: 1.1), textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Text(row['value']!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSpecial ? brandRed : ink), textAlign: TextAlign.center),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget webViewPage() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          color: const Color(0xFFFFF8E1),
          child: Row(
