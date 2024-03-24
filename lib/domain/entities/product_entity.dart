class ProductEntity {
  final int? idproductEntity;
  String name;
  bool check;
  double cost;
  ProductEntity({
    this.idproductEntity,
    required this.name,
    this.cost = 0.0,
    this.check = false,
  });

  factory ProductEntity.fromJson(Map<String, dynamic> json) {
    return ProductEntity(
      idproductEntity: json['idproductEntity'], 
      name: json['product'],
      cost: (json['cost'] as num).toDouble(),
      check: json['check']
    );
  }

  ProductEntity changeId(int id) {
    return ProductEntity(
      idproductEntity: id, 
      name: name,
      check: check,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idproductEntity': idproductEntity,
      'product': name,
      'cost': cost,
      'check': check,
    };
  }
}