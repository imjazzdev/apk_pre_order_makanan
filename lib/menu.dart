import 'package:flutter/material.dart';
import 'keranjang_pembayaran.dart';
import 'keranjang_data.dart';
import 'status_pemesanan.dart';
import 'profile.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> menuItems = const [
    {'name': 'Nasi Goreng', 'price': 12000, 'image': 'images/nasi_goreng.jpg'},
    {'name': 'Ayam Kremes', 'price': 12000, 'image': 'images/ayam_kremes.jpg'},
    {'name': 'Sop Ayam', 'price': 12000, 'image': 'images/sop_ayam.jpg'},
    {'name': 'Gado-Gado', 'price': 12000, 'image': 'images/gado-gado.jpeg'},
    {
      'name': 'Nasi Ayam Katsu',
      'price': 12000,
      'image': 'images/mie_rebus.jpg'
    },
    {'name': 'Nasi Bakar', 'price': 12000, 'image': 'images/nasi_bakar.jpg'},
  ];

  List<Map<String, dynamic>> filteredMenu = [];

  @override
  void initState() {
    super.initState();
    filteredMenu = List.from(menuItems); // Awal: tampilkan semua
    searchController.addListener(_filterMenu); // Dengarkan input teks
  }

  void _filterMenu() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredMenu = menuItems.where((item) {
        final name = item['name'].toString().toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF9C9D5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Menu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  itemCount: filteredMenu.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final item = filteredMenu[index];
                    return _buildMenuItem(context, item);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const KeranjangDanPembayaranPage(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StatusPage(
                  pesanan: keranjang,
                  waktuPemesanan: DateTime.now(),
                  waktuPengambilan: "30",
                ),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfilePage(),
              ),
            );
          }
        },
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

  Widget _buildMenuItem(BuildContext context, Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              item['image'],
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${item['price']}',
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                ),
                const SizedBox(height: 5),
                ElevatedButton.icon(
                  onPressed: () {
                    final existingItemIndex = keranjang.indexWhere(
                      (element) => element['name'] == item['name'],
                    );

                    if (existingItemIndex != -1) {
                      keranjang[existingItemIndex]['quantity'] += 1;
                    } else {
                      keranjang.add({
                        ...item,
                        'quantity': 1,
                      });
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('${item['name']} ditambahkan ke keranjang')),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text("Tambah"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
