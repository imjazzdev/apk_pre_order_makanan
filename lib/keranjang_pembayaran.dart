import 'package:flutter/material.dart';
import 'keranjang_data.dart';
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

  @override
  Widget build(BuildContext context) {
    int totalHarga = keranjang.fold<int>(
      0,
          (total, item) =>
      total + (item['price'] as int) * ((item['quantity'] ?? 1) as int),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: keranjang.isEmpty
          ? const Center(child: Text('Keranjang masih kosong'))
          : ListView.builder(
        itemCount: keranjang.length,
        itemBuilder: (context, index) {
          final item = keranjang[index];
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
                      icon:
                      const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          keranjang.removeAt(index);
                        });
                      },
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        item['image'],
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
                          Text(
                              'Subtotal: Rp ${item['price'] * item['quantity']}',
                              style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if (item['quantity'] > 1) {
                                    item['quantity']--;
                                  } else {
                                    keranjang.removeAt(index);
                                  }
                                });
                              },
                            ),
                            Text('${item['quantity']}',
                                style:
                                const TextStyle(fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  item['quantity']++;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
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
          if (keranjang.isNotEmpty)
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
                            : () {
                          final pesananSebelumClear =
                          List<Map<String, dynamic>>.from(keranjang);

                          // Simpan ke riwayat_data
                          pesananTerakhir = pesananSebelumClear;
                          waktuPengambilanTerakhir = selectedTime;
                          waktuPemesananTerakhir = DateTime.now();

                          setState(() {
                            keranjang.clear();
                          });

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
