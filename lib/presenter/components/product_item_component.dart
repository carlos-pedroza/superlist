import 'package:Shopping/domain/cases/controller.dart';
import 'package:Shopping/domain/entities/product_entity.dart';
import 'package:Shopping/presenter/components/button_confirm_component.dart';
import 'package:Shopping/presenter/components/button_listen_component.dart';
import 'package:Shopping/tools/snak.dart';
import 'package:flutter/material.dart';

class ProductItemComponent extends StatefulWidget {
  final Controller controller;
  final ProductEntity product;
  final bool showDelete;
  final void Function(ProductEntity productEntity) onEdit;
  final void Function(ProductEntity productEntity) onCheck;
  final void Function(ProductEntity productEntity) onChange;
  final void Function(ProductEntity productEntity) onCancel;
  final void Function(ProductEntity productEntity) onDelete;
  const ProductItemComponent({super.key, required this.controller, required this.product, required this.showDelete, required this.onEdit, required this.onCheck, required this.onChange, required this.onCancel, required this.onDelete});

  @override
  State<ProductItemComponent> createState() => _ProductItemComponentState();
}

class _ProductItemComponentState extends State<ProductItemComponent> {
  late bool _hasCost;
  var _confirmValue = false;
  double _containerWidth = 0.0;
  var _showDeleteIcon = false;
  var _isEdit = false;
  var _name = '';

  Color? _getColor() {
    return widget.product.check ? Colors.green[100] : Colors.grey[600];
  }

  void _startAnimation() {
    Future.delayed(Duration.zero, () {
      setState(() {
        _showDeleteIcon = true;
        _containerWidth = 60.0;
      });

      Future.delayed(const Duration(milliseconds: 700), () {
        setState(() {
          _containerWidth = 0.0;
        });

        Future.delayed(const Duration(milliseconds: 700), () { 
          setState(() {
            _showDeleteIcon = false;
          });
        });

      });
    });
  }

  @override
  void initState() {
    super.initState();
    _hasCost = widget.product.cost > 0;
    if(widget.showDelete) {
      _startAnimation();
    }
  }

  @override
  void didChangeDependencies() {
    setState(() {
      _hasCost = widget.product.cost > 0;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.product.idproductEntity.toString()), // Usar una clave única para cada elemento
      direction: DismissDirection.endToStart, // Dirección de deslizamiento
      onDismissed: (direction) {
        widget.onDelete(widget.product);
        Snak.show(
          context: context, 
          message: 'Removed item!',
          backcolor: Colors.red,
          style: Theme.of(context).textTheme.displayMedium,
        );
      },
      background: Container(
        color: Colors.red, // Color de fondo al deslizar
        child: const ListTile(
          trailing: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if(!_isEdit)
          Row(
            children: [
              Expanded(
                child: ListTile(
                  leading: IconButton(
                    onPressed: _onCheck,
                    icon: Icon(Icons.check_circle_rounded, color: _getColor(), size: 40),
                  ),
                  title: InkWell(
                    onTap: _onEditProduct,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.product.name,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.edit_rounded, color: Colors.white24)
                      ],
                    ),
                  ),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if(_hasCost && !_confirmValue)
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.30,
                        child: TextButton.icon(
                          onPressed: _onListenCost, 
                          icon: const Icon(Icons.close_rounded, color: Colors.white), 
                          label: Text(widget.product.cost.toString(), style: Theme.of(context).textTheme.displaySmall),
                        ),
                      ),
                      if(!_hasCost && !_confirmValue)
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ButtonListenComponent(
                              small: true,
                              onChange: _onChangeCost, 
                              onError: _onErrorCost
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 10),
                              padding: const EdgeInsets.all(4),
                              child: InkWell(
                                onTap: _onEdit,
                                child: const Icon(Icons.keyboard, color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ),
                      if(_confirmValue)
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.30,
                        child: ButtonConfirmComponent(
                          small: true,
                          value: widget.product.cost.toString(), 
                          onOk: _setCost,
                          onCancel: _onCancelProduct,
                        ),
                      ),
                    ],
                  )
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: _containerWidth,
                height: 60.0,
                color: Colors.red,
                child: Visibility(
                  visible: _showDeleteIcon,
                  child: const Center(
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if(_isEdit)
          ButtonConfirmComponent(
            value: _name, 
            onOk: _onChange,
            onCancel: _onCancel,
          ),
        ],
      ),
    );
  }

  void _onCheck() {
    setState(() {
      widget.product.check = !widget.product.check;
    });
    widget.controller.updateProduct(widget.product);
    widget.onCheck(widget.product);
  }

  void _onChangeCost(String value) async {
    widget.product.cost = _getCost(value);
    setState(() {
      _confirmValue = true;
    });
    widget.onEdit(widget.product);
  }

  void _onErrorCost() {
  }

  void _onListenCost() {
    widget.product.cost = 0.0;
    widget.controller.updateProduct(widget.product);
    widget.onChange(widget.product);
    setState(() {
      _hasCost = widget.product.cost > 0;
    });
  }

  void _setCost(String value) {
    widget.product.cost = double.parse(value);
    widget.controller.updateProduct(widget.product);
    widget.onChange(widget.product);
    setState(() {
      _confirmValue = false;
      _hasCost = widget.product.cost > 0.0;
    });
  }

  void _onCancelProduct() {
    setState(() {
      _confirmValue = false;
      _hasCost = widget.product.cost > 0.0;
    });
  }

  double _getCost(String value) {
    double? parsedDouble = double.tryParse(value);
    parsedDouble ??= 0.0; 

    return parsedDouble;
  }

  void _onEditProduct() {
    setState(() {
      _isEdit = true;
      _name = widget.product.name;
    });
    widget.onEdit(widget.product);
  }

  void _onChange(String value) {
    if(value.trim().isNotEmpty) {
      setState(() {
        _isEdit = false;
        widget.product.name = value;
      });
      widget.onChange(widget.product);
    }
  }

  void _onCancel() {
    setState(() {
      _isEdit = false;
    });
    widget.onCancel(widget.product);
  }

  void _onEdit() {
    setState(() {
      _confirmValue = true;
    });
    widget.onEdit(widget.product);
  }
}