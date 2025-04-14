import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masarat_alnur/src/features/content/data/content_repository.dart';
import 'package:masarat_alnur/src/features/content/domain/sub_category.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SubCategoryListScreen extends ConsumerWidget {
  final String? categoryId;
  final bool ongoingOnly;
  final String? categoryName;

  const SubCategoryListScreen({
    super.key,
    this.categoryId,
    this.categoryName,
    this.ongoingOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    // Watch appropriate stream based on mode
    final subCategoriesAsync = ongoingOnly
        ? ref.watch(ongoingSubCategoriesStreamProvider)
        : categoryId != null
            ? ref.watch(subCategoriesStreamProvider(categoryId!))
            : const AsyncValue<List<SubCategory>>.data([]);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(categoryName ?? l10n.ongoingSubCategoriesSectionTitle),
      ),
      body: subCategoriesAsync.when(
        data: (subCategories) => subCategories.isEmpty 
            ? Center(
                child: Text(
                  ongoingOnly 
                      ? 'لا توجد فئات فرعية قيد التقدم'  // No ongoing subcategories
                      : 'لا توجد فئات فرعية',  // No subcategories
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
                itemCount: subCategories.length,
                itemBuilder: (context, index) {
                  final subCategory = subCategories[index];
                  return _SubCategoryGridItem(subCategory: subCategory);
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

class _SubCategoryGridItem extends StatelessWidget {
  final SubCategory subCategory;

  const _SubCategoryGridItem({required this.subCategory});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/subcategories/${subCategory.id}/topics'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: subCategory.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: subCategory.imageUrl!,
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
                        child: const Icon(Icons.folder, size: 32),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.folder, size: 32),
                    ),
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
    );
  }
}