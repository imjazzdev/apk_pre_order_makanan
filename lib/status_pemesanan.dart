import 'dart:async';
import 'package:apk_pre_order_makanan/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'menu.dart';
import 'keranjang_pembayaran.dart';
import 'profile.dart';

int nomorAntrianGlobal = 0;

class StatusPage extends StatefulWidget {
  final List<Map<String, dynamic>> pesanan;
  final String waktuPengambilan;
  final DateTime waktuPemesanan;

  const StatusPage({
    super.key,
    required this.pesanan,
    required this.waktuPengambilan,
    required this.waktuPemesanan,
  });

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  String userId = '';
  Future<List<Map<String, dynamic>>>? futureOrders;
  String role = "";
  late DateTime waktuPemesanan;
  late int nomorAntrian;
  late List<Map<String, dynamic>> daftarPesanan;
  late int totalHarga;
  late Duration durasiPengambilan;
  Timer? timer;

  List<bool> statusChecklist = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    waktuPemesanan = widget.waktuPemesanan;
    daftarPesanan = List.from(widget.pesanan);
    nomorAntrianGlobal++;
    nomorAntrian = nomorAntrianGlobal;

    int menit = int.tryParse(widget.waktuPengambilan) ?? 0;
    durasiPengambilan = Duration(minutes: menit);

    timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateStatus());

    // Panggil async secara terpisah
    loadUserData();
  }

  void loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString("user_id") ?? '';
      role = prefs.getString("role") ?? '';
    });

    // Setelah userId dimuat, baru fetch orders
    setState(() {
      futureOrders = ApiService().getOrderDetails(userId);
    });
  }

  void _updateStatus() {
    final sekarang = DateTime.now();
    final selisih = sekarang.difference(waktuPemesanan).inMinutes;

    setState(() {
      if (selisih >= 0) statusChecklist[0] = true;
      if (selisih >= durasiPengambilan.inMinutes * 0.25)
        statusChecklist[1] = true;
      if (selisih >= durasiPengambilan.inMinutes * 0.5)
        statusChecklist[2] = true;
      if (selisih >= durasiPengambilan.inMinutes) statusChecklist[3] = true;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const MenuPage()));
    } else if (index == 1) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const KeranjangDanPembayaranPage()));
    } else if (index == 3) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const ProfilePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Pemesanan'),
        backgroundColor: Colors.pinkAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada pesanan."));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final items = List<Map<String, dynamic>>.from(order['items']);

              return Container(
                color: Colors.pink.shade100,
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Waktu Pemesanan:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(order['order_date']),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Status:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(order['status']),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Daftar Pesanan:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 8),
                          child: Text(
                              "- ${item['name']} x${item['quantity']} (Rp ${item['price']})"),
                        )),
                    const SizedBox(height: 8),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Text('Total: Rp ${order['total_amount']}')),
                  ],
                ),
              );
            },
          );
        },
      ),

      // body: Padding(
      //   padding: const EdgeInsets.all(16),
      //   child: ListView(
      //     children: [
      //       Container(
      //         padding: const EdgeInsets.all(12),
      //         color: Color(0xFFF9C9D5), // 🎨 Pink muda
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             Text(
      //                 'Waktu Pemesanan: ${DateFormat("dd-mm-yyy HH:mm:ss").format(waktuPemesanan)}'),
      //             Text('Nomor Antrian: $nomorAntrian'),
      //           ],
      //         ),
      //       ),
      //       const SizedBox(height: 12),
      //       Container(
      //         padding: const EdgeInsets.all(12),
      //         color: Color(0xFFF9C9D5), // 🎨 Pink muda
      //         child: const Text('Daftar Pesanan',
      //             style: TextStyle(fontWeight: FontWeight.bold)),
      //       ),
      //       if (daftarPesanan.isNotEmpty)
      //         ...daftarPesanan.map((item) => Padding(
      //               padding:
      //                   const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      //               child: Text("${item['name']} x${item['quantity']}"),
      //             ))
      //       else
      //         const Padding(
      //           padding: EdgeInsets.all(8),
      //           child: Text("Belum ada pesanan."),
      //         ),
      //       const SizedBox(height: 12),
      //       Container(
      //         padding: const EdgeInsets.all(12),
      //         color: Color(0xFFF9C9D5), // 🎨 Pink muda
      //         child: Text('Total: Rp $totalHarga'),
      //       ),
      //       const SizedBox(height: 12),
      //       role == "admin"
      //           ? Container(
      //               padding: const EdgeInsets.all(12),
      //               color: Color(0xFFF9C9D5), // 🎨 Pink muda
      //               child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   const Text('Status saat ini:',
      //                       style: TextStyle(fontWeight: FontWeight.bold)),
      //                   CheckboxListTile(
      //                       title: const Text('Menunggu Konfirmasi'),
      //                       value: statusChecklist[0],
      //                       onChanged: null),
      //                   CheckboxListTile(
      //                       title: const Text('Diproses'),
      //                       value: statusChecklist[1],
      //                       onChanged: null),
      //                   CheckboxListTile(
      //                       title: const Text('Siap Diambil'),
      //                       value: statusChecklist[2],
      //                       onChanged: null),
      //                   CheckboxListTile(
      //                       title: const Text('Pesanan Selesai'),
      //                       value: statusChecklist[3],
      //                       onChanged: null),
      //                 ],
      //               ),
      //             )
      //           : Container(
      //               padding: const EdgeInsets.all(12),
      //               color: Color(0xFFF9C9D5), // 🎨 Pink muda
      //               child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   const Text('Status saat ini:',
      //                       style: TextStyle(fontWeight: FontWeight.bold)),
      //                   Text('STATUS')
      //                 ],
      //               ),
      //             ),
      //     ],
      //   ),
      // ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Menu'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Keranjang'),
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time), label: 'Status Pemesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
