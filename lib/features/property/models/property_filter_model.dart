class PropertyFilterModel {
  final String? propertyType; // 'dorm', 'room', 'apartment', 'house'
  final double minPrice;
  final double maxPrice;
  final int? beds; // null means 'Any'
  final String? searchQuery;

  const PropertyFilterModel({
    this.propertyType,
    this.minPrice = 10,
    this.maxPrice = 800,
    this.beds,
    this.searchQuery,
  });

  PropertyFilterModel copyWith({
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    int? beds,
    String? searchQuery,
    bool clearPropertyType = false,
    bool clearBeds = false,
    bool clearSearchQuery = false,
  }) {
    return PropertyFilterModel(
      propertyType: clearPropertyType
          ? null
          : propertyType ?? this.propertyType,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      beds: clearBeds ? null : beds ?? this.beds,
      searchQuery: clearSearchQuery ? null : searchQuery ?? this.searchQuery,
    );
  }

  bool get hasActiveFilters {
    return propertyType != null ||
        minPrice != 10 ||
        maxPrice != 800 ||
        beds != null;
  }

  PropertyFilterModel reset() {
    return const PropertyFilterModel();
  }
}
