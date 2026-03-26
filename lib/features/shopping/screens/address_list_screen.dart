import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_snackbar.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/shopping_provider.dart';
import 'add_address_screen.dart';
import 'checkout_screen.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  int? _selectedAddressId;

  final Color primaryColor = const Color(0xFFE91E63);
  final Color secondaryColor = const Color(0xFFF06292);
  final Color backgroundColor = const Color(0xFFF9F6F2);
  final Color textColor = const Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        Provider.of<ShoppingProvider>(
          context,
          listen: false,
        ).fetchAddresses(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final shoppingProvider = Provider.of<ShoppingProvider>(context);
    final addresses = shoppingProvider.addresses;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background Decorative Element
          Positioned(
            top: -50,
            left: -50,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Expanded(
                  child: shoppingProvider.isLoading
                      ? Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        )
                      : addresses.isEmpty
                      ? _buildEmptyAddress()
                      : _buildAddressList(addresses),
                ),
                if (addresses.isNotEmpty) _buildBottomAction(addresses),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
            const SizedBox(height: 8),
            const Text(
              'Select Address',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                fontFamily: 'Serif',
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAddressScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.add_location_alt_outlined,
              color: primaryColor,
              size: 22,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildEmptyAddress() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
              ),
            ],
          ),
          child: Icon(
            Icons.location_on_outlined,
            size: 60,
            color: primaryColor.withValues(alpha: 0.2),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'No destinations found',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Serif',
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAddressScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Text(
              'ADD NEW ADDRESS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildAddressList(List<dynamic> addresses) => ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
    itemCount: addresses.length,
    itemBuilder: (context, index) {
      final address = addresses[index];
      final isSelected =
          _selectedAddressId == address.id ||
          (index == 0 && _selectedAddressId == null);
      if (isSelected && _selectedAddressId == null) {
        _selectedAddressId = address.id;
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: GestureDetector(
          onTap: () => setState(() => _selectedAddressId = address.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? primaryColor : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? primaryColor.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.02),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isSelected ? primaryColor : Colors.black12,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          address.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildActionIcon(
                          Icons.edit_outlined,
                          Colors.blue.shade400,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddAddressScreen(address: address),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildActionIcon(
                          Icons.delete_outline_rounded,
                          primaryColor.withValues(alpha: 0.7),
                          () async {
                            final bool? confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Address'),
                                content: const Text(
                                  'Are you sure you want to remove this destination?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('CANCEL'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text(
                                      'DELETE',
                                      style: TextStyle(color: primaryColor),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && mounted) {
                              final token = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              ).token;
                              if (token != null) {
                                final success =
                                    await Provider.of<ShoppingProvider>(
                                      context,
                                      listen: false,
                                    ).deleteAddress(token, address.id);
                                if (success && mounted) {
                                  AppSnackBar.show(
                                    context,
                                    message: 'Address removed successfully',
                                    type: SnackBarType.success,
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                if (address.isDefault)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'DEFAULT DESTINATION',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  address.phone,
                  style: const TextStyle(
                    color: Colors.black38,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${address.addressLine1}, ${address.addressLine2 != null ? address.addressLine2! + ', ' : ''}${address.city}, ${address.state} - ${address.pincode}',
                  style: TextStyle(
                    height: 1.5,
                    color: Colors.black.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      );

  Widget _buildBottomAction(List<dynamic> addresses) => Container(
    padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
    decoration: BoxDecoration(
      color: backgroundColor,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: GestureDetector(
      onTap: () {
        final shoppingProvider = Provider.of<ShoppingProvider>(
          context,
          listen: false,
        );
        final address = shoppingProvider.addresses.firstWhere(
          (a) => a.id == _selectedAddressId,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CheckoutScreen(address: address)),
        );
      },
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
        child: const Center(
          child: Text(
            'CONTINUE TO CHECKOUT',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 14,
            ),
          ),
        ),
      ),
    ),
  );
}
