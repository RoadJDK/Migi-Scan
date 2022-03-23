import 'dart:convert';

Product employeeFromJson(String str) => Product.fromJson(json.decode(str));

String employeeToJson(Product data) => json.encode(data.toJson());

class Product {
  String productID;
  String productName;
  String mCheckPoints;
  String originCountry;
  String barCode;
  String productImage;
  int quantity = 1;

  Product(this.productID, this.productName, this.mCheckPoints,
      this.originCountry, this.barCode, this.productImage, this.quantity);


  factory Product.fromJson(dynamic json) {
    return Product(
        json['productID'] as String,
        json['productName'] as String,
        json['mCheckPoints'] as String,
        json['originCountry'] as String,
        json['barCode'] as String,
        json['productImage'] as String,
        json['quantity'] as int);
  }

  String toJson() {
    return '{ ${this.productID}, ${this.productName}, ${this.mCheckPoints}, ${this.originCountry}, ${this.barCode}, ${this.productImage}, ${this.quantity} }';
  }
}
