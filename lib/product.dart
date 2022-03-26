class Product {
  String productID;
  String productName;
  String mCheckPoints;
  String originCountry;
  String barCode;
  String productImage;
  double productPrice;
  double totalPrice;
  int quantity = 1;

  Product(this.productID, this.productName, this.mCheckPoints,
      this.originCountry, this.barCode, this.productImage, this.productPrice, this.totalPrice, this.quantity);

  factory Product.fromJson(dynamic json) {
    return Product(
        json['productID'] as String,
        json['productName'] as String,
        json['mCheckPoints'] as String,
        json['originCountry'] as String,
        json['barCode'] as String,
        json['productImage'] as String,
        json['productPrice'] as double,
        json['totalPrice'] as double,
        json['quantity'] as int);
  }

  String toJson() {
    return '{ ${this.productID}, ${this.productName}, ${this.mCheckPoints}, ${this.originCountry}, ${this.barCode}, ${this.productImage}, ${this.productPrice}, ${this.totalPrice}, ${this.quantity} }';
  }
}
