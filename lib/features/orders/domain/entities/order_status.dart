enum OrderStatus {
  active('Active'),
  completed('Completed'),
  cancelled('Cancelled');

  const OrderStatus(this.label);

  final String label;

  static OrderStatus fromName(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.name == value.toLowerCase(),
      orElse: () => OrderStatus.active,
    );
  }
}
