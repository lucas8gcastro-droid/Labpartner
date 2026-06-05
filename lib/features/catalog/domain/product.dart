import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/enums.dart';

part 'product.freezed.dart';
part 'product.g.dart';

/// Produto do catálogo (espelha a tabela public.products).
@freezed
class Product with _$Product {
  const Product._();

  const factory Product({
    required String id,
    required String name,
    @JsonKey(name: 'cas_number') String? casNumber,
    required ProductCategory category,
    String? purity,
    String? packaging,
    @JsonKey(name: 'technical_description') String? technicalDescription,
    @Default(0) double price,
    @Default('un') String unit,
    @Default(0) int stock,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  bool get inStock => stock > 0;
}
