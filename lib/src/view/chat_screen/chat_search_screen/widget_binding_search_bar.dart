import 'dart:developer';

import 'package:chatme/util/constant/app_assets.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WidgetBindingSearchBar extends StatefulWidget {
  WidgetBindingSearchBar({
    Key? key,
    required this.searchController,
    required this.onChange,
    this.onSummit,
    this.hintText = '',
    this.autofocus = false,
  }) : super(key: key);

  final TextEditingController searchController;
  final Function(String)? onChange;
  final VoidCallback? onSummit;
  final String hintText;
  final bool autofocus;

  @override
  State<WidgetBindingSearchBar> createState() => _WidgetBindingSearchBarState();
}

class _WidgetBindingSearchBarState extends State<WidgetBindingSearchBar> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Color(0xffeeeeee),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Form(
        key: _formKey,
        child: TextFormField(
          textInputAction: TextInputAction.done,
          controller: widget.searchController,
          onChanged: ((value) {
            widget.onChange!(value);
          }),
          onEditingComplete: () {
            log(widget.searchController.text, name: 'search');
          },
          autofocus: widget.autofocus,
          onFieldSubmitted: ((value) => widget.onSummit),
          decoration: InputDecoration(
            errorStyle: TextStyle(
              fontSize: 12.0,
            ),
            prefixIcon: Icon(Icons.search),
            contentPadding: EdgeInsets.fromLTRB(0, 14.5, 12, 0),
            suffixIcon: AnimatedOpacity(
              opacity: _showCloseButton() ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: InkWell(
                onTap: _onClear,
                child: Image.asset(
                  Assets.app_assetsIconsSearchCloseButton,
                  scale: 3,
                ),
              ),
            ),
            border: InputBorder.none,
            hintText: widget.hintText.tr,
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  bool _showCloseButton() {
    if (widget.searchController.text.isNotEmpty) return true;
    return false;
  }

  void _onClear() {
    if (widget.searchController.text.isNotEmpty) {
      widget.searchController.clear();
      widget.onChange!('');
      setState(() {});
    }
  }
}
