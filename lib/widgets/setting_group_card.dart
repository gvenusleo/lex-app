import "package:flutter/material.dart";

/// 设置页面左侧面板选项卡
class SettingGroupCard extends StatelessWidget {
  const SettingGroupCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.selected,
  });

  final Widget icon;
  final String title;
  final Function()? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      color: selected ? Theme.of(context).colorScheme.surfaceVariant : null,
      clipBehavior: Clip.hardEdge,
      child: ListTile(
        leading: icon,
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}
