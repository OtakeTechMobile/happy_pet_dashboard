import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/hotel_owners_cubit.dart';

class RegisterHotelDialog extends StatefulWidget {
  const RegisterHotelDialog({super.key});

  @override
  State<RegisterHotelDialog> createState() => _RegisterHotelDialogState();
}

class _RegisterHotelDialogState extends State<RegisterHotelDialog> {
  final _formKey = GlobalKey<FormState>();
  final _hotelNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _ownerPasswordController = TextEditingController();
  final List<TextEditingController> _staffControllers = [TextEditingController()];

  @override
  void dispose() {
    _hotelNameController.dispose();
    _ownerNameController.dispose();
    _ownerEmailController.dispose();
    _ownerPasswordController.dispose();
    for (var c in _staffControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addStaffField() {
    if (_staffControllers.length < 3) {
      setState(() {
        _staffControllers.add(TextEditingController());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Limite inicial de 3 funcionários atingido.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cadastrar Nova Creche'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dados da Creche', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _hotelNameController,
                decoration: const InputDecoration(labelText: 'Nome da Creche'),
                validator: (v) => v?.isEmpty ?? true ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              const Text('Dados do Proprietário', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _ownerNameController,
                decoration: const InputDecoration(labelText: 'Nome do Dono'),
                validator: (v) => v?.isEmpty ?? true ? 'Obrigatório' : null,
              ),
              TextFormField(
                controller: _ownerEmailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (v) => v?.isEmpty ?? true ? 'Obrigatório' : null,
              ),
              TextFormField(
                controller: _ownerPasswordController,
                decoration: const InputDecoration(labelText: 'Senha Inicial'),
                obscureText: true,
                validator: (v) => (v?.length ?? 0) < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Funcionários Iniciais', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (_staffControllers.length < 3)
                    IconButton(onPressed: _addStaffField, icon: const Icon(Icons.add_circle_outline)),
                ],
              ),
              ..._staffControllers.map((controller) {
                final index = _staffControllers.indexOf(controller);
                return TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Nome do Funcionário ${index + 1}',
                    suffixIcon: _staffControllers.length > 1
                        ? IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => setState(() => _staffControllers.removeAt(index)),
                          )
                        : null,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              context.read<HotelOwnersCubit>().registerHotelWithOwner(
                hotelName: _hotelNameController.text,
                ownerName: _ownerNameController.text,
                ownerEmail: _ownerEmailController.text,
                ownerPassword: _ownerPasswordController.text,
                staffNames: _staffControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList(),
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
