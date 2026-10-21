class Validators {
  const Validators._();

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? name(String? value) {
    final requiredError = required(value, field: 'Full name');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 3) return 'Please enter at least 3 characters';
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value, field: 'Email');
    if (requiredError != null) return requiredError;
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!regex.hasMatch(value!.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? phone(String? value) {
    final requiredError = required(value, field: 'Phone number');
    if (requiredError != null) return requiredError;
    final digits = value!.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.length < 7) return 'Please enter a valid phone number';
    return null;
  }

  static String? address(String? value) {
    final requiredError = required(value, field: 'Delivery address');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 10) {
      return 'Please enter a complete delivery address';
    }
    return null;
  }

  static String? cardNumber(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\s+'), '');
    if (digits.isEmpty) return 'Card number is required';
    if (!RegExp(r'^\d{16}$').hasMatch(digits)) {
      return 'Enter a valid 16-digit card number';
    }
    return null;
  }

  static String? cardHolder(String? value) {
    return required(value, field: 'Card holder name');
  }

  static String? expiry(String? value) {
    final text = (value ?? '').trim();
    final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(text);
    if (match == null) return 'Use MM/YY format';

    final month = int.tryParse(match.group(1)!) ?? 0;
    final year = 2000 + (int.tryParse(match.group(2)!) ?? 0);
    if (month < 1 || month > 12) return 'Invalid month';

    final now = DateTime.now();
    final expiryDate = DateTime(year, month + 1, 0);
    if (expiryDate.isBefore(DateTime(now.year, now.month, now.day))) {
      return 'This card has expired';
    }
    return null;
  }

  static String? cvv(String? value) {
    if (value == null || !RegExp(r'^\d{3,4}$').hasMatch(value.trim())) {
      return 'Enter a valid CVV';
    }
    return null;
  }
}
