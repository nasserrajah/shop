/// Payment methods supported by the storefront.
enum PaymentMethod {
  paypal('PayPal', 'Pay securely with your PayPal account'),
  card('Credit Card', 'Visa, Mastercard and American Express'),
  cash('Cash on Delivery', 'Pay when your order arrives');

  const PaymentMethod(this.label, this.description);

  final String label;
  final String description;

  static PaymentMethod fromName(String value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.name == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}
