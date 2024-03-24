import 'dart:convert';

import 'package:Shopping/domain/entities/product_entity.dart';
import 'package:Shopping/domain/gateway/gateway_contract.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalGateway implements GatewayContract {

  static const String productKey = 'producs_key';

  @override
  late List<ProductEntity> products;
  LocalGateway() {
    products = <ProductEntity>[];
  }

  @override
  Future<void> deleteProduct(ProductEntity productEntity) async {
    var prefs = await SharedPreferences.getInstance();

    products.remove(productEntity);
    prefs.setStringList(productKey, products.map((p) => jsonEncode(p.toJson())).toList());
  }

  @override
  Future<ProductEntity?> getProduct(int id) async {
    var prefs = await SharedPreferences.getInstance();

    var sproducts = prefs.getStringList(productKey)??[];

    products = sproducts.map((p) => ProductEntity.fromJson(jsonDecode(p))).toList();

    var items = products.where((p) => p.idproductEntity == id).toList();

    return items.isNotEmpty ? items.first : null;
  }

  @override
  Future<List<ProductEntity>> getProducts(String client) async {
    var prefs = await SharedPreferences.getInstance();

    var sproducts = prefs.getStringList(productKey)??[];

    products = sproducts.map((p) => ProductEntity.fromJson(jsonDecode(p))).toList();

    return products;
  }

  @override
  Future<int> insertProduct(ProductEntity productEntity) async {
    var prefs = await SharedPreferences.getInstance();

    int maxId = products.isNotEmpty
      ? products
          .map((product) => product.idproductEntity??0)
          .reduce((value, element) => value > element ? value : element)
      : 0;
    maxId += 1;
    productEntity = productEntity.changeId(maxId);
    
    products.add(productEntity);

    prefs.setStringList(productKey, products.map((p) => jsonEncode(p.toJson())).toList());

    return maxId;
  }

  @override
  Future<void> updateProduct(ProductEntity productEntity) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setStringList(productKey, products.map((p) => jsonEncode(p.toJson())).toList());
  }
  
  @override
  Future<void> cleanAll() async {
    var prefs = await SharedPreferences.getInstance();

    products.clear();

    prefs.remove(productKey);
  }
 
}