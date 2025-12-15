# Home Screen Update Guide - Category ObjectIds Implementation

## Overview
This guide shows how to update `lib/presentation/screens/home/home_screen.dart` to fetch and use category ObjectIds instead of hardcoded category names.

## Changes Required

### 1. Import the Category Model
Add this import at the top of the file:
```dart
import '../../data/models/category_model.dart';
import '../../data/datasources/remote/api_service.dart';
```

### 2. Update State Variables
Replace the hardcoded categories list with dynamic fetching:

**BEFORE:**
```dart
final List<String> _businessCategories = [
  'Medicines',
  'Lab Tests',
  'Nursing Care',
  'Diagnostic Services',
  'Medical Equipment',
  'Pharmacy Services',
];

List<String> _selectedBusinessCategories = [];
```

**AFTER:**
```dart
List<CategoryModel> _availableCategories = [];
Map<String, String> _categoryNameToId = {}; // Maps display name to ObjectId
List<String> _selectedCategoryIds = []; // Stores ObjectIds
bool _categoriesLoaded = false;
```

### 3. Add Category Fetching Method
Add this method to the `_HomeScreenState` class:

```dart
Future<void> _fetchCategories() async {
  try {
    final apiService = ApiService();
    final categoriesData = await apiService.getCategories(
      'http://192.168.0.161:9001/api/v1/categories/list',
    );
    
    final categories = categoriesData
        .map((json) => CategoryModel.fromJson(json))
        .toList();
    
    setState(() {
      _availableCategories = categories;
      // Create mapping for UI display
      _categoryNameToId = {
        for (var cat in categories) cat.name: cat.id
      };
      _categoriesLoaded = true;
    });
    
    print('✅ Categories loaded: ${categories.length}');
    for (var cat in categories) {
      print('   - ${cat.name} (${cat.id})');
    }
  } catch (e) {
    print('❌ Error fetching categories: $e');
    setState(() => _categoriesLoaded = true);
    // Optionally show error to user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: $e')),
      );
    }
  }
}
```

### 4. Call Category Fetching in initState
Update the `initState` method:

```dart
@override
void initState() {
  super.initState();
  _fetchCategories(); // Add this line
}
```

### 5. Update MultiSelectDropdown Widget
Find the MultiSelectDropdown widget and update it:

**BEFORE:**
```dart
MultiSelectDropdown(
  label: 'Business Categories *',
  selectedValues: _selectedBusinessCategories,
  hint: 'Select your business categories',
  errorText: _businessCategoryError,
  items: _businessCategories,
  enabled: !isSubmitting,
  onChanged: (values) {
    setState(() => _selectedBusinessCategories = values);
  },
)
```

**AFTER:**
```dart
MultiSelectDropdown(
  label: 'Business Categories *',
  selectedValues: _selectedCategoryIds, // Now contains ObjectIds
  hint: 'Select your business categories',
  errorText: _businessCategoryError,
  items: _availableCategories.map((cat) => cat.name).toList(), // Display names
  enabled: !isSubmitting && _categoriesLoaded,
  onChanged: (values) {
    setState(() => _selectedCategoryIds = values);
  },
)
```

### 6. Update Form Validation
Update the validation logic to use the new variable:

**BEFORE:**
```dart
_businessCategoryError =
    _showErrors && _selectedBusinessCategories.isEmpty
        ? 'Please select at least one business category'
        : null;
```

**AFTER:**
```dart
_businessCategoryError =
    _showErrors && _selectedCategoryIds.isEmpty
        ? 'Please select at least one business category'
        : null;
```

### 7. Update Form Submission
Update the vendor creation to use ObjectIds:

**BEFORE:**
```dart
final vendor = VendorEntity(
  firstName: _firstNameController.text,
  lastName: _lastNameController.text,
  email: _emailController.text,
  password: _passwordController.text,
  mobile: _mobileController.text,
  businessName: _businessNameController.text,
  businessEmail: _businessEmailController.text,
  altMobile: _altMobileController.text,
  address: _businessAddressController.text,
  categories: _selectedBusinessCategories, // OLD
  // ... rest of fields
);
```

**AFTER:**
```dart
final vendor = VendorEntity(
  firstName: _firstNameController.text,
  lastName: _lastNameController.text,
  email: _emailController.text,
  password: _passwordController.text,
  mobile: _mobileController.text,
  businessName: _businessNameController.text,
  businessEmail: _businessEmailController.text,
  altMobile: _altMobileController.text,
  address: _businessAddressController.text,
  categories: _selectedCategoryIds, // NEW - Contains ObjectIds
  // ... rest of fields
);
```

### 8. Update Form Reset
Update the reset logic to clear the new variables:

**BEFORE:**
```dart
_selectedBusinessCategories = [];
```

**AFTER:**
```dart
_selectedCategoryIds = [];
```

## Data Flow Diagram

```
┌───────────────────────────────────────���─────────────────────┐
│ App Startup                                                 │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────┐
        │ _fetchCategories()         │
        │ Calls API endpoint         │
        └────────────┬───────────────┘
                     │
                     ▼
    ┌────────────────────────────────────┐
    │ Backend: /api/v1/categories/list   │
    │ Returns: [{_id, name}, ...]        │
    └────────────┬───────────────────────┘
                 │
                 ▼
    ┌────────────────────────────────────┐
    │ Parse to CategoryModel objects      │
    │ Create name->id mapping            │
    └────────────┬───────────────────────┘
                 │
                 ▼
    ┌────────────────────────────────────┐
    │ Display category names in dropdown │
    │ Store ObjectIds internally         │
    └────────────┬───────────────────────┘
                 │
                 ▼
    ┌────────────────────────────────────┐
    │ User selects categories            │
    │ _selectedCategoryIds = [id1, id2]  │
    └────────────┬───────────────────────┘
                 │
                 ▼
    ┌────────────────────────────────────┐
    │ Form submission                    │
    │ Send categoryIds[0], categoryIds[1]│
    └────────────┬───────────────────────┘
                 │
                 ▼
    ┌────────────────────────────────────┐
    │ Backend receives ObjectIds         │
    │ Validation passes ✅               │
    │ Vendor created successfully        │
    └────────────────────────────────────┘
```

## Testing Steps

1. **Verify Categories Load:**
   - Check console for: `✅ Categories loaded: X`
   - Verify category names and IDs are printed

2. **Verify Dropdown Display:**
   - Open the form
   - Dropdown should show category names (not IDs)
   - Dropdown should be enabled after categories load

3. **Verify Selection:**
   - Select multiple categories
   - Verify they're highlighted in the dropdown

4. **Verify Submission:**
   - Submit the form
   - Check console for multipart request
   - Verify `categoryIds[0]`, `categoryIds[1]` contain ObjectIds (not names)
   - Backend should return 200/201 (not 500)

## Troubleshooting

### Categories not loading?
- Check if backend endpoint exists: `GET /api/v1/categories/list`
- Check network tab in browser/device logs
- Verify API response format matches expected structure

### Still getting 500 error?
- Verify ObjectIds are being sent (not category names)
- Check console logs for the actual request being sent
- Verify backend expects `categoryIds` field (not `categories`)

### Dropdown shows IDs instead of names?
- Verify `_availableCategories.map((cat) => cat.name).toList()` is used
- Check CategoryModel parsing is correct

## Summary

The key changes are:
1. ✅ Fetch categories from backend on app startup
2. ✅ Store category ObjectIds (not names)
3. ✅ Display category names in UI
4. ✅ Send ObjectIds to backend in multipart request
5. ✅ Backend validation passes and vendor is created successfully
