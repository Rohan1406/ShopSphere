import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/profile/controllers/profile_controllers.dart';
import 'package:shopsphere/features/profile/models/address.dart';
import 'package:shopsphere/features/profile/services/geo_location_service.dart';
import 'package:shopsphere/features/profile/views/widgets/geographic_map_picker.dart';

class AddEditAddressSheet extends StatefulWidget {
  final Address? existing;
  final GeoPoint? prefilledGeoPoint;

  const AddEditAddressSheet({super.key, this.existing, this.prefilledGeoPoint});

  static Future<void> show(
    BuildContext context,
    WidgetRef ref, [
    Address? existing,
    GeoPoint? prefilledGeoPoint,
  ]) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddEditAddressSheet(
        existing: existing,
        prefilledGeoPoint: prefilledGeoPoint,
      ),
    );
  }

  @override
  State<AddEditAddressSheet> createState() => _AddEditAddressSheetState();
}

class _AddEditAddressSheetState extends State<AddEditAddressSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _aptCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _landmarkCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _pincodeCtrl;

  late AddressType _selectedType;
  late bool _isDefault;
  double? _currentLat;
  double? _currentLng;
  String? _currentLocationName;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final prefilled = widget.prefilledGeoPoint;

    _nameCtrl = TextEditingController(
      text: existing?.fullName ?? 'Demo Shopper',
    );
    _phoneCtrl = TextEditingController(
      text: existing?.phone ?? '+91 98765 43210',
    );
    _aptCtrl = TextEditingController(
      text: existing?.apartment ?? prefilled?.apartment ?? '',
    );
    _streetCtrl = TextEditingController(
      text: existing?.streetAddress ?? prefilled?.streetAddress ?? '',
    );
    _landmarkCtrl = TextEditingController(
      text: existing?.landmark ?? prefilled?.landmark ?? '',
    );
    _cityCtrl = TextEditingController(
      text: existing?.city ?? prefilled?.city ?? 'Bengaluru',
    );
    _stateCtrl = TextEditingController(
      text: existing?.state ?? prefilled?.state ?? 'Karnataka',
    );
    _pincodeCtrl = TextEditingController(
      text: existing?.pincode ?? prefilled?.pincode ?? '560038',
    );

    _selectedType = existing?.type ?? AddressType.home;
    _isDefault = existing?.isDefault ?? false;
    _currentLat = existing?.latitude ?? prefilled?.latitude;
    _currentLng = existing?.longitude ?? prefilled?.longitude;
    _currentLocationName = existing?.locationName ?? prefilled?.locationName;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _aptCtrl.dispose();
    _streetCtrl.dispose();
    _landmarkCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) => Container(
        height: MediaQuery.of(context).size.height * 0.90,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.existing == null
                        ? 'Add New Address'
                        : 'Edit Address',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: AppColors.border),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Interactive Geographic Map Picker Action Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.08),
                              AppColors.accent.withValues(alpha: 0.04),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.map_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pinpoint on Geographic Map',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _currentLat != null
                                        ? 'Pinned: ${_currentLat!.toStringAsFixed(4)}° N, ${_currentLng!.toStringAsFixed(4)}° E'
                                        : 'Auto-fill address using live GPS & Map',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _currentLat != null
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                      fontWeight: _currentLat != null
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final point = await GeographicMapPicker.show(
                                  context,
                                  initialLocation: _currentLat != null
                                      ? GeoPoint(
                                          latitude: _currentLat!,
                                          longitude: _currentLng!,
                                          locationName:
                                              _currentLocationName ??
                                              _streetCtrl.text,
                                          streetAddress: _streetCtrl.text,
                                          apartment: _aptCtrl.text,
                                          landmark: _landmarkCtrl.text,
                                          city: _cityCtrl.text,
                                          state: _stateCtrl.text,
                                          pincode: _pincodeCtrl.text,
                                        )
                                      : null,
                                );
                                if (point != null) {
                                  setState(() {
                                    _currentLat = point.latitude;
                                    _currentLng = point.longitude;
                                    _currentLocationName = point.locationName;
                                    _streetCtrl.text = point.streetAddress;
                                    if (point.apartment.isNotEmpty) {
                                      _aptCtrl.text = point.apartment;
                                    }
                                    if (point.landmark.isNotEmpty) {
                                      _landmarkCtrl.text = point.landmark;
                                    }
                                    _cityCtrl.text = point.city;
                                    _stateCtrl.text = point.state;
                                    _pincodeCtrl.text = point.pincode;
                                  });
                                }
                              },
                              icon: const Icon(
                                Icons.my_location_rounded,
                                size: 14,
                              ),
                              label: Text(
                                _currentLat != null ? 'Re-pick' : 'Choose',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Type Selection
                      const Text(
                        'Address Tag',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: AddressType.values.map((type) {
                          final isSel = _selectedType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              avatar: Icon(
                                type.icon,
                                size: 16,
                                color: isSel ? Colors.white : type.color,
                              ),
                              label: Text(type.displayName),
                              selected: isSel,
                              selectedColor: type.color,
                              labelStyle: TextStyle(
                                color: isSel
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                              onSelected: (sel) {
                                if (sel) {
                                  setState(() => _selectedType = type);
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Full Name
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          prefixIcon: Icon(
                            Icons.person_outline_rounded,
                            size: 20,
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Enter recipient name'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Phone
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                          prefixIcon: Icon(Icons.phone_outlined, size: 20),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Enter contact number'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Apartment / Flat / Building
                      TextFormField(
                        controller: _aptCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Flat / House No. / Building (Optional)',
                          prefixIcon: Icon(Icons.apartment_rounded, size: 20),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Street / Area
                      TextFormField(
                        controller: _streetCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Street Address / Area *',
                          prefixIcon: Icon(Icons.map_outlined, size: 20),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Enter street address'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Landmark
                      TextFormField(
                        controller: _landmarkCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Landmark (Optional)',
                          prefixIcon: Icon(Icons.near_me_outlined, size: 20),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // City & State
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cityCtrl,
                              decoration: const InputDecoration(
                                labelText: 'City *',
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Enter city'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _stateCtrl,
                              decoration: const InputDecoration(
                                labelText: 'State *',
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Enter state'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Pincode
                      TextFormField(
                        controller: _pincodeCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Pincode (6-digit) *',
                          prefixIcon: Icon(Icons.pin_drop_outlined, size: 20),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter pincode';
                          }
                          if (v.trim().length < 6) {
                            return 'Enter valid 6-digit pincode';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Default Switch
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Set as Default Delivery Address',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                        value: _isDefault,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) => setState(() => _isDefault = val),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    final newAddress = Address(
                      id: widget.existing?.id ?? '',
                      fullName: _nameCtrl.text.trim(),
                      phone: _phoneCtrl.text.trim(),
                      apartment: _aptCtrl.text.trim(),
                      streetAddress: _streetCtrl.text.trim(),
                      landmark: _landmarkCtrl.text.trim(),
                      city: _cityCtrl.text.trim(),
                      state: _stateCtrl.text.trim(),
                      pincode: _pincodeCtrl.text.trim(),
                      type: _selectedType,
                      isDefault: _isDefault,
                      latitude: _currentLat,
                      longitude: _currentLng,
                      locationName: _currentLocationName,
                    );

                    if (widget.existing == null) {
                      ref
                          .read(addressesControllerProvider.notifier)
                          .addAddress(newAddress);
                    } else {
                      ref
                          .read(addressesControllerProvider.notifier)
                          .updateAddress(newAddress);
                    }

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          widget.existing == null
                              ? 'Address saved with geographic location!'
                              : 'Address updated!',
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.existing == null ? 'Save Address' : 'Update Address',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
