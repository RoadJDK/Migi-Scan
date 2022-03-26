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

  Color colorPicker() {
    if (isAlternating == true) {
      isAlternating = false;
      return Color.fromRGBO(187, 222, 251, 1);
    } else {
      isAlternating = true;
      return Color.fromRGBO(197, 202, 233, 1);
    }
  }

  validateAnswer(String scannedBarcode, Iterable<Product> contain, int mCheckScore,
      int highestMCheck, Product highestMCheckProduct, Iterable<Product> alreadyAdded) {

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
                        if (alreadyAdded.isNotEmpty && scannedProducts.isNotEmpty) {
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

                        var alreadyAddedAlternative =
                        scannedProducts.where((product) => product.productID == highestMCheckProduct.productID);

                        if (alreadyAddedAlternative.isNotEmpty && scannedProducts.isNotEmpty) {
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
      scannedProducts.add(Product(
          "0", "Unknown Product", "0", "Unknown", "Unknown", "Unknown", 1));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext ctxt) {
    const Key centerKey = ValueKey<String>('bottom-sliver-list');

    return Scaffold(
        body: CustomScrollView(
          center: centerKey,
          slivers: <Widget>[
            SliverList(
              key: centerKey,
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return Container(
                    width: double.infinity,
                    color: colorPicker(),
                    margin: EdgeInsets.all(20),
                    height: 200,
                    child: Column(
                      children: <Widget>[
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                '${scannedProducts[index].quantity}x: ${scannedProducts[index].productName}'
                            )
                        ),
                        Align(
                            alignment: Alignment.center,
                            child: TextButton.icon(
                              onPressed: () {
                                scannedProducts[index].quantity += 1;
                                setState(() {});
                              },
                              icon: Icon(Icons.add, size: 18),
                              label: Text(""),
                            )
                        ),
                        Align(
                            alignment: Alignment.center,
                            child: TextButton.icon(
                              onPressed: () {
                                scannedProducts[index].quantity -= 1;
                                if (scannedProducts[index].quantity <= 0) {
                                  scannedProducts[index].quantity = 1;
                                  scannedProducts.remove(scannedProducts[index]);
                                }
                                setState(() {});
                              },
                              icon: Icon(Icons.remove, size: 18),
                              label: Text(""),
                            )
                        ),
                        Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                scannedProducts[index].quantity = 1;
                                scannedProducts.remove(scannedProducts[index]);
                                setState(() {});
                              },
                              icon: Icon(Icons.delete_outlined, size: 18),
                              label: Text(""),
                            )
                        )
                      ],
                    ),
                  );
                },
                childCount: scannedProducts.length,
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                onPressed: () async {
                  var scannedBarcode = await FlutterBarcodeScanner.scanBarcode(
                      '#ff6600', CANCEL_BUTTON_TEXT, false, ScanMode.BARCODE);

                  if (scannedBarcode == '-1') {
                    return;
                  }

                  int mCheckScore = 0;
                  var contain =
                  products.where((product) => product.barCode == scannedBarcode);
                  if (contain.isNotEmpty) {
                    mCheckScore = int.parse(contain.first.mCheckPoints);
                  }

                  var highestMCheckProduct = Product(
                      "0", "Unknown Product", "0", "Unknown", "Unknown", "Unknown", 1);
                  var highestMCheck = 0;

                  for (var i = 0; i < products.length; i++) {
                    if (int.parse(products[i].mCheckPoints) > highestMCheck) {
                      highestMCheck = int.parse(products[i].mCheckPoints);
                      highestMCheckProduct = products[i];
                    }
                  }

                  var alreadyAdded =
                  scannedProducts.where((product) => product.productID == contain.first.productID);

                  validateAnswer(scannedBarcode, contain, mCheckScore, highestMCheck, highestMCheckProduct, alreadyAdded);

                  setState(() {});
                },
                label: const Text('ADD PRODUCT'),
                backgroundColor: DEFAULT_COLOR,
              ),
              SizedBox(
                height: 10,
              ),
              FloatingActionButton.extended(
                onPressed: () {
                  // Add your onPressed code here!
                },
                label: const Text('CHECKOUT'),
                backgroundColor: Colors.lightGreen,
              )
            ]
        )
    );
  }
}

class BarcodeDialog extends StatelessWidget {
  String barcode = "";

  BarcodeDialog(String barcode) {
    this.barcode = barcode;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: InkWell(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: ExactAssetImage(barcode),
                  fit: BoxFit.contain
              )
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      )
    );
  }
}

class CheckoutDialog extends StatelessWidget {
  int points = 0;

  CheckoutDialog(int points) {
    this.points = points;
  }

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
                )
            )
        ),
        onTap: () {
          Navigator.pop(context);
        },
      )
    );
  }
}
