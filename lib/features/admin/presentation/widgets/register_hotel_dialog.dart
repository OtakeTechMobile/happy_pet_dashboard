import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/via_cep_service.dart';
import '../../../../domain/models/hotel_model.dart';
import '../cubit/hotel_owners_cubit.dart';

class RegisterHotelDialog extends StatefulWidget {
  final HotelModel? hotel;
  const RegisterHotelDialog({super.key, this.hotel});

  @override
  State<RegisterHotelDialog> createState() => _RegisterHotelDialogState();
}

class _RegisterHotelDialogState extends State<RegisterHotelDialog> {
  final _formKey = GlobalKey<FormState>();

  // Hotel Details
  final _hotelNameController = TextEditingController();
  final _hotelEmailController = TextEditingController();
  final _hotelPhoneController = TextEditingController();
  final _capacityController = TextEditingController(text: '20');
  final _maxStaffController = TextEditingController(text: '3');
  final _addressStreetController = TextEditingController();
  final _addressNumberController = TextEditingController();
  final _addressCityController = TextEditingController();
  final _addressStateController = TextEditingController();
  final _addressZipController = TextEditingController();
  bool _isActive = true;
  bool _isLoadingCep = false;

  // Owner (Only for new hotels)
  final _ownerNameController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _ownerPasswordController = TextEditingController();

  // Staff
  late List<Map<String, dynamic>> _staffMembers;
  bool _isLoadingStaff = false;

  bool get _isEditing => widget.hotel != null;

  @override
  void initState() {
    super.initState();
    _staffMembers = [];
    if (_isEditing) {
      final h = widget.hotel!;
      _hotelNameController.text = h.name;
      _hotelEmailController.text = h.email ?? '';
      _hotelPhoneController.text = h.phone ?? '';
      _capacityController.text = h.capacity.toString();
      _maxStaffController.text = h.maxStaff.toString();
      _addressStreetController.text = h.addressStreet ?? '';
      _addressNumberController.text = h.addressNumber ?? '';
      _addressCityController.text = h.addressCity ?? '';
      _addressStateController.text = h.addressState ?? '';
      _addressZipController.text = h.addressZip ?? '';
      _isActive = h.isActive;
      _loadStaff();
    } else {
      _staffMembers = [
        {
          'name': TextEditingController(),
          'email': TextEditingController(),
          'password': TextEditingController(),
          'isNew': true,
        },
      ];
    }
    _addressZipController.addListener(_onZipChanged);
  }

  void _onZipChanged() {
    final zip = _addressZipController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (zip.length == 8) {
      _fetchAddress(zip);
    }
  }

  Future<void> _fetchAddress(String zip) async {
    setState(() => _isLoadingCep = true);
    final service = ViaCepService();
    final data = await service.getAddress(zip);
    if (data != null && mounted) {
      setState(() {
        _addressStreetController.text = data['logradouro'] ?? '';
        _addressCityController.text = data['localidade'] ?? '';
        _addressStateController.text = data['uf'] ?? '';
      });
    }
    if (mounted) {
      setState(() => _isLoadingCep = false);
    }
  }

  Future<void> _loadStaff() async {
    setState(() => _isLoadingStaff = true);
    final staff = await context.read<HotelOwnersCubit>().getHotelStaff(widget.hotel!.id);
    setState(() {
      _staffMembers = staff
          .map(
            (s) => {
              'id': s['id'],
              'name': TextEditingController(text: s['full_name']),
              'email': s['email'], // Read only usually
              'role': s['role'],
              'isNew': false,
            },
          )
          .toList();
      _isLoadingStaff = false;
    });
  }

  @override
  void dispose() {
    _addressZipController.removeListener(_onZipChanged);
    _hotelNameController.dispose();
    _hotelEmailController.dispose();
    _hotelPhoneController.dispose();
    _capacityController.dispose();
    _maxStaffController.dispose();
    _addressStreetController.dispose();
    _addressNumberController.dispose();
    _addressCityController.dispose();
    _addressStateController.dispose();
    _addressZipController.dispose();
    _ownerNameController.dispose();
    _ownerEmailController.dispose();
    _ownerPasswordController.dispose();
    for (var s in _staffMembers) {
      if (s['name'] is TextEditingController) (s['name'] as TextEditingController).dispose();
      if (s['email'] is TextEditingController) (s['email'] as TextEditingController).dispose();
      if (s['password'] is TextEditingController) (s['password'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  void _addStaffField() {
    final limit = int.tryParse(_maxStaffController.text) ?? 3;
    if (_staffMembers.length < limit) {
      setState(() {
        _staffMembers.add({
          'name': TextEditingController(),
          'email': TextEditingController(),
          'password': TextEditingController(),
          'isNew': true,
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Limite de $limit funcionários atingido.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Editar Creche' : 'Cadastrar Nova Creche'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Dados da Creche', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (_isEditing)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isActive ? 'Ativa' : 'Inativa',
                            style: TextStyle(color: _isActive ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                          ),
                          Switch(value: _isActive, onChanged: (v) => setState(() => _isActive = v)),
                        ],
                      ),
                  ],
                ),
                TextFormField(
                  controller: _hotelNameController,
                  decoration: const InputDecoration(labelText: 'Nome da Creche'),
                  validator: (v) => v?.isEmpty ?? true ? 'Obrigatório' : null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _hotelEmailController,
                        decoration: const InputDecoration(labelText: 'E-mail de Contato'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _hotelPhoneController,
                        decoration: const InputDecoration(labelText: 'Telefone'),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _capacityController,
                        decoration: const InputDecoration(labelText: 'Capacidade de Pets'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v?.isEmpty ?? true ? 'Obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _maxStaffController,
                        decoration: const InputDecoration(labelText: 'Limite de Equipe'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v?.isEmpty ?? true ? 'Obrigatório' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Endereço', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _addressStreetController,
                        decoration: const InputDecoration(labelText: 'Rua'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _addressNumberController,
                        decoration: const InputDecoration(labelText: 'Nº'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _addressCityController,
                        decoration: const InputDecoration(labelText: 'Cidade'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _addressStateController,
                        decoration: const InputDecoration(labelText: 'Estado'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _addressZipController,
                        decoration: InputDecoration(
                          labelText: 'CEP',
                          suffixIcon: _isLoadingCep
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : null,
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, CepInputFormatter()],
                      ),
                    ),
                  ],
                ),

                if (!_isEditing) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Configuração Inicial (Dono)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextFormField(
                    controller: _ownerNameController,
                    decoration: const InputDecoration(labelText: 'Nome do Dono'),
                    validator: (v) => v?.isEmpty ?? true ? 'Obrigatório' : null,
                  ),
                  TextFormField(
                    controller: _ownerEmailController,
                    decoration: const InputDecoration(labelText: 'E-mail do Proprietário'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v?.isEmpty ?? true ? 'Obrigatório' : null,
                  ),
                  TextFormField(
                    controller: _ownerPasswordController,
                    decoration: const InputDecoration(labelText: 'Senha do Proprietário'),
                    obscureText: true,
                    validator: (v) => (v?.length ?? 0) < 6 ? 'Mínimo 6 caracteres' : null,
                  ),
                ],

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Equipe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      onPressed: _addStaffField,
                      icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                    ),
                  ],
                ),
                if (_isLoadingStaff)
                  const Center(
                    child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
                  )
                else
                  ..._staffMembers.map((staff) {
                    final index = _staffMembers.indexOf(staff);
                    final isNew = staff['isNew'] == true;
                    final role = staff['role'] ?? 'staff';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(role == 'owner' ? Icons.stars : Icons.person, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  role == 'owner' ? 'Proprietário' : 'Funcionário ${index + 1}',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                if (isNew)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Chip(
                                      label: Text('Novo', style: TextStyle(fontSize: 10)),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                const Spacer(),
                                if (isNew || (role == 'staff' && _staffMembers.length > 1))
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.red),
                                    onPressed: () => setState(() => _staffMembers.removeAt(index)),
                                  ),
                              ],
                            ),
                            TextFormField(
                              controller: staff['name'],
                              decoration: const InputDecoration(labelText: 'Nome Completo'),
                              validator: (v) => v?.isEmpty ?? true ? 'Obrigatório' : null,
                            ),
                            if (isNew) ...[
                              TextFormField(
                                controller: staff['email'],
                                decoration: const InputDecoration(labelText: 'E-mail de Login'),
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) => v?.isEmpty ?? true ? 'Obrigatório' : null,
                              ),
                              TextFormField(
                                controller: staff['password'],
                                decoration: const InputDecoration(labelText: 'Senha Inicial'),
                                obscureText: true,
                                validator: (v) => (v?.length ?? 0) < 6 ? 'Mínimo 6 caracteres' : null,
                              ),
                            ] else
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'E-mail: ${staff['email']}',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              final cubit = context.read<HotelOwnersCubit>();

              if (_isEditing) {
                // Update Hotel
                final updatedHotel = widget.hotel!.copyWith(
                  name: _hotelNameController.text,
                  email: _hotelEmailController.text,
                  phone: _hotelPhoneController.text,
                  capacity: int.parse(_capacityController.text),
                  maxStaff: int.parse(_maxStaffController.text),
                  addressStreet: _addressStreetController.text,
                  addressNumber: _addressNumberController.text,
                  addressCity: _addressCityController.text,
                  addressState: _addressStateController.text,
                  addressZip: _addressZipController.text,
                  isActive: _isActive,
                );

                await cubit.updateHotel(updatedHotel);

                // Handle Staff updates (Update names of existing, Add new ones)
                // Note: Realistically, profile updates should be a separate Cubit method or call,
                // but let's implement basic signup for new staff.
                for (var s in _staffMembers) {
                  if (s['isNew'] == true) {
                    await cubit.signupStaff(
                      fullName: (s['name'] as TextEditingController).text,
                      email: (s['email'] as TextEditingController).text,
                      password: (s['password'] as TextEditingController).text,
                      hotelId: widget.hotel!.id,
                    );
                  }
                }
              } else {
                // Create New Hotel
                final staffList = _staffMembers
                    .where((s) => s['isNew'] == true)
                    .map(
                      (s) => {
                        'name': (s['name'] as TextEditingController).text,
                        'email': (s['email'] as TextEditingController).text,
                        'password': (s['password'] as TextEditingController).text,
                      },
                    )
                    .toList();

                final newHotel = HotelModel(
                  id: '',
                  name: _hotelNameController.text,
                  email: _hotelEmailController.text,
                  phone: _hotelPhoneController.text,
                  capacity: int.tryParse(_capacityController.text) ?? 20,
                  maxStaff: int.tryParse(_maxStaffController.text) ?? 3,
                  addressStreet: _addressStreetController.text,
                  addressNumber: _addressNumberController.text,
                  addressCity: _addressCityController.text,
                  addressState: _addressStateController.text,
                  addressZip: _addressZipController.text,
                  isActive: _isActive,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                await cubit.registerHotelWithOwner(
                  hotel: newHotel,
                  ownerName: _ownerNameController.text,
                  ownerEmail: _ownerEmailController.text,
                  ownerPassword: _ownerPasswordController.text,
                  staffData: staffList,
                );
              }
              Navigator.pop(context);
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
