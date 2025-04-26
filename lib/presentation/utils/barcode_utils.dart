import 'package:barcode_widget/barcode_widget.dart';
import 'package:da_storage/data/constants/route_constants.dart';
import 'package:da_storage/data/models/product_model.dart';
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

    if (context.mounted &&
        barcodeResult != 'failed' &&
        barcodeResult != '' &&
        barcodeResult != '-1') {
      final resultAction = await Navigator.pushNamed(
        context,
        RouteConstants.scanBarcode,
        arguments: {
          'barcodeResult': barcodeResult,
          'createTransaction': createTransaction,
        },
      );

      if (resultAction != null) {
        return resultAction as Set<Product>;
      }
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

  static String productIdToBarcodeValue(int productId) {
    return '0${productId.toString().padLeft(6, '0')}';
  }
}
