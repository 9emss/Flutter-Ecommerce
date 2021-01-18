class ProductModel {
  final String id;
  final String namaProduk;
  final int hargaProduk;
  final String createDate;
  final String cover;
  final String status;
  final String deskripsiProduk;

  ProductModel(
      {this.id,
      this.namaProduk,
      this.hargaProduk,
      this.createDate,
      this.cover,
      this.status,
      this.deskripsiProduk});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      namaProduk: json['namaProduk'],
      hargaProduk: json['hargaProduk'],
      createDate: json['createDate'],
      cover: json['cover'],
      status: json['status'],
      deskripsiProduk: json['deskripsiProduk'],
    );
  }
}
