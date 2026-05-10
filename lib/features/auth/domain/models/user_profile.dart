/// Auth profile persisted in `profiles/{uid}`.
class UserProfile {
	const UserProfile({
		required this.id,
		this.email,
		this.displayName,
		this.photoUrl,
		this.createdAt,
		this.onboardingComplete = false,
	});

	final String id;
	final String? email;
	final String? displayName;
	final String? photoUrl;
	final DateTime? createdAt;
	final bool onboardingComplete;

	/// Builds a profile from Firestore JSON data.
	factory UserProfile.fromJson(Map<String, dynamic> json) {
		return UserProfile(
			id: json['id'] as String? ?? '',
			email: json['email'] as String?,
			displayName: json['displayName'] as String?,
			photoUrl: json['photoUrl'] as String?,
			createdAt: _readDateTime(json['createdAt']),
			onboardingComplete: json['onboardingComplete'] as bool? ?? false,
		);
	}

	/// Serializes this profile to a JSON map.
	Map<String, dynamic> toJson() {
		return <String, dynamic>{
			'id': id,
			if (email != null) 'email': email,
			if (displayName != null) 'displayName': displayName,
			if (photoUrl != null) 'photoUrl': photoUrl,
			if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
			'onboardingComplete': onboardingComplete,
		};
	}

	/// Returns a copy of this profile with selected fields replaced.
	UserProfile copyWith({
		String? id,
		String? email,
		String? displayName,
		String? photoUrl,
		DateTime? createdAt,
		bool? onboardingComplete,
	}) {
		return UserProfile(
			id: id ?? this.id,
			email: email ?? this.email,
			displayName: displayName ?? this.displayName,
			photoUrl: photoUrl ?? this.photoUrl,
			createdAt: createdAt ?? this.createdAt,
			onboardingComplete: onboardingComplete ?? this.onboardingComplete,
		);
	}

	static DateTime? _readDateTime(Object? value) {
		if (value is DateTime) {
			return value;
		}
		if (value is String) {
			return DateTime.tryParse(value);
		}
		try {
			final dynamic timestamp = value;
			final dynamic asDate = timestamp?.toDate?.call();
			if (asDate is DateTime) {
				return asDate;
			}
		} catch (_) {
			return null;
		}
		return null;
	}

	@override
	bool operator ==(Object other) {
		return identical(this, other) ||
				other is UserProfile &&
					id == other.id &&
					email == other.email &&
					displayName == other.displayName &&
					photoUrl == other.photoUrl &&
					createdAt == other.createdAt &&
					onboardingComplete == other.onboardingComplete;
	}

	@override
	int get hashCode {
		return Object.hash(id, email, displayName, photoUrl, createdAt, onboardingComplete);
	}
}// @freezed: id, shopName, tier, credits