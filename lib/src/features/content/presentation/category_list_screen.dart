import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masarat_alnur/src/features/content/data/content_repository.dart';
import 'package:masarat_alnur/src/features/content/domain/category.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoryListScreen extends ConsumerWidget {
  final bool ongoingOnly;

  const CategoryListScreen({
    super.key,
    this.ongoingOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ongoingOnly 
        ? ref.watch(ongoingCategoriesStreamProvider)
        : ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.categoriesSectionTitle),
      ),
      body: categoriesAsync.when(
        data: (categories) => categories.isEmpty 
            ? Center(
                child: Text(
                  ongoingOnly 
                      ? 'لا توجد فئات قيد التقدم'  // No ongoing categories
                      : 'لا توجد فئات',  // No categories
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _CategoryGridItem(category: category);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

class _CategoryGridItem extends StatelessWidget {
  final Category category;

  const _CategoryGridItem({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/categories/${category.id}/subcategories'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: category.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: category.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.category, size: 32),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.category, size: 32),
                    ),
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
    );
  }
}