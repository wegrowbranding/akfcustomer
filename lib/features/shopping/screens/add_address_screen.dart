import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/shopping_models.dart';
import '../providers/shopping_provider.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key, this.address});
  final Address? address;

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  late TextEditingController _countryController;
  late bool _isDefault;

  final Color primaryColor = const Color(0xFFE91E63);
  final Color secondaryColor = const Color(0xFFF06292);
  final Color backgroundColor = const Color(0xFFF9F6F2);
  final Color textColor = const Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?.name);
    _phoneController = TextEditingController(text: widget.address?.phone);
    _address1Controller = TextEditingController(
      text: widget.address?.addressLine1,
    );
    _address2Controller = TextEditingController(
      text: widget.address?.addressLine2,
    );
    _cityController = TextEditingController(text: widget.address?.city);
    _stateController = TextEditingController(text: widget.address?.state);
    _pincodeController = TextEditingController(text: widget.address?.pincode);
    _countryController = TextEditingController(
      text: widget.address?.country ?? 'India',
    );
    _isDefault = widget.address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final shoppingProvider = Provider.of<ShoppingProvider>(
        context,
        listen: false,
      );

      if (token != null) {
        final address = Address(
          id: widget.address?.id ?? 0,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          addressLine1: _address1Controller.text.trim(),
          addressLine2: _address2Controller.text.trim().isEmpty
              ? null
              : _address2Controller.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          pincode: _pincodeController.text.trim(),
          country: _countryController.text.trim(),
          isDefault: _isDefault,
        );

        bool success;
        if (widget.address == null) {
          success = await shoppingProvider.addAddress(token, address);
        } else {
          success = await shoppingProvider.editAddress(
            token,
            widget.address!.id,
            address,
          );
        }

        if (success && mounted) {
          Navigator.pop(context);
          AppSnackBar.show(
            context,
            message: widget.address == null
                ? 'Address saved'
                : 'Address updated',
            type: SnackBarType.success,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: backgroundColor,
    body: Stack(
      children: [
        // Background Decorative Element
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.03),
              shape: BoxShape.circle,
            ),
          ),
        ),

        SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildSectionLabel('RECIPIENT IDENTITY'),
                        const SizedBox(height: 12),
                        _buildField(
                          _nameController,
                          'Full Name',
                          Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          _phoneController,
                          'Phone Number',
                          Icons.phone_android_rounded,
                          keyboardType: TextInputType.phone,
                          validator: (val) => val == null || val.isEmpty
                              ? 'Required'
                              : val.length != 10
                              ? 'Invalid phone number'
                              : null,
                        ),

                        const SizedBox(height: 32),
                        _buildSectionLabel('DELIVERY DESTINATION'),
                        const SizedBox(height: 12),
                        _buildField(
                          _address1Controller,
                          'Address Line 1',
                          Icons.location_city_rounded,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          _address2Controller,
                          'Address Line 2 (Optional)',
                          Icons.location_on_rounded,
                          isRequired: false,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                _cityController,
                                'City',
                                Icons.map_rounded,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildField(
                                _stateController,
                                'State',
                                Icons.explore_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                _pincodeController,
                                'Pincode',
                                Icons.pin_drop_rounded,
                                keyboardType: TextInputType.number,
                                validator: (val) => val == null || val.isEmpty
                                    ? 'Required'
                                    : val.length != 6
                                    ? 'Invalid pincode'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildField(
                                _countryController,
                                'Country',
                                Icons.flag_rounded,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        _buildDefaultToggle(),

                        const SizedBox(height: 48),
                        _buildSubmitButton(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildHeader(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 24, 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              StringConstants.appName,
              style: TextStyle(
                letterSpacing: 4,
                fontWeight: FontWeight.w800,
                fontSize: 10,
                color: Colors.black54,
              ),
            ),
            Text(
              widget.address == null ? 'New Address' : 'Edit Address',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                fontFamily: 'Serif',
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildSectionLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 11,
      letterSpacing: 2,
      fontWeight: FontWeight.w800,
      color: Colors.black38,
    ),
  );

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isRequired = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(
          color: Colors.black.withValues(alpha: 0.2),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: primaryColor, size: 20),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
      ),
      validator:
          validator ??
          (val) =>
              isRequired && (val == null || val.isEmpty) ? 'Required' : null,
    ),
  );

  Widget _buildDefaultToggle() => GestureDetector(
    onTap: () => setState(() => _isDefault = !_isDefault),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _isDefault ? primaryColor.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isDefault
              ? primaryColor.withValues(alpha: 0.2)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isDefault
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: _isDefault ? primaryColor : Colors.black12,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Set as Default Destination',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildSubmitButton() => GestureDetector(
    onTap: _submit,
    child: Container(
      height: 65,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.address == null ? 'SAVE ADDRESS' : 'UPDATE ADDRESS',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
      ),
    ),
  );
}
