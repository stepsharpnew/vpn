import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';
import 'package:test_app/models/country.dart';

/// BottomSheet со списком стран для выбора
class CountryListBottomSheet extends StatelessWidget {
  final List<Country> countries;
  final String selectedCountry;
  final Function(Country) onCountrySelected;

  const CountryListBottomSheet({
    super.key,
    required this.countries,
    required this.selectedCountry,
    required this.onCountrySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Select Country',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: countries.length,
              itemBuilder: (context, index) {
                final country = countries[index];
                final isSelected = country.name == selectedCountry;

                return ListTile(
                  leading: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 32),
                  ),
                  title: Text(
                    country.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check,
                          color: AppColors.primaryBlue,
                        )
                      : null,
                  onTap: () {
                    onCountrySelected(country);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Статический метод для показа BottomSheet
  static void show({
    required BuildContext context,
    required List<Country> countries,
    required String selectedCountry,
    required Function(Country) onCountrySelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return CountryListBottomSheet(
          countries: countries,
          selectedCountry: selectedCountry,
          onCountrySelected: onCountrySelected,
        );
      },
    );
  }
}

