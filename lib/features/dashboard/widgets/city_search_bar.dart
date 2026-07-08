import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/city_model.dart';
import '../../../providers/city_search_provider.dart';

class CitySearchBar extends ConsumerStatefulWidget {
  final void Function(CityResult city) onCitySelected;
  final String tag;
  const CitySearchBar({super.key, required this.onCitySelected, required this.tag});

  @override
  ConsumerState<CitySearchBar> createState() => _CitySearchBarState();
}

class _CitySearchBarState extends ConsumerState<CitySearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(citySearchProvider(widget.tag));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search city…',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: searchState.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : (_controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _controller.clear();
                          ref.read(citySearchProvider(widget.tag).notifier).clear();
                          setState(() {});
                        },
                      )
                    : null),
          ),
          onChanged: (value) {
            setState(() {});
            ref.read(citySearchProvider(widget.tag).notifier).onQueryChanged(value);
          },
        ),
        if (searchState.failure != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              searchState.failure!.message,
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
            ),
          ),
        if (searchState.results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 260),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: searchState.results.length,
              itemBuilder: (context, i) {
                final city = searchState.results[i];
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(city.displayName),
                  onTap: () {
                    _controller.clear();
                    _focusNode.unfocus();
                    ref.read(citySearchProvider(widget.tag).notifier).clear();
                    widget.onCitySelected(city);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
