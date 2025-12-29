# Vendor Edit/Resubmission Flow Implementation

## Overview
This implementation enables users to click on vendor cards from vendor listing screens and open a prefilled form to edit or resubmit vendor information across all vendor statuses (Pending, Approved, Rejected).

## Changes Made

### 1. **Vendor List Screen Navigation** (`vendor_list_screen.dart`)
- **Change**: Made vendor cards clickable by wrapping `_VendorCard` widget with `GestureDetector`
- **Added parameter**: `onTap` callback to `_VendorCard` widget
- **Navigation**: When a vendor card is tapped, it navigates to `VendorEditScreen` passing:
  - `vendorId`: The unique identifier of the vendor
  - `user`: User entity containing authentication token

```dart
_VendorCard(
  vendor: vendor,
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VendorEditScreen(
          vendorId: vendor.id,
          user: widget.user,
        ),
      ),
    );
  },
);
```

### 2. **New Vendor Edit Screen** (`vendor_edit_screen.dart`)
- **Purpose**: Acts as a wrapper/loader screen that:
  - Fetches vendor details using `GetVendorDetailsUseCase`
  - Shows loading state while fetching data
  - Handles errors gracefully
  - Passes vendor details to `VendorProfileScreen` in edit mode

- **Features**:
  - Loading indicator while fetching vendor data
  - Error dialog with retry capability
  - Seamless transition to form with prefilled data

### 3. **Dependency Injection** (`injection_container.dart`)
- **Added**: `GetVendorDetailsUseCase` registration
```dart
sl.registerLazySingleton(() => GetVendorDetailsUseCase(sl()));
```

### 4. **Vendor Profile Screen Modifications** (`vendor_profile_screen.dart`)

#### Constructor Changes:
- **New parameters**:
  - `vendorDetails`: Optional `VendorDetailsEntity` containing existing vendor data
  - `isEditMode`: Boolean flag to determine if form is in edit or create mode

```dart
const VendorProfileScreen({
  super.key,
  required this.user,
  this.draftId,
  this.vendorDetails,
  this.isEditMode = false,
});
```

#### New Method: `_prefillVendorDetails()`
Automatically populates form controllers with vendor's existing data:
- **Personal Details**: First name, last name, email, phone, Aadhaar, address
- **Business Details**: Business name, email, mobile, categories, address
- **Banking Details**: Account number, IFSC, branch, bank name, account holder
- **Documents**: Document names and numbers

```dart
Future<void> _prefillVendorDetails(VendorDetailsEntity vendor) async {
  setState(() {
    _firstNameController.text = vendor.firstName;
    _lastNameController.text = vendor.lastName;
    // ... prefill all other fields
    _selectedBusinessCategories = List<String>.from(vendor.categories);
  });
  
  // Update category mappings
  if (_categoriesLoaded) {
    _updateCategoryMappings();
  }
}
```

#### Updated `initState()`:
- Checks if in edit mode and vendor details are provided
- Calls `_prefillVendorDetails()` to populate the form
- Falls back to draft loading if not in edit mode

```dart
@override
void initState() {
  super.initState();
  _currentDraftId = widget.draftId ?? DateTime.now().millisecondsSinceEpoch.toString();
  _fetchCategories();
  
  if (widget.isEditMode && widget.vendorDetails != null) {
    _prefillVendorDetails(widget.vendorDetails!);
  } else if (widget.draftId != null) {
    _loadDraft(widget.draftId!);
  }
}
```

### 5. **Form Submission Logic** (`_createVendor()`)
- **Modified** to support both create and update scenarios
- **Detects edit mode**: If `isEditMode` is true and `vendorDetails` is provided
- **Includes vendorId**: When editing, the vendor ID is included in the `VendorEntity`
- **Conditional submission**: Same form submission process but with vendorId for updates

```dart
VendorEntity(
  // ... all fields ...
  vendorId: widget.isEditMode ? widget.vendorDetails?.id : null,
);
```

### 6. **API Endpoints** (`api_endpoints.dart`)
- **Added**: New update endpoint
```dart
static const String updateVendor = '$baseUrl/employeevendor/vendor/update';
```

## User Flow

### For Editing a Vendor:
1. User views vendor listing screen (All Vendors, Approved, Pending, or Rejected)
2. User clicks on any vendor card
3. **VendorEditScreen** loads and fetches vendor details
4. **VendorProfileScreen** opens with:
   - All form fields prefilled with vendor's existing data
   - `isEditMode` set to true
   - Edit/Resubmit mode enabled
5. User can:
   - Modify any field
   - Correct previously rejected information
   - Resubmit the vendor profile
6. System processes as create/update based on vendorId presence

### For Creating a New Vendor:
1. User navigates to create new vendor (existing flow)
2. **VendorProfileScreen** opens with:
   - Empty form fields
   - `isEditMode` set to false
   - `vendorDetails` as null
3. User fills in all details and submits
4. System creates new vendor

## Status Support
The implementation works for all vendor statuses:
- ✅ **Pending**: Can edit and resubmit
- ✅ **Approved**: Can edit (for updates)
- ✅ **Rejected**: Can edit, correct, and resubmit

## Key Benefits

1. **Smooth Edit Flow**: No need to re-enter all information from scratch
2. **Status Agnostic**: Works for pending, approved, and rejected vendors
3. **Reusable Form**: Single form handles both create and edit modes
4. **Data Preservation**: All previously entered data is automatically populated
5. **Better UX**: Reduced user friction when correcting rejected submissions
6. **Scalable**: Easy to extend for other entity types using same pattern

## Technical Notes

- The vendor details fetching is done asynchronously in `VendorEditScreen`
- Form prefilling is done in `initState()` ensuring controllers are ready
- The `isEditMode` flag allows the form to know its operational mode
- Category mappings are updated after prefilling for correct selection
- Both create and update use the same form submission process; the backend distinguishes based on vendorId presence

## Files Modified/Created

### Created:
- `lib/presentation/screens/vendor_edit/vendor_edit_screen.dart` - New wrapper screen

### Modified:
- `lib/presentation/screens/vendor_list/vendor_list_screen.dart` - Added tap navigation
- `lib/presentation/screens/vendor_profile/vendor_profile_screen.dart` - Added edit mode support
- `lib/core/di/injection_container.dart` - Added DI registration
- `lib/core/constants/api_endpoints.dart` - Added update endpoint

## Testing Checklist

- [ ] Click on vendor card in "All Vendors" screen → Form prefills
- [ ] Click on vendor card in "Approved Vendors" screen → Form prefills
- [ ] Click on vendor card in "Pending Vendors" screen → Form prefills
- [ ] Click on vendor card in "Rejected Vendors" screen → Form prefills
- [ ] Edit a field and verify it changes
- [ ] Submit form and verify update/resubmission works
- [ ] Test for all vendor statuses
- [ ] Verify OTP flow still works for edits
- [ ] Test creating new vendor (ensure old flow still works)

