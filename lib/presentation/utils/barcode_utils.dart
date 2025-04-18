import 'package:barcode_widget/barcode_widget.dart';
import 'package:da_cashier/data/constants/route_constants.dart';
import 'package:da_cashier/data/models/product_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';

class BarcodeUtils {
  static Future<Set<Product>> scanBarcode(
    BuildContext context, {
    bool createTransaction = false,
  }) async {
    String barcodeResult;

    try {
      barcodeResult = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );
    } on PlatformException {
      barcodeResult = 'failed';
    }

    if (context.mounted && barcodeResult != 'failed' && barcodeResult != '') {
      return await Navigator.pushNamed(
            context,
            RouteConstants.scanBarcode,
            arguments: {
              'barcodeResult': barcodeResult,
              'createTransaction': createTransaction,
            },
          )
          as Set<Product>;
    }

    return <Product>{Product.none};
  }

  static BarcodeWidget generateBarcode(String data) {
    return BarcodeWidget(
      data: data,
      barcode: Barcode.upcE(),
      width: 200,
      height: 100,
    );
  }
}
