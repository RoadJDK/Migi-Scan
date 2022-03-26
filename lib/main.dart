import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:migi_scan/Product.dart';

const Color DEFAULT_COLOR = Color.fromRGBO(255, 102, 0, 1);
const String CANCEL_BUTTON_TEXT = "Cancel";

bool useAlternative = false;

List<Product>? products;
List<Product> scannedProducts = [];

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Migi Scan';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: ShoppingCardWidgetState(),
    );
  }
}

class ShoppingCardWidgetState extends StatefulWidget {
  const ShoppingCardWidgetState({Key? key}) : super(key: key);

  @override
  State<ShoppingCardWidgetState> createState() => ShoppingCardWidget();
}

class ShoppingCardWidget extends State<ShoppingCardWidgetState> {
  bool isAlternating = false;

  List<Product> products = <Product>[];

  @override
  void initState() {
    super.initState();
    getProductDetails();
  }

  getProductDetails() async {
    String jsonString = await rootBundle.loadString('assets/data.json');
    var parsed = json.decode(jsonString);
    products = (parsed as List).map((data) => Product.fromJson(data)).toList();
  }

  validateAnswer(
      String scannedBarcode,
      Iterable<Product> contain,
      int mCheckScore,
      int highestMCheck,
      Product highestMCheckProduct,
      Iterable<Product> alreadyAdded) {
    if (contain.isNotEmpty) {
      if (mCheckScore < highestMCheck) {
        showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => AlertDialog(
                  title: const Text('There is a better alternative'),
                  content: Text(highestMCheckProduct.productName),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, 'Cancel');
                        if (alreadyAdded.isNotEmpty &&
                            scannedProducts.isNotEmpty) {
                          alreadyAdded.first.quantity += 1;
                        } else {
                          scannedProducts.add(contain.first);
                        }
                        setState(() {});
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, 'Add');

                        var alreadyAddedAlternative = scannedProducts.where(
                            (product) =>
                                product.productID ==
                                highestMCheckProduct.productID);

                        if (alreadyAddedAlternative.isNotEmpty &&
                            scannedProducts.isNotEmpty) {
                          alreadyAddedAlternative.first.quantity += 1;
                        } else {
                          scannedProducts.add(highestMCheckProduct);
                        }
                        setState(() {});
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ));
      } else {
        if (alreadyAdded.isNotEmpty && scannedProducts.isNotEmpty) {
          alreadyAdded.first.quantity += 1;
        } else {
          scannedProducts.add(contain.first);
        }
        setState(() {});
      }
    } else {
      scannedProducts.add(Product("0", "Unknown Product", "0", "Unknown",
          "Unknown", "Unknown", 0.00, 0.00, 1));
      setState(() {});
    }
  }

  String calculateStars(Product product) {
    var points = int.parse(product.mCheckPoints);

    switch (points) {
      case 1:
        return 'assets/star_1.png';

      case 2:
        return 'assets/star_2.png';

      case 3:
        return 'assets/star_3.png';

      case 4:
        return 'assets/star_4.png';

      case 5:
        return 'assets/star_5.png';
    }

    return '';
  }

  @override
  Widget build(BuildContext ctxt) {
    const Key centerKey = ValueKey<String>('bottom-sliver-list');

    return Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: <Widget>[
            const SliverPadding(
                padding: EdgeInsets.only(left: 20.0, right: 20, bottom: 20),
                sliver: SliverAppBar(
                  title: Text(
                    'PRODUCT OVERVIEW',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black),
                  ),
                  backgroundColor: Colors.white,
                  floating: true,
                  snap: true,
                )),
            const SliverPadding(
              padding:
                  EdgeInsets.only(left: 20.0, top: 5, right: 20, bottom: 2),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'My Shopping Card',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.black),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      height: 150,
                      child: Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 2, top: 2, right: 2, bottom: 2),
                                  child: Container(
                                      margin: const EdgeInsets.all(20),
                                      decoration: const BoxDecoration(
                                        color:
                                            Color.fromRGBO(204, 204, 204, 0.3),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                      ),
                                      height: 100,
                                      width: 100,
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Image.asset(
                                          'assets/chocolate.png',
                                          height: 75,
                                          width: 75,
                                        ),
                                      )))),
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    scannedProducts[index].productName,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 2, bottom: 2),
                                  child: Text(
                                      'CHF ${scannedProducts[index].totalPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 12),
                                      textAlign: TextAlign.left),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 2, bottom: 2),
                                  child: Image.asset(
                                      calculateStars(scannedProducts[index]),
                                      height: 10),
                                ),
                                Row(children: [
                                  Expanded(
                                    flex: 1,
                                    child: IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
                                      onPressed: () {
                                        scannedProducts[index].quantity -= 1;
                                        scannedProducts[index].totalPrice =
                                            scannedProducts[index].totalPrice -
                                                scannedProducts[index]
                                                    .productPrice;

                                        if (scannedProducts[index].quantity <=
                                            0) {
                                          scannedProducts[index].quantity = 1;
                                          scannedProducts[index].totalPrice =
                                              scannedProducts[index]
                                                  .productPrice;
                                          scannedProducts
                                              .remove(scannedProducts[index]);
                                        }
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                        '${scannedProducts[index].quantity}x',
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 12),
                                        textAlign: TextAlign.center,
                                      )),
                                  Expanded(
                                    flex: 1,
                                    child: IconButton(
                                      icon:
                                          const Icon(Icons.add_circle_outline),
                                      onPressed: () {
                                        scannedProducts[index].quantity += 1;
                                        scannedProducts[index].totalPrice =
                                            (scannedProducts[index].totalPrice +
                                                scannedProducts[index]
                                                    .productPrice);

                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 1,
                                    child: SizedBox(),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete_outlined),
                                      onPressed: () {
                                        scannedProducts[index].quantity = 1;
                                        scannedProducts[index].totalPrice =
                                            scannedProducts[index].productPrice;

                                        scannedProducts
                                            .remove(scannedProducts[index]);
                                        setState(() {});
                                      },
                                    ),
                                  )
                                ])
                              ],
                            ),
                          )
                        ],
                      ));
                },
                childCount: scannedProducts.length,
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton.extended(
            onPressed: () async {
              var scannedBarcode = await FlutterBarcodeScanner.scanBarcode(
                  '#ff6600', CANCEL_BUTTON_TEXT, false, ScanMode.BARCODE);

              if (scannedBarcode == '-1') {
                return;
              }

              int mCheckScore = 0;
              var contain = products
                  .where((product) => product.barCode == scannedBarcode);
              if (contain.isNotEmpty) {
                mCheckScore = int.parse(contain.first.mCheckPoints);
              }

              var highestMCheckProduct = Product("0", "Unknown Product", "0",
                  "Unknown", "Unknown", "Unknown", 0.00, 0.00, 1);
              var highestMCheck = 0;

              for (var i = 0; i < products.length; i++) {
                if (int.parse(products[i].mCheckPoints) > highestMCheck) {
                  highestMCheck = int.parse(products[i].mCheckPoints);
                  highestMCheckProduct = products[i];
                }
              }

              var alreadyAdded = scannedProducts.where(
                  (product) => product.productID == contain.first.productID);

              validateAnswer(scannedBarcode, contain, mCheckScore,
                  highestMCheck, highestMCheckProduct, alreadyAdded);

              setState(() {});
            },
            label: const Text('ADD PRODUCT'),
            backgroundColor: DEFAULT_COLOR,
          ),
          const SizedBox(
            height: 10,
          ),
          FloatingActionButton.extended(
            onPressed: () async {
              if (scannedProducts.isNotEmpty) {
                for (var i = 0; i < scannedProducts.length; i++) {
                  if (scannedProducts[i].productID != '0') {
                    for (var j = 0; j < scannedProducts[i].quantity; j++) {
                      await showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) =>
                              BarcodeDialog(scannedProducts[i].productImage));
                    }
                  }
                }

                int totalPoints = 0;

                for (var i = 0; i < scannedProducts.length; i++) {
                  if (scannedProducts[i].productID != '0') {
                    for (var j = 0; j < scannedProducts[i].quantity; j++) {
                      totalPoints += int.parse(scannedProducts[i].mCheckPoints);
                    }
                  }
                }

                if (totalPoints >= 1) {
                  await showDialog(
                      context: context,
                      builder: (_) => CheckoutDialog(totalPoints));
                }

                scannedProducts.clear();
                setState(() {});
              }
            },
            label: const Text('CHECKOUT'),
            backgroundColor: Colors.lightGreen,
          )
        ]));
  }
}

class BarcodeDialog extends StatelessWidget {
  String barcode = "";

  BarcodeDialog(this.barcode, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: InkWell(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: ExactAssetImage(barcode), fit: BoxFit.contain)),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    ));
  }
}

class CheckoutDialog extends StatelessWidget {
  int points = 0;

  CheckoutDialog(this.points, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: InkWell(
      child: Container(
          width: 200,
          height: 200,
          child: Center(
              child: Text(
            'You gained ${points} points! Not bad..',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ))),
      onTap: () {
        Navigator.pop(context);
      },
    ));
  }
}
