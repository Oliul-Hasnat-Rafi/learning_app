import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:language_learning_app/app/models/language_model.dart';
import 'package:language_learning_app/app/view/widget/button_3.dart';
import 'package:language_learning_app/app/view/widget/card.dart';
import 'package:language_learning_app/app/view/widget/custom_animated_size_widget.dart';
import 'package:language_learning_app/app/view/widget/title_text.dart.dart';
import 'package:language_learning_app/app/utils/components.dart';
import '../../controllers/view_controller/languages_controller.dart';

class LanguagesView
    extends
        StatelessWidget {
  LanguagesView({
    super.key,
  });

  final LanguagesController _controller = Get.put(
    LanguagesController(),
  );
  final TextEditingController _searchController =
      TextEditingController();
  final RxString _searchQuery =
      ''.obs;
  final RxBool _isSearching =
      false.obs;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: _buildAppBar(
        context,
      ),
      body: _buildBody(
        context,
      ),
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
  ) {
    return AppBar(
      title: const SubtitleText(
        string:
            'Choose a Language',
        color:
            Colors.white,
      ),
      actions: [
        Button3(
          onTap: () {
            _isSearching.value = !_isSearching.value;
            if (_isSearching.value) {
              _searchController.clear();
              _searchQuery.value = '';
            }
          },
          child: const Icon(
            Icons.search,
            color:
                Colors.white,
          ),
        ),
      ],
      centerTitle:
          true,
      backgroundColor:
          Theme.of(
            context,
          ).colorScheme.primary,
    );
  }

  Widget _buildBody(
    BuildContext context,
  ) {
    return Obx(
      () {
        if (_controller.isLoading.value) {
          return const LinearProgressIndicator();
        }

        if (_controller.languages.isEmpty) {
          return const Center(
            child: TitleText(
              'No languages available',
            ),
          );
        }

        return Column(
          children: [
            CustomAnimatedSize(
              child:
                  _isSearching.value
                      ? _buildSearchBar(
                        context,
                      )
                      : const SizedBox.shrink(),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.all(
                  defaultPadding /
                      2,
                ),
                child: _buildLanguageGrid(
                  context,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
  ) {
    return Padding(
      padding: EdgeInsets.all(
        defaultPadding /
            2,
      ),
      child: TextField(
        controller:
            _searchController,
        decoration: InputDecoration(
          hintText:
              'Search languages...',
          prefixIcon: const Icon(
            Icons.search,
          ),
          suffixIcon: Obx(
            () =>
                _searchQuery.value.isNotEmpty
                    ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _searchQuery.value = '';
                      },
                    )
                    : const SizedBox.shrink(),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              defaultBorderRadius,
            ),
            borderSide: BorderSide(
              color:
                  Theme.of(
                    context,
                  ).colorScheme.primary,
            ),
          ),
          filled:
              true,
          fillColor:
              Theme.of(
                context,
              ).colorScheme.surface,
        ),
        onChanged: (
          value,
        ) {
          _searchQuery.value = value;
        },
      ),
    );
  }

  Widget _buildLanguageGrid(
    BuildContext context,
  ) {
    final List<
      LanguageModel
    >
    filteredLanguages =
        _searchQuery.value.isEmpty
            ? _controller.languages
            : _controller.languages
                .where(
                  (
                    language,
                  ) =>
                      language.name.toLowerCase().contains(
                        _searchQuery.value.toLowerCase(),
                      ) ||
                      language.description.toLowerCase().contains(
                        _searchQuery.value.toLowerCase(),
                      ),
                )
                .toList();

    if (filteredLanguages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size:
                  MediaQuery.of(
                    context,
                  ).size.width *
                  0.15,
              color: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(
                0.5,
              ),
            ),
            SizedBox(
              height:
                  defaultPadding /
                  2,
            ),
            Text(
              'No languages match your search',
              style:
                  Theme.of(
                    context,
                  ).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            2,
        childAspectRatio:
            0.85,
        crossAxisSpacing:
            defaultPadding /
            2,
        mainAxisSpacing:
            defaultPadding /
            2,
      ),
      itemCount:
          filteredLanguages.length,
      itemBuilder: (
        context,
        index,
      ) {
        return _buildLanguageCard(
          filteredLanguages[index],
          context,
        );
      },
    );
  }

  Widget _buildLanguageCard(
    LanguageModel language,
    BuildContext context,
  ) {
    final theme = Theme.of(
      context,
    );
    final screenWidth =
        MediaQuery.of(
          context,
        ).size.width;

    return InkWell(
      onTap:
          () => _controller.selectLanguage(
            language.id,
          ),
      child: CustomCard(
        child: Padding(
          padding: EdgeInsets.all(
            defaultPadding /
                4,
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius:
                    screenWidth *
                    0.08,
                backgroundImage: AssetImage(
                  language.flagUrl,
                ),
              ),
              SizedBox(
                height:
                    defaultPadding /
                    4,
              ),
              FittedBox(
                fit:
                    BoxFit.scaleDown,
                child: Text(
                  language.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height:
                    defaultPadding /
                    4,
              ),
              Expanded(
                child: Text(
                  language.description,
                  textAlign:
                      TextAlign.center,
                  maxLines:
                      3,
                  overflow:
                      TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(
                      0.7,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
