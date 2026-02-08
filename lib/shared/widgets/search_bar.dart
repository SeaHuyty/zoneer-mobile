import 'package:flutter/material.dart';

class SearchBarApp extends StatefulWidget {
  const SearchBarApp({super.key});

  @override
  State<SearchBarApp> createState() => _SearchBarAppState();
}

class _SearchBarAppState extends State<SearchBarApp> {

  @override
  Widget build(BuildContext context) {

    return SearchAnchor(
      dividerColor: Colors.grey.shade300,
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          controller: controller,
          hintText: "Search properties...",
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          elevation: const WidgetStatePropertyAll<double>(0),
          shadowColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
          onTap: () {
            controller.openView();
          },
          onChanged: (_) {
            controller.openView();
          },
          leading: const Icon(Icons.search),
          trailing: <Widget>[
            Tooltip(
              message: 'filter',
              child: IconButton(
                // isSelected: () {},
                onPressed: () {},
                icon: const Icon(Icons.filter_list),
                selectedIcon: const Icon(Icons.filter_list),
              ),
            ),
          ],
        );
      },
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        return List<ListTile>.generate(5, (int index) {
          final String item = 'item $index';
          return ListTile(
            title: Text(item),
            onTap: () {
              setState(() {
                controller.closeView(item);
              });
            },
          );
        });
      },
    );
  }
}