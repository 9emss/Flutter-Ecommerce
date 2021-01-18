class ProductCartModel {
  final String id;
  final String namaProduk;
  final int hargaProduk;
  final String createDate;
  final String cover;
  final String status;
  final String deskripsiProduk;
  final String qty;

  ProductCartModel({
    this.id,
    this.namaProduk,
    this.hargaProduk,
    this.createDate,
    this.cover,
    this.status,
    this.deskripsiProduk,
    this.qty,
  });

  factory ProductCartModel.fromJson(Map<String, dynamic> json) {
    return ProductCartModel(
      id: json['id'],
      namaProduk: json['namaProduk'],
      hargaProduk: json['hargaProduk'],
      createDate: json['createDate'],
      cover: json['cover'],
      status: json['status'],
      deskripsiProduk: json['deskripsiProduk'],
      qty: json['qty'],
    );
  }
}
