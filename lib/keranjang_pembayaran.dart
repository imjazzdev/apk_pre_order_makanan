import 'package:apk_pre_order_makanan/services/api_service.dart';
import 'package:apk_pre_order_makanan/utils/var_global.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'menu.dart';
import 'status_pemesanan.dart';
import 'profile.dart';
import 'riwayat_data.dart';

class KeranjangDanPembayaranPage extends StatefulWidget {
  const KeranjangDanPembayaranPage({super.key});

  @override
  State<KeranjangDanPembayaranPage> createState() =>
      _KeranjangDanPembayaranPageState();
}

class _KeranjangDanPembayaranPageState
    extends State<KeranjangDanPembayaranPage> {
  int _selectedIndex = 1;
  String selectedTime = '';
  String user_id = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUserData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MenuPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StatusPage(
            pesanan: pesananTerakhir,
            waktuPengambilan: waktuPengambilanTerakhir,
            waktuPemesanan: waktuPemesananTerakhir,
          ),
        ),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
  }

  void loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs.getString("user_id") ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalHarga = VarGlobal.keranjang.fold(0, (total, item) {
      final harga = item['price'];
      final jumlah = item['quantity'] ?? 1;
      return total + (harga * jumlah);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: VarGlobal.keranjang.isEmpty
          ? const Center(child: Text('Keranjang masih kosong'))
          : ListView.builder(
              itemCount: VarGlobal.keranjang.length,
              itemBuilder: (context, index) {
                final item = VarGlobal.keranjang[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                VarGlobal.keranjang.removeAt(index);
                              });
                            },
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              item['image_url'],
                              width: 85,
                              height: 85,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                const SizedBox(height: 4),
                                Text(
                                    'Rp ${item['price']} x ${item['quantity']}',
                                    style: const TextStyle(fontSize: 14)),
                                // Text(
                                //     'Subtotal: Rp ${double.tryParse(item['price'])?.toInt() * double.tryParse(item['quantity'])!.toInt()}',
                                //     style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                          // Column(
                          //   children: [
                          //     Row(
                          //       children: [
                          //         IconButton(
                          //           icon: const Icon(Icons.remove),
                          //           onPressed: () {
                          //             setState(() {
                          //               if (item['quantity'] > 1) {
                          //                 item['quantity']--;
                          //               } else {
                          //                 VarGlobal.keranjang.removeAt(index);
                          //               }
                          //             });
                          //           },
                          //         ),
                          //         Text('${item['quantity']}',
                          //             style: const TextStyle(fontSize: 16)),
                          //         IconButton(
                          //           icon: const Icon(Icons.add),
                          //           onPressed: () {
                          //             setState(() {
                          //               item['quantity']++;
                          //             });
                          //           },
                          //         ),
                          //       ],
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (VarGlobal.keranjang.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MenuPage()),
                        );
                      },
                      child: const Text('+ Tambah Menu Lain'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Metode Pembayaran',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Icon(Icons.check_box, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Bayar Langsung di Kantin'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Waktu Pengambilan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Radio<String>(
                        value: '15',
                        groupValue: selectedTime,
                        onChanged: (value) {
                          setState(() {
                            selectedTime = value!;
                          });
                        },
                      ),
                      const Text('15 Menit'),
                      const SizedBox(width: 20),
                      Radio<String>(
                        value: '30',
                        groupValue: selectedTime,
                        onChanged: (value) {
                          setState(() {
                            selectedTime = value!;
                          });
                        },
                      ),
                      const Text('30 Menit'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Harga: Rp $totalHarga',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: selectedTime.isEmpty
                            ? null
                            : () async {
                                final pesananSebelumClear =
                                    List<Map<String, dynamic>>.from(
                                  VarGlobal.keranjang,
                                );

                                // Hitung dan simpan subtotal per item
                                VarGlobal.detailSubtotal =
                                    pesananSebelumClear.map((item) {
                                  final harga = item['price'];
                                  final jumlah = item['quantity'] ?? 1;
                                  final subtotal = harga * jumlah;
                                  return {
                                    'menu_id':
                                        item['id'], // HARUS ADA di keranjang
                                    'name': item['name'],
                                    'price': harga,
                                    'quantity': jumlah,
                                    'subtotal': subtotal,
                                  };
                                }).toList();

                                // Hitung total dan simpan
                                VarGlobal.totalHarga =
                                    VarGlobal.detailSubtotal.fold<int>(
                                  0,
                                  (total, item) =>
                                      total + (item['subtotal'] as int),
                                );

                                try {
                                  // Kirim ke server
                                  final result = await ApiService().postOrders(
                                    user_id,
                                    VarGlobal.totalHarga.toString(),
                                    VarGlobal.detailSubtotal.map((e) {
                                      return {
                                        "menu_id": e['menu_id'],
                                        "quantity": e['quantity'],
                                        "price": e['price'],
                                      };
                                    }).toList(),
                                  );

                                  if (result['status'] == 'success') {
                                    // Simpan data pemesanan lokal
                                    pesananTerakhir = pesananSebelumClear;
                                    waktuPengambilanTerakhir = selectedTime;
                                    waktuPemesananTerakhir = DateTime.now();

                                    // Kosongkan keranjang
                                    setState(() {
                                      VarGlobal.keranjang.clear();
                                    });

                                    // Pindah ke halaman status
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StatusPage(
                                          pesanan: pesananTerakhir,
                                          waktuPengambilan:
                                              waktuPengambilanTerakhir,
                                          waktuPemesanan:
                                              waktuPemesananTerakhir,
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Tampilkan pesan error
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(result['message'])),
                                    );
                                  }
                                } catch (e) {
                                  print('TERJADI KESALAHAN: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Terjadi kesalahan saat memesan")),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Text('Pesan'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          BottomNavigationBar(
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book), label: 'Menu'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart), label: 'Keranjang'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.access_time), label: 'Status Pemesanan'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profil'),
            ],
          ),
        ],
      ),
    );
  }
}
