Uri buildUpiPaymentUri({
	required String upiId,
	required String payeeName,
	double? amount,
	String? note,
	String currency = 'INR',
}) {
	final Map<String, String> params = <String, String>{
		'pa': upiId.trim(),
		'pn': payeeName.trim(),
		'cu': currency,
	};

	if (amount != null && amount > 0) {
		params['am'] = amount.toStringAsFixed(2);
	}
	if ((note ?? '').trim().isNotEmpty) {
		params['tn'] = note!.trim();
	}

	return Uri(
		scheme: 'upi',
		host: 'pay',
		queryParameters: params,
	);
}

String buildUpiPaymentUrl({
	required String upiId,
	required String payeeName,
	double? amount,
	String? note,
}) {
	return buildUpiPaymentUri(
		upiId: upiId,
		payeeName: payeeName,
		amount: amount,
		note: note,
	).toString();
}