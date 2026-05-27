// lib/screens/employees_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

// ─── Modelo ──────────────────────────────────────────────────────────────────

class Employee {
  final String id;
  String name;
  String email;
  String phone;
  String role;
  String department;
  bool isActive;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.department,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'department': department,
        'isActive': isActive,
      };

  factory Employee.fromJson(Map<String, dynamic> j) => Employee(
        id: j['id'] as String,
        name: j['name'] as String,
        email: j['email'] as String,
        phone: j['phone'] as String,
        role: j['role'] as String,
        department: j['department'] as String,
        isActive: j['isActive'] as bool? ?? true,
      );
}

// ─── Provider ────────────────────────────────────────────────────────────────

class EmployeesProvider extends ChangeNotifier {
  static const _kKey = 'employees_list';

  final List<Employee> _employees = [];
  List<Employee> get employees => List.unmodifiable(_employees);

  EmployeesProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kKey);
      if (raw != null) {
        final List decoded = jsonDecode(raw) as List;
        _employees.addAll(
          decoded.map((e) => Employee.fromJson(e as Map<String, dynamic>)),
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kKey, jsonEncode(_employees.map((e) => e.toJson()).toList()));
  }

  Future<void> addEmployee(Employee emp) async {
    _employees.add(emp);
    notifyListeners();
    await _save();
  }

  Future<void> updateEmployee(Employee updated) async {
    final i = _employees.indexWhere((e) => e.id == updated.id);
    if (i != -1) {
      _employees[i] = updated;
      notifyListeners();
      await _save();
    }
  }

  Future<void> toggleActive(String id) async {
    final i = _employees.indexWhere((e) => e.id == id);
    if (i != -1) {
      _employees[i].isActive = !_employees[i].isActive;
      notifyListeners();
      await _save();
    }
  }

  Future<void> deleteEmployee(String id) async {
    _employees.removeWhere((e) => e.id == id);
    notifyListeners();
    await _save();
  }
}

// ─── Pantalla principal ───────────────────────────────────────────────────────

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  String _search = '';
  String _filterDept = 'Todos';

  static const _departments = [
    'Todos',
    'Ventas',
    'Almacén',
    'Administración',
    'Atención al cliente',
  ];

  static const _roles = [
    'Vendedor/a',
    'Encargado/a de almacén',
    'Administrador/a',
    'Cajero/a',
    'Atención al cliente',
    'Gerente',
  ];

  List<Employee> _filtered(List<Employee> all) {
    return all.where((e) {
      final matchSearch = _search.isEmpty ||
          e.name.toLowerCase().contains(_search.toLowerCase()) ||
          e.email.toLowerCase().contains(_search.toLowerCase());
      final matchDept =
          _filterDept == 'Todos' || e.department == _filterDept;
      return matchSearch && matchDept;
    }).toList();
  }

  void _openForm({Employee? employee}) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final provider = context.read<EmployeesProvider>();
    final isEdit = employee != null;

    final nameCtrl = TextEditingController(text: employee?.name ?? '');
    final emailCtrl = TextEditingController(text: employee?.email ?? '');
    final phoneCtrl = TextEditingController(text: employee?.phone ?? '');
    String selectedRole = employee?.role ?? _roles.first;
    String selectedDept = employee?.department ?? _departments[1];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.getSurfaceCard(isDark),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppTheme.getBorder(isDark),
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(isEdit ? 'Editar empleado' : 'Dar de alta empleado',
                    style: TextStyle(
                        color: AppTheme.getTextPrimary(isDark),
                        fontWeight: FontWeight.w800,
                        fontSize: 20)),
                const SizedBox(height: 24),
                _Field(
                    controller: nameCtrl,
                    label: 'Nombre completo',
                    icon: Icons.person_outline_rounded,
                    isDark: isDark),
                const SizedBox(height: 14),
                _Field(
                    controller: emailCtrl,
                    label: 'Correo electrónico',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    isDark: isDark),
                const SizedBox(height: 14),
                _Field(
                    controller: phoneCtrl,
                    label: 'Teléfono',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    isDark: isDark),
                const SizedBox(height: 14),
                _Dropdown(
                  label: 'Puesto',
                  icon: Icons.work_outline_rounded,
                  value: selectedRole,
                  items: _roles,
                  isDark: isDark,
                  onChanged: (v) => setModal(() => selectedRole = v!),
                ),
                const SizedBox(height: 14),
                _Dropdown(
                  label: 'Departamento',
                  icon: Icons.business_outlined,
                  value: selectedDept,
                  items: _departments.skip(1).toList(),
                  isDark: isDark,
                  onChanged: (v) => setModal(() => selectedDept = v!),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('Nombre y correo son obligatorios'),
                          backgroundColor: AppTheme.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ));
                        return;
                      }
                      if (isEdit) {
                        await provider.updateEmployee(Employee(
                          id: employee!.id,
                          name: nameCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          role: selectedRole,
                          department: selectedDept,
                          isActive: employee.isActive,
                        ));
                      } else {
                        await provider.addEmployee(Employee(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          role: selectedRole,
                          department: selectedDept,
                        ));
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(isEdit
                              ? 'Empleado actualizado'
                              : 'Empleado dado de alta'),
                          backgroundColor: AppTheme.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(isEdit ? 'Guardar cambios' : 'Dar de alta',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return ChangeNotifierProvider(
      create: (_) => EmployeesProvider(),
      child: Consumer<EmployeesProvider>(
        builder: (context, provider, _) {
          final list = _filtered(provider.employees);

          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: AppTheme.getBackground(isDark),
              body: Column(
                children: [
                  // ── Barra de búsqueda + filtro ───────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.getSurfaceCard(isDark),
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: AppTheme.getBorder(isDark)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search_rounded,
                                  color: AppTheme.getTextSecondary(isDark),
                                  size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  style: TextStyle(
                                      color:
                                          AppTheme.getTextPrimary(isDark)),
                                  onChanged: (v) =>
                                      setState(() => _search = v),
                                  decoration: InputDecoration(
                                    hintText: 'Buscar empleado...',
                                    hintStyle: TextStyle(
                                        color: AppTheme.getTextSecondary(
                                            isDark)),
                                    border: InputBorder.none,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _departments.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final dept = _departments[i];
                              final isActive = dept == _filterDept;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _filterDept = dept),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppTheme.accent
                                        : AppTheme.getSurfaceCard(isDark),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: isActive
                                            ? AppTheme.accent
                                            : AppTheme.getBorder(isDark)),
                                  ),
                                  child: Text(dept,
                                      style: TextStyle(
                                          color: isActive
                                              ? Colors.black
                                              : AppTheme.getTextSecondary(
                                                  isDark),
                                          fontWeight: isActive
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          fontSize: 13)),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),

                  // ── Lista de empleados ───────────────────────────────────
                  Expanded(
                    child: list.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline_rounded,
                                    size: 64,
                                    color:
                                        AppTheme.getTextSecondary(isDark)),
                                const SizedBox(height: 12),
                                Text('Sin empleados',
                                    style: TextStyle(
                                        color:
                                            AppTheme.getTextPrimary(isDark),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16)),
                                const SizedBox(height: 6),
                                Text('Presiona + para dar de alta',
                                    style: TextStyle(
                                        color: AppTheme.getTextSecondary(
                                            isDark),
                                        fontSize: 13)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding:
                                const EdgeInsets.fromLTRB(20, 4, 20, 100),
                            itemCount: list.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) =>
                                _EmployeeCard(
                              employee: list[i],
                              isDark: isDark,
                              onEdit: () => _openForm(employee: list[i]),
                              onToggle: () => provider
                                  .toggleActive(list[i].id),
                              onDelete: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor:
                                        AppTheme.getSurfaceCard(isDark),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18)),
                                    title: Text('Eliminar empleado',
                                        style: TextStyle(
                                            color: AppTheme.getTextPrimary(
                                                isDark),
                                            fontWeight: FontWeight.w700)),
                                    content: Text(
                                        '¿Deseas eliminar a ${list[i].name}?',
                                        style: TextStyle(
                                            color:
                                                AppTheme.getTextSecondary(
                                                    isDark))),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: Text('Cancelar',
                                            style: TextStyle(
                                                color:
                                                    AppTheme.getTextSecondary(
                                                        isDark))),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Eliminar',
                                            style: TextStyle(
                                                color: Color(0xFFFCA5A5),
                                                fontWeight:
                                                    FontWeight.w700)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await provider.deleteEmployee(list[i].id);
                                }
                              },
                            ),
                          ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => _openForm(),
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.black,
                icon: const Icon(Icons.person_add_rounded),
                label: const Text('Nuevo empleado',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Card de empleado ─────────────────────────────────────────────────────────

class _EmployeeCard extends StatelessWidget {
  final Employee employee;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _EmployeeCard({
    required this.employee,
    required this.isDark,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceCard(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.getBorder(isDark)),
      ),
      child: Row(
        children: [
          // Avatar con inicial
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                employee.name.isNotEmpty
                    ? employee.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(employee.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppTheme.getTextPrimary(isDark),
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: employee.isActive
                            ? AppTheme.success.withOpacity(0.15)
                            : AppTheme.error.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        employee.isActive ? 'Activo' : 'Inactivo',
                        style: TextStyle(
                            color: employee.isActive
                                ? AppTheme.success
                                : AppTheme.error,
                            fontWeight: FontWeight.w600,
                            fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(employee.role,
                    style: TextStyle(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
                const SizedBox(height: 2),
                Text(employee.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppTheme.getTextSecondary(isDark),
                        fontSize: 12)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            color: AppTheme.getSurfaceCard(isDark),
            icon: Icon(Icons.more_vert_rounded,
                color: AppTheme.getTextSecondary(isDark)),
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'toggle') onToggle();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  const Icon(Icons.edit_outlined,
                      size: 18, color: AppTheme.accent),
                  const SizedBox(width: 8),
                  Text('Editar',
                      style:
                          TextStyle(color: AppTheme.getTextPrimary(isDark))),
                ]),
              ),
              PopupMenuItem(
                value: 'toggle',
                child: Row(children: [
                  Icon(
                      employee.isActive
                          ? Icons.block_rounded
                          : Icons.check_circle_outline_rounded,
                      size: 18,
                      color: employee.isActive
                          ? AppTheme.error
                          : AppTheme.success),
                  const SizedBox(width: 8),
                  Text(employee.isActive ? 'Desactivar' : 'Activar',
                      style:
                          TextStyle(color: AppTheme.getTextPrimary(isDark))),
                ]),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  const Icon(Icons.delete_outline_rounded,
                      size: 18, color: Color(0xFFFCA5A5)),
                  const SizedBox(width: 8),
                  const Text('Eliminar',
                      style: TextStyle(color: Color(0xFFFCA5A5))),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final bool isDark;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.getBackground(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorder(isDark)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(color: AppTheme.getTextPrimary(isDark)),
              decoration: InputDecoration(
                hintText: label,
                hintStyle:
                    TextStyle(color: AppTheme.getTextSecondary(isDark)),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final List<String> items;
  final bool isDark;
  final ValueChanged<String?> onChanged;

  const _Dropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.getBackground(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorder(isDark)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                dropdownColor: AppTheme.getSurfaceCard(isDark),
                style: TextStyle(
                    color: AppTheme.getTextPrimary(isDark), fontSize: 14),
                isExpanded: true,
                items: items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
