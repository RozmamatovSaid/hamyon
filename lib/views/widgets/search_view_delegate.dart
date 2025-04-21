import 'package:flutter/material.dart';
import 'package:hamyon/models/wallet_model.dart';

class SearchViewDelegate extends SearchDelegate<List<WalletModel>> {
  final List<WalletModel> data;

  SearchViewDelegate(this.data);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, []);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList =
        query.isEmpty
            ? data
            : data.where((element) {
              if (element.title.toLowerCase().contains(query.toLowerCase()) ||
                  element.cost.toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  element.date.toString().toLowerCase().contains(
                    query.toLowerCase(),
                  )) {
                return true;
              }
              return false;
            }).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder:
          (context, index) => ListTile(
            onTap: () {
              close(context, suggestionList);
            },
            title: Text(
              suggestionList[index].title,
              style: TextStyle(fontSize: 20),
            ),
            subtitle: Text("${suggestionList[index].date}"),
            trailing: Text("${suggestionList[index].cost}"),
          ),
    );
  }
}
