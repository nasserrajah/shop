enum ProductSortOption {
  featured('Featured'),
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low'),
  topRated('Top Rated');

  const ProductSortOption(this.label);

  final String label;
}
