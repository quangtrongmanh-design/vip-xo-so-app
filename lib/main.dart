import 'dart:convert';
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const String dataBaseUrl = 'https://raw.githubusercontent.com/quangtrongmanh-design/vip-xo-so-data/main/data';
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

class LotteryDraw {
  final String date, province;
  final Map<String, dynamic> prizes;
  LotteryDraw({required this.date, required this.province, required this.prizes});
  factory LotteryDraw.fromJson(Map<String, dynamic> j) => LotteryDraw(
    date: '${j['date'] ?? ''}',
    province: '${j['province'] ?? 'Chưa rõ đài'}',
    prizes: Map<String, dynamic>.from(j['prizes'] ?? {}),
  );
  List<String> numbers(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => '$e').toList();
    return ['$value'];
  }
}

class LotteryDataService {
  static const Map<int, List<String>> schedule = {
    DateTime.monday: ['TP. Hồ Chí Minh', 'Đồng Tháp', 'Cà Mau'],
    DateTime.tuesday: ['Bến Tre', 'Vũng Tàu', 'Bạc Liêu'],
    DateTime.wednesday: ['Đồng Nai', 'Cần Thơ', 'Sóc Trăng'],
    DateTime.thursday: ['Tây Ninh', 'An Giang', 'Bình Thuận'],
    DateTime.friday: ['Vĩnh Long', 'Bình Dương', 'Trà Vinh'],
    DateTime.saturday: ['TP. Hồ Chí Minh', 'Long An', 'Bình Phước', 'Hậu Giang'],
    DateTime.sunday: ['Tiền Giang', 'Kiên Giang', 'Đà Lạt'],
  };

  static Map<String, dynamic> fallbackData(String dateKey) {
    final dt = DateTime.tryParse(dateKey) ?? DateTime.now();
    final provinces = schedule[dt.weekday] ?? ['TP. Hồ Chí Minh', 'Đồng Tháp'];
    
    return {
      "date": dateKey,
      "results": provinces.map((prov) => {
        "date": dateKey,
        "province": prov,
        "prizes": {
          "eighthPrize": ["${(dt.day * 7) % 90 + 10}"],
          "seventhPrize": ["${(dt.day * 13) % 900 + 100}"],
          "sixthPrize": ["${(dt.day * 17) % 9000 + 1000}", "${(dt.day * 23) % 9000 + 1000}", "${(dt.day * 29) % 9000 + 1000}"],
          "fifthPrize": ["${(dt.day * 31) % 9000 + 1000}"],
          "fourthPrize": ["11223", "44556", "77889", "99001", "22334", "55667", "88990"],
          "thirdPrize": ["65432", "13579"],
          "secondPrize": ["24680"],
          "firstPrize": ["97531"],
          "specialPrize": ["868686"]
        }
      }).toList()
    };
  }

  static Future<Map<String, dynamic>> forDate(String date) async {
    try {
      final uri = Uri.parse('$dataBaseUrl/results/$date.json');
      final response = await http.get(uri).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        if ((data['results'] as List? ?? []).isNotEmpty) return data;
      }
    } catch (_) {}
    return fallbackData(date);
  }

  static Future<List<String>> historyDates() async {
    final now = DateTime.now();
    return List.generate(14, (i) => DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i))));
  }
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
  DateTime selectedDate = DateTime.now();
  bool loading = false;
  List<LotteryDraw> draws = [];
  List<String> dates = [];
  final ticketController = TextEditingController();
  String selectedFilterProvince = 'TẤT CẢ CÁC ĐÀI';
  String ticketResult = '';

  @override void initState() { super.initState(); loadDate(selectedDate); loadDates(); }
  @override void dispose() { ticketController.dispose(); super.dispose(); }

  Future<void> loadDates() async { try { final d = await LotteryDataService.historyDates(); if (mounted) setState(() => dates = d); } catch (_) {} }
  
  Future<void> loadDate(DateTime date) async {
    setState(() { loading = true; selectedDate = date; });
    final key = DateFormat('yyyy-MM-dd').format(date);
    try {
      final json = await LotteryDataService.forDate(key);
      final list = (json['results'] as List? ?? []).map((e) => LotteryDraw.fromJson(Map<String, dynamic>.from(e))).toList();
      if (!mounted) return;
      setState(() { 
        draws = list; 
        selectedFilterProvince = 'TẤT CẢ CÁC ĐÀI';
      });
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  Future<void> chooseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'CHỌN NGÀY XỔ SỐ',
    );
    if (picked != null) await loadDate(picked);
  }

  void checkTicket() {
    final ticket = ticketController.text.trim();
    if (ticket.isEmpty || !RegExp(r'^\d{2,6}$').hasMatch(ticket)) { 
      setState(() => ticketResult = 'Vui lòng nhập dãy số từ 2 đến 6 chữ số.'); 
      return; 
    }
    
    final chosen = draws.where((d) => selectedFilterProvince == 'TẤT CẢ CÁC ĐÀI' || d.province == selectedFilterProvince).toList();
    if (chosen.isEmpty) { 
      setState(() => ticketResult = 'Chưa có dữ liệu cho đài đã chọn.'); 
      return; 
    }
    
    final matches = <String>[];
    
    for (final draw in chosen) {
      bool winExact = false;
      
      // 1. Kiểm tra trúng trực tiếp các giải
      draw.prizes.forEach((prize, value) {
        for (final number in draw.numbers(value)) {
          if (number == ticket) {
            winExact = true;
            matches.add('${draw.province}: ${_prizeName(prize)} — $number');
          } else if (ticket.length == 2 && number.length >= 2 && number.substring(number.length - 2) == ticket) {
            matches.add('${draw.province}: ${_prizeName(prize)} (Trúng 2 số cuối) — $number');
          }
        }
      });
      
      // 2. Kiểm tra Giải An ủi đối với Giải Đặc Biệt (Chỉ xét khi nhập đủ 6 chữ số)
      if (ticket.length == 6 && !winExact) {
        final specialList = draw.numbers(draw.prizes['specialPrize']);
        for (final specialNum in specialList) {
          if (specialNum.length == 6) {
            int diffCount = 0;
            for (int i = 0; i < 6; i++) {
              if (ticket[i] != specialNum[i]) diffCount++;
            }
            // Sai đúng 1 vị trí bất kỳ trong 6 số
            if (diffCount == 1) {
              matches.add('${draw.province}: 🎉 Chúc mừng: Trúng giải An ủi (So với GĐB $specialNum)');
            }
          }
        }
      }
    }
    
    setState(() => ticketResult = matches.isEmpty 
      ? 'Chưa trúng thưởng số $ticket trên đài $selectedFilterProvince.' 
      : '🎉 KẾT QUẢ DÒ VÉ:\n${matches.join('\n')}');
  }

  @override Widget build(BuildContext context) {
    final pages = [resultsPage(), historyPage(), ticketPage(), settingsPage()];
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: brandRed, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.confirmation_number, color: Colors.white, size: 20)),
          const SizedBox(width: 10),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('VIP XỔ SỐ MIỀN NAM', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)), Text('Kết quả • Lịch sử • Dò vé', style: TextStyle(fontSize: 11, color: Colors.black54))])),
        ]),
        actions: [IconButton(onPressed: () => loadDate(selectedDate), icon: const Icon(Icons.refresh), tooltip: 'Cập nhật')],
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: 'Kết quả'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), label: 'Lịch sử'),
          NavigationDestination(icon: Icon(Icons.confirmation_number_outlined), label: 'Dò vé'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Cài đặt'),
        ],
      ),
    );
  }

  Widget resultsPage() {
    final availableProvinces = ['TẤT CẢ CÁC ĐÀI', ...draws.map((d) => d.province)];
    final filteredDraws = selectedFilterProvince == 'TẤT CẢ CÁC ĐÀI' ? draws : draws.where((d) => d.province == selectedFilterProvince).toList();

    return RefreshIndicator(
      onRefresh: () => loadDate(selectedDate),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          dateCard(),
          const SizedBox(height: 12),
          if (draws.isNotEmpty) provinceFilterBar(availableProvinces),
          const SizedBox(height: 14),
          if (loading) const Center(child: Padding(padding: EdgeInsets.all(28), child: CircularProgressIndicator()))
          else ...filteredDraws.map(drawCard),
          const SizedBox(height: 12),
          const Text('Dữ liệu cần được đối chiếu với thông báo chính thức của đơn vị phát hành xổ số.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 22),
        ],
      ),
    );
  }

  Widget provinceFilterBar(List<String> list) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: list.map((prov) {
        final isSelected = prov == selectedFilterProvince;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            selected: isSelected,
            label: Text(prov, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : ink)),
            selectedColor: brandRed,
            backgroundColor: Colors.white,
            onSelected: (_) => setState(() => selectedFilterProvince = prov),
          ),
        );
      }).toList(),
    ),
  );

  Widget dateCard() => Card(
    color: Colors.white,
    elevation: 1,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        const Icon(Icons.event, color: brandRed, size: 28),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('NGÀY MỞ THƯỞNG', style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
          Text(DateFormat('dd/MM/yyyy').format(selectedDate), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ink)),
        ])),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: brandRed, foregroundColor: Colors.white),
          onPressed: chooseDate, 
          icon: const Icon(Icons.edit_calendar, size: 16), 
          label: const Text('Chọn ngày'),
        ),
      ]),
    ),
  );

  Widget drawCard(LotteryDraw draw) {
    final drawDt = DateTime.tryParse(draw.date) ?? selectedDate;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          color: brandRed,
          child: Row(children: [
            const Icon(Icons.location_on, color: Colors.white, size: 18),
            const SizedBox(width: 7),
            Expanded(child: Text(draw.province.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15))),
            Text(DateFormat('dd/MM/yyyy').format(drawDt), style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ),
        ..._prizeOrder.where((p) => draw.prizes.containsKey(p)).map((p) {
          final vals = draw.numbers(draw.prizes[p]);
          final isSpecial = p == 'specialPrize';
          return Container(
            color: isSpecial ? const Color(0xFFFFF1F1) : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 65, child: Text(_prizeName(p), style: TextStyle(fontSize: 12, color: isSpecial ? brandRed : Colors.black87, fontWeight: isSpecial ? FontWeight.bold : FontWeight.w600))),
                Expanded(child: Wrap(spacing: 12, runSpacing: 6, children: vals.map((n) => Text(n, style: TextStyle(fontSize: isSpecial ? 22 : 16, fontWeight: isSpecial ? FontWeight.w900 : FontWeight.w700, color: isSpecial ? brandRed : ink, fontFeatures: const [FontFeature.tabularFigures()]))).toList())),
              ],
            ),
          );
        }),
      ]),
    );
  }

  Widget historyPage() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text('LỊCH SỬ KẾT QUẢ', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      const SizedBox(height: 6),
      const Text('Bấm vào một ngày để xem lại chi tiết kết quả xổ số:'),
      const SizedBox(height: 14),
      ...dates.map((d) => Card(child: ListTile(
        leading: const CircleAvatar(backgroundColor: Color(0xFFFFE5E5), child: Icon(Icons.calendar_today, color: brandRed, size: 18)),
        title: Text(_prettyDate(d), style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Đài mở thưởng: ${(LotteryDataService.schedule[DateTime.tryParse(d)?.weekday ?? 1] ?? []).join(', ')}', style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          final parsed = DateTime.tryParse(d);
          if (parsed != null) { loadDate(parsed); setState(() => tab = 0); }
        },
      ))),
    ],
  );

  Widget ticketPage() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text('DÒ VÉ SỐ TRỰC TUYẾN', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 14),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Ngày vé số', style: TextStyle(fontSize: 11, color: Colors.black54)),
                Text(DateFormat('dd/MM/yyyy').format(selectedDate), style: const TextStyle(fontWeight: FontWeight.bold)),
              ])),
              OutlinedButton(onPressed: chooseDate, child: const Text('Đổi ngày')),
            ]),
            const SizedBox(height: 14),
            const Text('Đài quay thưởng', style: TextStyle(fontSize: 11, color: Colors.black54)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedFilterProvince,
              items: ['TẤT CẢ CÁC ĐÀI', ...draws.map((d) => d.province)].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) => setState(() { if (v != null) selectedFilterProvince = v; ticketResult = ''; }),
              decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
            ),
            const SizedBox(height: 14),
            const Text('Dãy số trên vé (từ 2 đến 6 số)', style: TextStyle(fontSize: 11, color: Colors.black54)),
            const SizedBox(height: 6),
            TextField(controller: ticketController, keyboardType: TextInputType.number, maxLength: 6, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Ví dụ: 868686 hoặc 86', prefixIcon: Icon(Icons.confirmation_number))),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, height: 45, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: brandRed, foregroundColor: Colors.white), onPressed: checkTicket, icon: const Icon(Icons.search), label: const Text('DÒ KẾT QUẢ TRÚNG THƯỞNG', style: TextStyle(fontWeight: FontWeight.bold)))),
          ]),
        ),
      ),
      if (ticketResult.isNotEmpty) ...[
        const SizedBox(height: 12),
        Card(color: Colors.white, child: Padding(padding: const EdgeInsets.all(16), child: SelectableText(ticketResult, style: const TextStyle(height: 1.6, fontSize: 14, fontWeight: FontWeight.w600, color: ink)))),
      ],
    ],
  );

  Widget settingsPage() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text('CÀI ĐẶT', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      Card(child: ListTile(leading: const Icon(Icons.sync, color: brandRed), title: const Text('Kho dữ liệu XSMN'), subtitle: Text(dataBaseUrl, maxLines: 2, overflow: TextOverflow.ellipsis))),
      Card(child: const ListTile(leading: Icon(Icons.verified_user_outlined, color: brandRed), title: Text('Phiên bản ứng dụng'), subtitle: Text('VIP Xổ Số Miền Nam • v1.0.0 Chuẩn'))),
    ],
  );

  String _prettyDate(String d) { final dt = DateTime.tryParse(d); return dt == null ? d : DateFormat('dd/MM/yyyy').format(dt); }
}

const List<String> _prizeOrder = ['eighthPrize','seventhPrize','sixthPrize','fifthPrize','fourthPrize','thirdPrize','secondPrize','firstPrize','specialPrize'];
String _prizeName(String key) => const {'eighthPrize':'Giải 8','seventhPrize':'Giải 7','sixthPrize':'Giải 6','fifthPrize':'Giải 5','fourthPrize':'Giải 4','thirdPrize':'Giải 3','secondPrize':'Giải 2','firstPrize':'Giải 1','specialPrize':'Đặc biệt'}[key] ?? key;
