import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masarat_alnur/src/features/content/data/content_repository.dart';
import 'package:masarat_alnur/src/features/content/domain/category.dart';
import 'package:masarat_alnur/src/features/content/domain/sub_category.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final ongoingCategoriesAsync = ref.watch(ongoingCategoriesStreamProvider);
    final ongoingSubCategoriesAsync = ref.watch(ongoingSubCategoriesStreamProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // All Categories Section
              _SectionHeader(
                title: l10n.categoriesSectionTitle,
                onShowAll: () => context.push('/categories'),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 180,
                child: categoriesAsync.when(
                  data: (categories) => _CategorySlider(categories: categories),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text('Error: $error'),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Ongoing Categories Section (if any)
              ongoingCategoriesAsync.when(
                data: (categories) => categories.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            title: l10n.ongoingCategoriesSectionTitle,
                            onShowAll: () => context.push('/categories/ongoing'),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 180,
                            child: _CategorySlider(
                              categories: categories,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // Ongoing Sub-Categories Section (if any)
              ongoingSubCategoriesAsync.when(
                data: (subCategories) => subCategories.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            title: l10n.ongoingSubCategoriesSectionTitle,
                            onShowAll: () =>
                                context.push('/subcategories/ongoing'),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 180,
                            child: _SubCategorySlider(
                              subCategories: subCategories,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // Per-Category Sub-Categories Sections
              categoriesAsync.when(
                data: (categories) => Column(
                  children: categories.map((category) {
                    final subCategoriesAsync = ref.watch(
                      subCategoriesStreamProvider(category.id),
                    );
                    return subCategoriesAsync.when(
                      data: (subCategories) => subCategories.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionHeader(
                                  title: category.title_ar,
                                  onShowAll: () => context.push(
                                    '/categories/${category.id}/subcategories',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 180,
                                  child: _SubCategorySlider(
                                    subCategories: subCategories,
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            )
                          : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  }).toList(),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onShowAll;

  const _SectionHeader({
    required this.title,
    required this.onShowAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          TextButton(
            onPressed: onShowAll,
            child: Text(AppLocalizations.of(context)!.showAllButton),
          ),
        ],
      ),
    );
  }
}

class _CategorySlider extends StatelessWidget {
  final List<Category> categories;

  const _CategorySlider({required this.categories});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: InkWell(
            onTap: () => context.push('/categories/${category.id}/subcategories'),
            child: SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: category.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: category.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  _CategoryPlaceholder(),
                            )
                          : _CategoryPlaceholder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.title_ar,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SubCategorySlider extends StatelessWidget {
  final List<SubCategory> subCategories;

  const _SubCategorySlider({required this.subCategories});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: subCategories.length,
      itemBuilder: (context, index) {
        final subCategory = subCategories[index];
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: InkWell(
            onTap: () => context.push(
              '/subcategories/${subCategory.id}/topics',
              extra: subCategory.title_ar,
            ),
            child: SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: subCategory.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: subCategory.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  _SubCategoryPlaceholder(),
                            )
                          : _SubCategoryPlaceholder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subCategory.title_ar,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CategoryPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.category, size: 32),
    );
  }
}

class _SubCategoryPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.folder, size: 32),
    );
  }
}