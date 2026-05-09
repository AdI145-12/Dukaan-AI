import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_shadows.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/khata/domain/khata_entry.dart';
import 'package:dukaan_ai/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter/material.dart';

class KhataEntryCard extends StatelessWidget {
	const KhataEntryCard({
		super.key,
		required this.entry,
		required this.onSendReminder,
		required this.onMarkPaid,
		required this.onDelete,
		required this.onEditAmount,
	});

	final KhataEntry entry;
	final VoidCallback onSendReminder;
	final VoidCallback onMarkPaid;
	final VoidCallback onDelete;
	final VoidCallback onEditAmount;

	static const List<Color> _avatarPalette = <Color>[
		Color(0xFFEF5350),
		Color(0xFFFF7043),
		Color(0xFFFFCA28),
		Color(0xFF66BB6A),
		Color(0xFF42A5F5),
		Color(0xFFAB47BC),
	];

	static Color _avatarColor(String name) {
		if (name.isEmpty) {
			return _avatarPalette.first;
		}
		return _avatarPalette[name.codeUnits.first % _avatarPalette.length];
	}

	@override
	Widget build(BuildContext context) {
		final String initials =
				entry.customerName.isNotEmpty ? entry.customerName[0].toUpperCase() : '?';
		final bool isCredit = entry.type == 'credit';
		final Color amountColor = isCredit ? AppColors.khataDebit : AppColors.khataCredit;

		return RepaintBoundary(
			child: GestureDetector(
				onLongPress: () => _showActionSheet(context),
				child: Container(
					margin: const EdgeInsets.symmetric(
						horizontal: AppSpacing.md,
						vertical: AppSpacing.xs,
					),
					padding: const EdgeInsets.all(AppSpacing.md),
					decoration: BoxDecoration(
						color: AppColors.surface,
						borderRadius: BorderRadius.circular(AppRadius.card),
						boxShadow: AppShadows.card,
					),
					child: Row(
						children: <Widget>[
							CircleAvatar(
								radius: 22,
								backgroundColor: _avatarColor(entry.customerName),
								child: Text(
									initials,
									style: AppTypography.labelLarge.copyWith(color: AppColors.surface),
								),
							),
							const SizedBox(width: AppSpacing.md),
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: <Widget>[
										Text(
											entry.customerName,
											style: AppTypography.bodyLarge.copyWith(
												fontWeight: FontWeight.w600,
											),
											maxLines: 1,
											overflow: TextOverflow.ellipsis,
										),
										if (entry.customerPhone != null && entry.customerPhone!.isNotEmpty)
											Text(
												entry.customerPhone!,
												style: AppTypography.bodyMedium.copyWith(
													color: AppColors.textSecondary,
												),
											),
									],
								),
							),
							Text(
								'₹${entry.amount.toStringAsFixed(0)}',
								style: AppTypography.headlineMedium.copyWith(
									color: amountColor,
									fontWeight: FontWeight.w700,
								),
							),
						],
					),
				),
			),
		);
	}

	Future<void> _showActionSheet(BuildContext context) {
		return AppBottomSheet.show<void>(
			context: context,
			title: entry.customerName,
			child: Column(
				mainAxisSize: MainAxisSize.min,
				children: <Widget>[
					_ActionTile(
						icon: Icons.edit_rounded,
						iconColor: AppColors.primary,
						label: AppStrings.editAmountAction,
						onTap: onEditAmount,
					),
					_ActionTile(
						icon: Icons.chat_rounded,
						iconColor: const Color(0xFF25D366),
						label: AppStrings.sendReminderAction,
						onTap: onSendReminder,
					),
					_ActionTile(
						icon: Icons.check_circle_rounded,
						iconColor: AppColors.success,
						label: AppStrings.markPaidAction,
						onTap: onMarkPaid,
					),
					_ActionTile(
						icon: Icons.delete_rounded,
						iconColor: AppColors.error,
						label: AppStrings.deleteEntryAction,
						onTap: onDelete,
					),
				],
			),
		);
	}
}

class _ActionTile extends StatelessWidget {
	const _ActionTile({
		required this.icon,
		required this.iconColor,
		required this.label,
		required this.onTap,
	});

	final IconData icon;
	final Color iconColor;
	final String label;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return ListTile(
			contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
			leading: Icon(icon, color: iconColor),
			title: Text(label, style: AppTypography.bodyLarge),
			onTap: () {
				Navigator.of(context).pop();
				onTap();
			},
		);
	}
}