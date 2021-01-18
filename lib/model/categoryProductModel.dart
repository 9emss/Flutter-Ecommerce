import 'package:my_ecommerce/model/productModel.dart';

class CategoryProductModel {
  final String id;
  final String categoryName;
  final int status;
  final String createDate;
  final List<ProductModel> product;

  CategoryProductModel({
    this.id,
    this.categoryName,
    this.status,
    this.createDate,
    this.product,
  });

  factory CategoryProductModel.froJson(Map<String, dynamic> json) {
    var list = json['product'] as List;
    List<ProductModel> productList =
        list.map((i) => ProductModel.fromJson(i)).toList();

    return CategoryProductModel(
      product: productList,
      id: json['id'],
      categoryName: json['categoryName'],
      status: json['status'],
      createDate: json['createDate'],
    );
  }
}
