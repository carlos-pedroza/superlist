import 'package:flutter/material.dart';

class ButtonConfirmComponent extends StatefulWidget {
  final bool small;
  final String value;
  final void Function(String value) onOk;
  final void Function() onCancel;
  const ButtonConfirmComponent({super.key, this.small = false, required this.value, required this.onOk, required this.onCancel});

  @override
  State<ButtonConfirmComponent> createState() => _ButtonConfirmComponentState();
}

class _ButtonConfirmComponentState extends State<ButtonConfirmComponent> {
  final _enterTextController = TextEditingController();

  @override
  void initState() {
    _enterTextController.text = widget.value;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _enterTextController.text = widget.value;
    Future.microtask(() => _enterTextController.selection = TextSelection(baseOffset: 0, extentOffset: _enterTextController.text.length));
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _enterTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.grey[200],
      ),
      padding: !widget.small ? const EdgeInsets.all(10.0) : const EdgeInsets.only(left: 8, right: 8),
      margin: !widget.small ? const EdgeInsets.all(10.0) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if(!widget.small)
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: InkWell(
              onTap: _onCancel,
              child: const Icon(Icons.close_rounded, color: Colors.red, size: 40),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: _enterTextController, // Controlador del TextField
              decoration: InputDecoration(
                prefixIcon: !widget.small ? const Icon(Icons.edit_rounded) : null,
                hintText: '[product name]',
                border: InputBorder.none,
              ),
              onEditingComplete: _onOk,
              keyboardType: widget.small ? const TextInputType.numberWithOptions(signed: false, decimal: true) : null,
            ),
          ),
          const SizedBox(width: 10.0),
          InkWell(
            onTap: _onOk,
            child: !widget.small ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 40) : const Icon(Icons.check_rounded),
          ),
        ],
      ),
    );
  }

  void _onOk() {
    widget.onOk(_enterTextController.text);
  }

  void _onCancel() {
    widget.onCancel();
  }
}