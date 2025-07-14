class VarGlobal {
  static List<Map<String, dynamic>> keranjang = [];

  static int totalHarga = 0;
  static List<Map<String, dynamic>> detailSubtotal = [];

  // Jika belum ada, bisa taruh ini juga:
  static List<Map<String, dynamic>> pesananTerakhir = [];
  static String waktuPengambilanTerakhir = '';
  static DateTime waktuPemesananTerakhir = DateTime.now();
}
