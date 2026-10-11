import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/mock_data.dart';
import '../forms/validators.dart';
import '../widgets/form_layout.dart';
import 'not_found_screen.dart';

class TripFormScreen extends StatefulWidget {
  final String id;
  final bool driver;
  const TripFormScreen({super.key, required this.id, required this.driver});
  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _pickup = TextEditingController();
  final _time = TextEditingController();
  final _seats = TextEditingController();
  final _price = TextEditingController();
  String? _city;

  @override
  void dispose() {
    for (final controller in [_name, _phone, _pickup, _time, _seats, _price]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final race = findRace(widget.id);
    if (race == null) return const NotFoundScreen();
    return FormLayout(
      title: widget.driver ? 'Предложить поездку' : 'Найти место',
      eyebrow: '${race.code} / ${race.city}',
      description:
          '${race.title} · ${race.date}\nУкажи место встречи и удобное время выезда.',
      formKey: _formKey,
      fields: [
        TextFormField(
          key: const Key('trip-name'),
          controller: _name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Имя'),
          validator: Validators.name,
        ),
        DropdownButtonFormField<String>(
          key: const Key('trip-city'),
          initialValue: _city,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Город выезда'),
          items: ['Chișinău', 'Bălți', 'Iași', 'București']
              .map((city) => DropdownMenuItem(value: city, child: Text(city)))
              .toList(),
          onChanged: (value) => setState(() => _city = value),
          validator: (value) => value == null ? 'Выберите город выезда' : null,
        ),
        TextFormField(
          key: const Key('trip-pickup'),
          controller: _pickup,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Место встречи',
            hintText: 'Площадь, улица или ориентир',
          ),
          validator: Validators.name,
        ),
        TextFormField(
          key: const Key('trip-time'),
          controller: _time,
          keyboardType: TextInputType.datetime,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
            LengthLimitingTextInputFormatter(5),
          ],
          decoration: const InputDecoration(
            labelText: 'Время выезда',
            hintText: '06:30',
          ),
          validator: Validators.time,
        ),
        TextFormField(
          key: const Key('trip-seats'),
          controller: _seats,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          decoration: InputDecoration(
            labelText: widget.driver ? 'Свободных мест' : 'Нужно мест',
          ),
          validator: Validators.seats,
        ),
        if (widget.driver)
          TextFormField(
            key: const Key('trip-price'),
            controller: _price,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            decoration: const InputDecoration(
              labelText: 'Вклад с человека, MDL',
              helperText: '0 — бесплатная поездка',
            ),
            validator: Validators.price,
          ),
        TextFormField(
          key: const Key('trip-phone'),
          controller: _phone,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[+0-9]')),
            LengthLimitingTextInputFormatter(16),
          ],
          decoration: const InputDecoration(
            labelText: 'Телефон',
            hintText: '+37360000000',
          ),
          validator: Validators.phone,
        ),
      ],
      onSubmit: () {
        if (!_formKey.currentState!.validate()) return;
        finishForm(
          context,
          widget.driver
              ? 'Данные поездки проверены'
              : 'Запрос на место проверен',
        );
      },
    );
  }
}
