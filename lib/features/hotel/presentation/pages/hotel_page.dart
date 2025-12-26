import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/via_cep_service.dart';
import '../../../../data/repositories/hotel_repository.dart';
import '../../../../domain/models/hotel_model.dart';
import '../cubit/hotel_cubit.dart';
import '../cubit/hotel_state.dart';

class HotelPage extends StatelessWidget {
  const HotelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => HotelCubit(HotelRepository())..loadFirstHotel(), child: const HotelView());
  }
}

class HotelView extends StatefulWidget {
  const HotelView({super.key});

  @override
  State<HotelView> createState() => _HotelViewState();
}

class _HotelViewState extends State<HotelView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _streetController;
  late TextEditingController _numberController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  late TextEditingController _capacityController;

  bool _isLoadingCep = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _streetController = TextEditingController();
    _numberController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _zipController = TextEditingController();
    _capacityController = TextEditingController();

    _zipController.addListener(_onZipChanged);
  }

  void _onZipChanged() {
    final zip = _zipController.text.replaceAll(RegExp(r'[^0-9]'), '');
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
        _streetController.text = data['logradouro'] ?? '';
        _cityController.text = data['localidade'] ?? '';
        _stateController.text = data['uf'] ?? '';
      });
    }
    if (mounted) {
      setState(() => _isLoadingCep = false);
    }
  }

  @override
  void dispose() {
    _zipController.removeListener(_onZipChanged);
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hotel Profile')),
      body: BlocConsumer<HotelCubit, HotelState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          }
          if (state.hotel != null) {
            if (_nameController.text.isEmpty && state.hotel!.name.isNotEmpty) {
              _populateControllers(state.hotel!);
            }
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Hotel Name', border: OutlineInputBorder()),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, TelefoneInputFormatter()],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _capacityController,
                          decoration: const InputDecoration(labelText: 'Capacity', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  const Text('Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _zipController,
                          decoration: InputDecoration(
                            labelText: 'CEP',
                            border: const OutlineInputBorder(),
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _stateController,
                          decoration: const InputDecoration(labelText: 'State (UF)', border: OutlineInputBorder()),
                          maxLength: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _streetController,
                    decoration: const InputDecoration(labelText: 'Street', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _numberController,
                          decoration: const InputDecoration(labelText: 'Number', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _saveHotel(context, state.hotel);
                        }
                      },
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _populateControllers(HotelModel hotel) {
    _nameController.text = hotel.name;
    _phoneController.text = hotel.phone ?? '';
    _emailController.text = hotel.email ?? '';
    _streetController.text = hotel.addressStreet ?? '';
    _numberController.text = hotel.addressNumber ?? '';
    _cityController.text = hotel.addressCity ?? '';
    _stateController.text = hotel.addressState ?? '';
    _zipController.text = hotel.addressZip ?? '';
    _capacityController.text = hotel.capacity.toString();
  }

  void _saveHotel(BuildContext context, HotelModel? currentHotel) {
    final hotel =
        (currentHotel ??
                HotelModel(
                  id: '', // Will be handled by repository/DB or ignored if creating
                  name: '',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ))
            .copyWith(
              name: _nameController.text,
              phone: _phoneController.text,
              email: _emailController.text,
              addressStreet: _streetController.text,
              addressNumber: _numberController.text,
              addressCity: _cityController.text,
              addressState: _stateController.text,
              addressZip: _zipController.text,
              capacity: int.tryParse(_capacityController.text) ?? 20,
            );

    context.read<HotelCubit>().saveHotel(hotel);
  }
}
