import 'package:apk_pre_order_makanan/services/api_service.dart';
import 'package:apk_pre_order_makanan/utils/var_global.dart';
import 'package:flutter/material.dart';
import 'keranjang_pembayaran.dart';
import 'status_pemesanan.dart';
import 'profile.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> menus = [];
  bool isLoading = true;
  List<Map<String, dynamic>> filteredMenu = [];

  @override
  void initState() {
    super.initState();
    filteredMenu = List.from(menus); // Awal: tampilkan semua
    searchController.addListener(_filterMenu); // Dengarkan input teks
    getMenus();
  }

  void getMenus() async {
    try {
      final data = await ApiService().getMenus();
      setState(() {
        menus = List<Map<String, dynamic>>.from(data);
        filteredMenu = List.from(menus);
        isLoading = false;
      });
      for (var item in menus) {
        print('==== DATA DARI DATABASE ====');
        item.forEach((key, value) {
          print('$key => $value (${value.runtimeType})');
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterMenu() {
    print('FILTER MENU $filteredMenu');
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredMenu = menus.where((item) {
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
                  pesanan: VarGlobal.keranjang,
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
              item['image_url'],
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
                    final existingItemIndex = VarGlobal.keranjang.indexWhere(
                      (element) => element['name'] == item['name'],
                    );

                    if (existingItemIndex != -1) {
                      VarGlobal.keranjang[existingItemIndex]['quantity'] += 1;
                    } else {
                      VarGlobal.keranjang.add({
                        ...item,
                        'quantity': 1,
                      });
                    }

                    for (var item in VarGlobal.keranjang) {
                      print('==== ITEM ====');
                      item.forEach((key, value) {
                        print('$key => $value (${value.runtimeType})');
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
