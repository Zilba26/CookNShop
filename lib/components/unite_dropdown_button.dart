import 'package:cook_n_shop/models/units.dart';
import 'package:cook_n_shop/my_shared_preferences.dart';
import 'package:flutter/material.dart';

class UniteDropdownButton extends StatefulWidget {

  final Function(Unit unite)? onTap;
  final ValueNotifier<Unit> controller;

  const UniteDropdownButton({Key? key, this.onTap, required this.controller}) : super(key: key);

  @override
  State<UniteDropdownButton> createState() => _UniteDropdownButtonState();
}

class _UniteDropdownButtonState extends State<UniteDropdownButton> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMenu(context),
      child: Row(
        children: [
          Text(widget.controller.value.unit, style: const TextStyle(fontSize: 16),),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          button.localToGlobal(button.size.topRight(Offset.zero), ancestor: overlay),
          button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
        ),
        Offset.zero & overlay.size,
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
      items: MySharedPreferences.unites.map((Unit unite) {
        return PopupMenuItem<Unit>(
          value: unite,
          onTap: () {
            if (widget.onTap != null) widget.onTap!(unite);
            setState(() {
              widget.controller.value = unite;
            });
          },
          child: Text('${unite.fullName} ${unite.unit.isEmpty ? "" : "(${unite.unit})"}'),
        );
      }).toList(),
    );
  }

}
