import 'package:Shopping/domain/entities/product_entity.dart';

abstract class GatewayContract {
  late List<ProductEntity> products;
  Future<List<ProductEntity>> getProducts(String client);
  Future<ProductEntity?> getProduct(int id);
  Future<int> insertProduct(ProductEntity productEntity);
  Future<void> updateProduct(ProductEntity productEntity);
  Future<void> deleteProduct(ProductEntity productEntity);
  Future<void> cleanAll();
}