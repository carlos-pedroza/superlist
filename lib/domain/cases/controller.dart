import 'package:Shopping/domain/entities/product_entity.dart';
import 'package:Shopping/domain/gateway/gateway_contract.dart';
import 'package:Shopping/domain/gateway/local_gateway.dart';

class Controller implements GatewayContract {
  late GatewayContract _contract;
  Controller() {
    _contract = LocalGateway();
  }

  @override
  List<ProductEntity> get products {
    return _contract.products;
  }

  @override
  Future<void> deleteProduct(ProductEntity productEntity) {
    return _contract.deleteProduct(productEntity);
  }

  @override
  Future<ProductEntity?> getProduct(int id) {
    return _contract.getProduct(id);
  }

  @override
  Future<List<ProductEntity>> getProducts(String client) {
    return _contract.getProducts(client);
  }

  @override
  Future<int> insertProduct(ProductEntity productEntity) {
    return _contract.insertProduct(productEntity);
  }

  @override
  Future<void> updateProduct(ProductEntity productEntity) {
    return _contract.updateProduct(productEntity);
  }
  
  @override
  set products(List<ProductEntity> _products) {
  }
  
  @override
  Future<void> cleanAll() {
    return _contract.cleanAll();
  }

}