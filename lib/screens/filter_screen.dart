import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String _selectedGender = 'Men';
  String _selectedSize = 'S';
  RangeValues _priceRange = const RangeValues(12, 312);
  List<String> _selectedColors = ['Black'];

  final List<String> genders = ['Men', 'Women', 'Unisex'];
  final List<String> sizes = ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL'];
  final List<Map<String, dynamic>> colors = [
    {'name': 'Black', 'color': Colors.black},
    {'name': 'White', 'color': Colors.white},
    {'name': 'Red', 'color': Colors.red},
    {'name': 'Grey', 'color': Colors.grey},
    {'name': 'Yellow', 'color': Colors.amber},
    {'name': 'Pink', 'color': Colors.pink[300]},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Gender'),
                    _buildGenderSelector(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Size'),
                    _buildSizeSelector(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Price'),
                    _buildPriceRangeSelector(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Color'),
                    _buildColorSelector(),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF24969A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Show 80 Results',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Wrap(
      spacing: 8,
      children: genders.map((gender) {
        final isSelected = _selectedGender == gender;
        return FilterChip(
          label: Text(gender),
          selected: isSelected,
          onSelected: (_) {
            setState(() {
              _selectedGender = gender;
            });
          },
          selectedColor: const Color(0xFFE0F7F4),
          checkmarkColor: const Color(0xFF24969A),
          backgroundColor: Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? const Color(0xFF24969A) : Colors.transparent,
              width: 1,
            ),
          ),
          labelStyle: TextStyle(
            color: isSelected ? const Color(0xFF24969A) : Colors.black,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );
      }).toList(),
    );
  }

  Widget _buildSizeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sizes.map((size) {
        final isSelected = _selectedSize == size;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedSize = size;
            });
          },
          child: Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE0F7F4) : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? const Color(0xFF24969A) : Colors.transparent,
                width: 1,
              ),
            ),
            child: Text(
              size,
              style: TextStyle(
                color: isSelected ? const Color(0xFF24969A) : Colors.black,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceRangeSelector() {
    return Column(
      children: [
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 500,
          divisions: 50,
          activeColor: const Color(0xFF24969A),
          inactiveColor: Colors.grey[200],
          labels: RangeLabels(
            '\$${_priceRange.start.round()}',
            '\$${_priceRange.end.round()}',
          ),
          onChanged: (values) {
            setState(() {
              _priceRange = values;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${_priceRange.start.round()}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '\$${_priceRange.end.round()}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: colors.map((colorData) {
        final isSelected = _selectedColors.contains(colorData['name']);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedColors.remove(colorData['name']);
              } else {
                _selectedColors.add(colorData['name']);
              }
            });
          },
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: colorData['color'],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorData['name'] == 'White'
                            ? Colors.grey[300]!
                            : Colors.transparent,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF24969A),
                          width: 2,
                        ),
                      ),
                    ),
                  if (isSelected && colorData['name'] == 'Black')
                    const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    ),
                  if (isSelected && colorData['name'] != 'Black')
                    const Icon(
                      Icons.check,
                      color: Colors.black,
                      size: 24,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                colorData['name'],
                style: TextStyle(
                  color: isSelected ? const Color(0xFF24969A) : Colors.black,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
