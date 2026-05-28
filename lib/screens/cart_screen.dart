// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import '../theme/app_theme.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // ── Datos simulados de tarjeta ─────────────────────────────────────────────
  final _cardNumberCtrl = TextEditingController(text: '4242 4242 4242 4242');
  final _cardNameCtrl   = TextEditingController(text: 'USUARIO EJEMPLO');
  final _cardExpCtrl    = TextEditingController(text: '12/27');
  final _cardCvvCtrl    = TextEditingController(text: '123');
  bool _obscureCvv      = true;

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _cardNameCtrl.dispose();
    _cardExpCtrl.dispose();
    _cardCvvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final cart   = context.watch<CartProvider>();

    const shipping = OrdersProvider.shippingCost;
    final subtotal = cart.totalPrice;
    final total    = subtotal + shipping;

    return Scaffold(
      backgroundColor: AppTheme.getBackground(isDark),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      size: 80, color: AppTheme.getTextSecondary(isDark)),
                  const SizedBox(height: 16),
                  Text('Tu carrito está vacío',
                      style: TextStyle(
                          color: AppTheme.getTextPrimary(isDark),
                          fontWeight: FontWeight.w600, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Comienza a añadir productos',
                      style: TextStyle(
                          color: AppTheme.getTextSecondary(isDark),
                          fontSize: 14)),
                ],
              ),
            )
          : Column(
              children: [
                // ── Lista de ítems ─────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ítems del carrito
                        ...cart.items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.getSurfaceCard(isDark),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: AppTheme.getBorder(isDark)),
                                ),
                                child: Row(
                                  children: [
                                    // Imagen del producto
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: AppTheme.getBackground(isDark),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: item.image.isNotEmpty
                                          ? Image.asset(
                                              item.image,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Center(
                                                child: Icon(
                                                  Icons.broken_image_rounded,
                                                  color: AppTheme.getTextSecondary(isDark),
                                                ),
                                              ),
                                            )
                                          : Center(
                                              child: Icon(Icons.image_rounded,
                                                  color: AppTheme.getTextSecondary(isDark)),
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Datos del ítem
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: AppTheme.getTextPrimary(isDark),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14)),
                                          const SizedBox(height: 4),
                                          Container(
                                            width: 20, height: 20,
                                            decoration: BoxDecoration(
                                              color: Color(int.parse(
                                                  item.color.replaceFirst('#', '0xFF'))),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: AppTheme.getBorder(isDark)),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                            style: const TextStyle(
                                                color: AppTheme.accent,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Controles cantidad + eliminar
                                    Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppTheme.getBackground(isDark),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                                color: AppTheme.getBorder(isDark)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _QtyBtn(
                                                icon: Icons.remove_rounded,
                                                isDark: isDark,
                                                onTap: () {
                                                  if (item.quantity > 1) {
                                                    cart.updateQuantity(item.id,
                                                        item.color, item.quantity - 1);
                                                  }
                                                },
                                              ),
                                              Text('${item.quantity}',
                                                  style: TextStyle(
                                                      color: AppTheme.getTextPrimary(isDark),
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 12)),
                                              _QtyBtn(
                                                icon: Icons.add_rounded,
                                                isDark: isDark,
                                                onTap: () => cart.updateQuantity(
                                                    item.id, item.color, item.quantity + 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        IconButton(
                                          icon: Icon(Icons.delete_outline_rounded,
                                              color: AppTheme.error, size: 18),
                                          onPressed: () =>
                                              cart.removeItem(item.id, item.color),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                              minWidth: 32, minHeight: 32),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )),

                        const SizedBox(height: 8),

                        // ── Tarjeta de pago simulada ───────────────────────
                        Text('Método de pago',
                            style: TextStyle(
                                color: AppTheme.getTextPrimary(isDark),
                                fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 12),
                        _CardWidget(
                          numberCtrl: _cardNumberCtrl,
                          nameCtrl:   _cardNameCtrl,
                          expCtrl:    _cardExpCtrl,
                          cvvCtrl:    _cardCvvCtrl,
                          obscureCvv: _obscureCvv,
                          isDark:     isDark,
                          onToggleCvv: () =>
                              setState(() => _obscureCvv = !_obscureCvv),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // ── Footer: resumen + botón ────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  decoration: BoxDecoration(
                    color: AppTheme.getSurfaceCard(isDark),
                    border: Border(
                        top: BorderSide(color: AppTheme.getBorder(isDark))),
                  ),
                  child: Column(
                    children: [
                      // Subtotal
                      _SummaryRow(
                        label: 'Subtotal',
                        value: '\$${subtotal.toStringAsFixed(2)}',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 6),
                      // Costo de envío
                      _SummaryRow(
                        label: 'Envío',
                        value: '\$${shipping.toStringAsFixed(2)}',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      Divider(color: AppTheme.getBorder(isDark), height: 1),
                      const SizedBox(height: 10),
                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total',
                              style: TextStyle(
                                  color: AppTheme.getTextPrimary(isDark),
                                  fontWeight: FontWeight.w700, fontSize: 17)),
                          Text('\$${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.w800, fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Botón proceder al pago
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            // Capturamos los ítems antes de limpiar el carrito
                            final items = List.of(cart.items);
                            await context
                                .read<OrdersProvider>()
                                .placeOrder(items);
                            cart.clearCart();

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: const Text('¡Pedido realizado con éxito! 🎉'),
                              backgroundColor: AppTheme.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Proceder al pago',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ─── Botón de cantidad ────────────────────────────────────────────────────────
class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _QtyBtn({required this.icon, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: AppTheme.getTextPrimary(isDark), size: 16),
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}

// ─── Fila de resumen de precio ────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _SummaryRow(
      {required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: AppTheme.getTextSecondary(isDark), fontSize: 14)),
        Text(value,
            style: TextStyle(
                color: AppTheme.getTextSecondary(isDark),
                fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}

// ─── Widget tarjeta de pago simulada ─────────────────────────────────────────
class _CardWidget extends StatelessWidget {
  final TextEditingController numberCtrl;
  final TextEditingController nameCtrl;
  final TextEditingController expCtrl;
  final TextEditingController cvvCtrl;
  final bool obscureCvv;
  final bool isDark;
  final VoidCallback onToggleCvv;

  const _CardWidget({
    required this.numberCtrl,
    required this.nameCtrl,
    required this.expCtrl,
    required this.cvvCtrl,
    required this.obscureCvv,
    required this.isDark,
    required this.onToggleCvv,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceCard(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Número de tarjeta
          _CardField(
            controller: numberCtrl,
            label: 'Número de tarjeta',
            icon: Icons.credit_card_rounded,
            isDark: isDark,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CardNumberFormatter(),
            ],
          ),
          const SizedBox(height: 12),

          // Nombre del titular
          _CardField(
            controller: nameCtrl,
            label: 'Nombre del titular',
            icon: Icons.person_outline_rounded,
            isDark: isDark,
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 12),

          // Expiración + CVV en fila
          Row(
            children: [
              Expanded(
                child: _CardField(
                  controller: expCtrl,
                  label: 'MM/AA',
                  icon: Icons.calendar_today_outlined,
                  isDark: isDark,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ExpFormatter(),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CardField(
                  controller: cvvCtrl,
                  label: 'CVV',
                  icon: Icons.lock_outline_rounded,
                  isDark: isDark,
                  obscure: obscureCvv,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureCvv
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppTheme.getTextSecondary(isDark), size: 18,
                    ),
                    onPressed: onToggleCvv,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isDark;
  final bool obscure;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final Widget? suffixIcon;

  const _CardField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.isDark,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getBackground(isDark),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.getBorder(isDark)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Icon(icon, color: AppTheme.accent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              textCapitalization: textCapitalization,
              style: TextStyle(
                  color: AppTheme.getTextPrimary(isDark), fontSize: 14),
              decoration: InputDecoration(
                hintText: label,
                hintStyle:
                    TextStyle(color: AppTheme.getTextSecondary(isDark), fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (suffixIcon != null) suffixIcon!,
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ─── Formateadores ────────────────────────────────────────────────────────────

/// Formatea el número de tarjeta como "XXXX XXXX XXXX XXXX"
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    if (digits.length > 16) return oldValue;
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Formatea la fecha de expiración como "MM/AA"
class _ExpFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll('/', '');
    if (digits.length > 4) return oldValue;
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
