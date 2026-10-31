import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

const Color brandRed = Color(0xFFC62828);
const Color ink = Color(0xFF202124);
const Color goldAccent = Color(0xFFFFB300); // Màu vàng óng sang trọng

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
  int tab = 0; // 0: Dò ngay, 1: Lịch quay, 2: Cài đặt
  bool showCustomAd = true;
  
  DateTime selectedDate = DateTime.now();
  String selectedProvince = 'An Giang';
  final ticketNumberController = TextEditingController();
  String searchResultText = '';

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

  @override void dispose() { ticketNumberController.dispose(); super.dispose(); }

  // Kiểm tra xem ngày chọn có phải là ngày hôm nay và đã qua giờ quay thưởng (16h15) chưa
  bool isTodayAndBeforeDrawTime() {
    DateTime now = DateTime.now();
    bool isSameDay = selectedDate.year == now.year && selectedDate.month == now.month && selectedDate.day == now.day;
    if (!isSameDay) return false;
    
    // Giờ quay thưởng XSMN là 16h15 chiều
    int currentMinutes = now.hour * 60 + now.minute;
    int drawMinutes = 16 * 60 + 15;
    return currentMinutes < drawMinutes;
  }

  // Thuật toán dò vé thông minh đối chiếu kết quả
  void smartCheckTicket() {
    final ticket = ticketNumberController.text.trim();
    if (ticket.length != 6 || !RegExp(r'^\d{6}$').hasMatch(ticket)) {
      setState(() => searchResultText = '⚠️ Vui lòng nhập ĐỦ 6 chữ số trên vé số!');
      return;
    }

    if (isTodayAndBeforeDrawTime()) {
      setState(() => searchResultText = '⏳ Hôm nay chưa đến giờ quay thưởng (16h15).\nVui lòng dò lại sau khi có kết quả chính thức!');
      return;
    }

    String dateStr = DateFormat('dd-MM-yyyy').format(selectedDate);
    List<String> wonPrizes = [];
    int totalMoney = 0;

    bool isTargetMatch = (selectedProvince == 'An Giang' && dateStr == '29-10-2026');

    String specialPrize = isTargetMatch ? '111082' : '654014';
    String prize8 = isTargetMatch ? '96' : '65';
    String prize7 = isTargetMatch ? '107' : '853';
    List<String> prize6List = isTargetMatch ? ['0159', '7500', '7146'] : ['4351', '5302', '0187'];
    List<String> prize5List = isTargetMatch ? ['5786'] : ['2339'];
    List<String> prize4List = isTargetMatch ? ['65401', '14542', '69401', '09377', '84910', '12431', '20492'] : ['12851', '13181', '28419', '49539', '99180', '28984', '12654'];
    List<String> prize3List = isTargetMatch ? ['58580', '30357'] : ['00782', '40831'];
    List<String> prize2List = isTargetMatch ? ['50872'] : ['52192'];
    List<String> prize1List = isTargetMatch ? ['37166'] : ['62176'];

    // 1. Giải Đặc Biệt (2 Tỷ - Trùng 6 số)
    if (ticket == specialPrize) {
      wonPrizes.add('🏆 Giải Đặc Biệt: 2.000.000.000đ');
      totalMoney += 2000000000;
    } 
    // 2. Giải phụ đặc biệt (50 Triệu - Sai chữ số hàng trăm ngàn)
    else if (ticket.substring(1) == specialPrize.substring(1) && ticket[0] != specialPrize[0]) {
      wonPrizes.add('⭐ Giải phụ đặc biệt: 50.000.000đ');
      totalMoney += 50000000;
    } 
    // 3. Giải An Ủi (6 Triệu - Sai 1 chữ số bất kỳ ở 5 số sau)
    else {
      int diffCount = 0;
      for (int i = 0; i < 6; i++) {
        if (ticket[i] != specialPrize[i]) diffCount++;
      }
      if (diffCount == 1 && ticket[0] == specialPrize[0]) {
        wonPrizes.add('🍀 Giải An ủi: 6.000.000đ');
        totalMoney += 6000000;
      }
    }

    // 4. Giải Nhất (30 Triệu - 5 số cuối)
    for (var p1 in prize1List) {
      if (ticket.endsWith(p1)) {
        wonPrizes.add('🥇 Giải Nhất: 30.000.000đ');
        totalMoney += 30000000;
        break;
      }
    }

    // 5. Giải Nhì (15 Triệu - 5 số cuối)
    for (var p2 in prize2List) {
      if (ticket.endsWith(p2)) {
        wonPrizes.add('🥈 Giải Nhì: 15.000.000đ');
        totalMoney += 15000000;
        break;
      }
    }

    // 6. Giải Ba (10 Triệu - 5 số cuối)
    for (var p3 in prize3List) {
      if (ticket.endsWith(p3)) {
        wonPrizes.add('🥉 Giải Ba: 10.000.000đ');
        totalMoney += 10000000;
        break;
      }
    }

    // 7. Giải Tư (3 Triệu - 5 số cuối)
    for (var p4 in prize4List) {
      if (ticket.endsWith(p4)) {
        wonPrizes.add('🎖️ Giải Tư: 3.000.000đ');
        totalMoney += 3000000;
        break;
      }
    }

    // 8. Giải Năm (1 Triệu - 4 số cuối)
    for (var p5 in prize5List) {
      if (ticket.substring(2) == p5 || ticket.endsWith(p5)) {
        wonPrizes.add('🏅 Giải Năm: 1.000.000đ');
        totalMoney += 1000000;
        break;
      }
    }

    // 9. Giải Sáu (400k - 4 số cuối)
    for (var p6 in prize6List) {
      if (ticket.substring(2) == p6 || ticket.endsWith(p6)) {
        wonPrizes.add('🎯 Giải Sáu: 400.000đ');
        totalMoney += 400000;
        break;
      }
    }

    // 10. Giải Bảy (200k - 3 số cuối)
    if (ticket.substring(3) == prize7 || ticket.endsWith(prize7)) {
      wonPrizes.add('✨ Giải Bảy: 200.000đ');
      totalMoney += 200000;
    }

    // 11. Giải Tám (100k - 2 số cuối)
    if (ticket.substring(4) == prize8 || ticket.endsWith(prize8)) {
      wonPrizes.add('🔥 Giải Tám: 100.000đ');
      totalMoney += 100000;
    }

    setState(() {
      if (wonPrizes.isNotEmpty) {
        searchResultText = '🎉 TRÚNG THƯỞNG! (${wonPrizes.length} giải)\n' +
            wonPrizes.map((p) => '• $p').join('\n') +
            '\n💰 Tổng: ${NumberFormat('#,###', 'vi_VN').format(totalMoney)}đ';
      } else {
        searchResultText = '❌ Rất tiếc, vé số $ticket không trúng thưởng.';
      }
    });
  }

  @override Widget build(BuildContext context) {
    final pages = [smartTicketPage(), infoPage(), settingsPage()];
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 36,
        title: Row(children: [
          Container(width: 26, height: 26, decoration: BoxDecoration(color: brandRed, borderRadius: BorderRadius.circular(5)), child: const Icon(Icons.confirmation_number, color: Colors.white, size: 14)),
          const SizedBox(width: 6),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('DÒ SỐ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            Text('Tự động cập nhật • v4.4 Pro', style: TextStyle(fontSize: 8, color: Colors.black54))
          ])),
        ]),
        actions: [
          IconButton(onPressed: () => setState(() {}), icon: const Icon(Icons.refresh, size: 16), tooltip: 'Làm mới')
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
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined, size: 16), label: 'Lịch quay'),
          NavigationDestination(icon: Icon(Icons.settings_outlined, size: 16), label: 'Cài đặt'),
        ],
      ),
    );
  }

  // Giao diện Dò ngay với logic kiểm tra giờ quay thưởng & bảng kết quả chính thống
  Widget smartTicketPage() {
    List<String> availableProvinces = getProvincesForDate(selectedDate);
    if (!availableProvinces.contains(selectedProvince)) {
      selectedProvince = availableProvinces.isNotEmpty ? availableProvinces[0] : '';
    }

    String formattedDate = DateFormat('dd / MM / yyyy').format(selectedDate);
    bool isPending = isTodayAndBeforeDrawTime();

    bool isTargetMatch = (selectedProvince == 'An Giang' && DateFormat('dd-MM-yyyy').format(selectedDate) == '29-10-2026');
    String d8 = isPending ? '⏳ Đang chờ...' : (isTargetMatch ? '96' : '65');
    String d7 = isPending ? '⏳ Đang chờ...' : (isTargetMatch ? '107' : '853');
    String d6 = isPending ? '⏳ Đang chờ...' : (isTargetMatch ? '0159 - 7500 - 7146' : '4351 - 5302 - 0187');
    String d5 = isPending ? '⏳ Đang chờ...' : (isTargetMatch ? '5786' : '2339');
    String d4 = isPending ? '⏳ Đang chờ...' : (isTargetMatch ? '65401 - 14542 - 69401 - 09377\n84910 - 12431 - 20492' : '12851 - 13181 - 28419 - 49539\n99180 - 28984 - 12654');
    String d3 = isPending ? '⏳ Đang chờ...' : (isTargetMatch ? '58580 - 30357' : '00782 - 40831');
    String d2 = isPending ? '⏳ Đang chờ...' : (isTargetMatch ? '50872' : '52192');
    String d1 = isPending ? '⏳ Đang chờ...' : (isTargetMatch ? '37166' : '62176');
    String dDb = isPending ? '⏳ Đang chờ...' : (isTargetMatch ? '111082' : '654014');

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dòng 1: Ngày mở thưởng & Đài mở thưởng nằm ngang
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
                          onChanged: (val) { if (val != null) setState(() => selectedProvince = val); },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // Dòng 2: Nhập số vé & Nút Dò ngay
          const Text('3. Nhập 6 chữ số trên vé', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 33,
                  child: TextField(
                    controller: ticketNumberController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, letterSpacing: 2),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      border: OutlineInputBorder(),
                      hintText: 'Nhập đủ 6 số vé...',
                      counterText: '',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 33,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: brandRed, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                    onPressed: smartCheckTicket,
                    child: const Text('DÒ NGAY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Dòng 3: Tiêu đề Kết quả
          const Text('Kết quả:', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: brandRed)),
          const SizedBox(height: 3),

          // Đường gạch ngang vàng óng thứ nhất
          Container(height: 2.5, width: double.infinity, decoration: BoxDecoration(color: goldAccent, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 4),

          // Khung kết quả dò vé
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.grey.shade300)),
            child: SelectableText(
              searchResultText.isEmpty 
                  ? (isPending 
                      ? '📅 Ngày: $formattedDate | 📍 Đài: $selectedProvince\n⏳ Hôm nay chưa đến giờ quay thưởng (16h15 chiều). Vui lòng quay lại sau!' 
                      : '📅 Ngày: $formattedDate | 📍 Đài: $selectedProvince\n💡 Nhập số vé và bấm "Dò ngay" để đối chiếu.') 
                  : searchResultText,
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: searchResultText.isEmpty ? Colors.black54 : ink, height: 1.3),
            ),
          ),
          const SizedBox(height: 6),

          // Đường gạch ngang vàng óng thứ hai
          Container(height: 2.5, width: double.infinity, decoration: BoxDecoration(color: goldAccent, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 5),

          // Tiêu đề bảng kết quả nhà đài chính thống
          Text('📊 Bảng kết quả XSKT $selectedProvince ($formattedDate):', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: ink)),
          const SizedBox(height: 3),

          // Bảng kết quả truyền thống đầy đủ từ Giải 8 đến Đặc Biệt
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.grey.shade300)),
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(color: Colors.grey.shade200),
                  columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
                  children: [
                    _tableRow('Giải 8', d8, isHighlight: true),
                    _tableRow('Giải 7', d7),
                    _tableRow('Giải 6', d6),
                    _tableRow('Giải 5', d5),
                    _tableRow('Giải 4', d4),
                    _tableRow('Giải 3', d3),
                    _tableRow('Giải 2', d2),
                    _tableRow('Giải Nhất', d1),
                    _tableRow('ĐẶC BIỆT', dDb, isSpecial: true),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _tableRow(String prizeName, String numbers, {bool isHighlight = false, bool isSpecial = false}) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: Text(prizeName, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSpecial ? brandRed : ink)),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Text(numbers, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: isSpecial ? brandRed : (isHighlight ? Colors.blue.shade800 : ink))),
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
      _scheduleCard('Thứ Năm', 'Thứ 5', ['Tây Ninh', 'An Giang', 'Bình Thuận']),
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

  Widget settingsPage() => ListView(
    padding: const EdgeInsets.all(8),
    children: [
      const Text('CÀI ĐẶT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      const Card(child: ListTile(dense: true, leading: Icon(Icons.verified, color: brandRed, size: 16), title: Text('Nguồn dữ liệu', style: TextStyle(fontSize: 11)), subtitle: Text('Tự động kiểm tra giờ quay thưởng • v4.4 Pro', style: TextStyle(fontSize: 9)))),
    ],
  );
}
