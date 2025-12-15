# Architecture Diagram - Category ObjectIds Flow

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         MEDICOMPARE EMPLOYEE APP                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                      PRESENTATION LAYER                         │  │
│  │                                                                  │  │
│  │  ┌────────────────────────────────────────────────────────────┐ │  │
│  │  │  HomeScreen (Vendor Form)                                 │ │  │
│  │  │                                                            │ │  │
│  │  │  State Variables:                                         │ │  │
│  │  │  - _availableCategories: List<CategoryModel>             │ │  │
│  │  │  - _selectedCategoryIds: List<String>  (ObjectIds)       │ │  │
│  │  │  - _categoryNameToId: Map<String, String>                │ │  │
│  │  │                                                            │ │  │
│  │  │  Methods:                                                 │ │  │
│  │  │  - _fetchCategories()  ──┐                               │ │  │
│  │  │  - _onSubmit()           │                               │ │  │
│  │  │                           │                               │ │  │
│  │  │  Widgets:                 │                               │ │  │
│  │  │  - MultiSelectDropdown    │                               │ │  │
│  │  │    (displays names)        │                               │ │  │
│  │  └────────────────────────────┼───────────────────────────────┘ │  │
│  │                               │                                  │  │
│  └───────────────────────────────┼──────────────────────────────────┘  │
│                                  │                                     │
│  ┌───────────────────────────────▼──────────────────────────────────┐  │
│  │                      DATA LAYER                                 │  │
│  │                                                                  │  │
│  │  ┌────────────────────────────────────────────────────────────┐ │  │
│  │  │  ApiService                                               │ │  │
│  │  │                                                            │ │  │
│  │  │  Methods:                                                 │ │  │
│  │  │  - getCategories(url)  ──┐                               │ │  │
│  │  │  - postMultipart(...)     │                               │ │  │
│  │  │                           │                               │ │  │
│  │  └───────────────────────────┼───────────────────────────────┘ │  │
│  │                              │                                  │  │
│  │  ┌──────────────────────────┼──────────────────────────────┐   │  │
│  │  │  CategoryModel           │                              │   │  │
│  │  │  - id: String (ObjectId) │                              │   │  │
│  │  │  - name: String          │                              │   │  │
│  │  │  - fromJson()            │                              │   │  │
│  │  └─────────────────���────────┼──────────────────────────────┘   │  │
│  │                              │                                  │  │
│  │  ┌──────────────────────────▼──────────────────────────────┐   │  │
│  │  │  VendorModel                                            │   │  │
│  │  │  - categories: List<String> (ObjectIds)                │   │  │
│  │  │  - toMultipartFields()                                  │   │  │
│  │  │    └─> categoryIds[0], categoryIds[1], ...             │   │  │
│  │  │  - toMultipartFiles()                                   │   │  │
│  │  └──────────────────────────────────────────────────────────┘   │  │
│  │                                                                  │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
                                  │
                                  │ HTTP Requests
                                  │
                    ┌─────────────┴──────────────┐
                    │                            │
                    ▼                            ▼
        ┌──────────────────────┐    ┌──────────────────────┐
        │  GET /categories/list│    │ POST /vendor/create  │
        │                      │    │                      │
        │  Response:           │    │  Request:            │
        │  [{                  │    │  categoryIds[0]: id1  │
        │    _id: "507f...",   │    │  categoryIds[1]: id2  │
        │    name: "Lab Tests" │    │  ...other fields...   │
        │  }, ...]             │    │                      │
        └──────────────────────┘    └──────��───────────────┘
                    │                            │
                    └─────────────┬──────────────┘
                                  │
                    ┌─────────────▼──────────────┐
                    │                            │
                    │   BACKEND API SERVER       │
                    │   (Node.js/Express)        │
                    │                            │
                    │  - Categories Collection   │
                    │  - Vendors Collection      │
                    │  - Validation Logic        │
                    │                            │
                    └────────────────────────────┘
```

---

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        APP INITIALIZATION                               │
└────────────────────────────────┬──���─────────────────────────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────┐
                    │  initState()           │
                    │  _fetchCategories()    │
                    └────────────┬───────────┘
                                 │
                                 ▼
                    ┌────────────────────────────────────┐
                    │  ApiService.getCategories()        │
                    │  GET /api/v1/categories/list       │
                    └────────────┬───────────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────────────────┐
                    │  Backend Response                  │
                    │  [{_id: "507f...", name: "Lab"}]   │
                    └────────────┬───���───────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────────────────┐
                    │  Parse to CategoryModel            │
                    │  Create name->id mapping           │
                    │  Update UI                         │
                    └────────────┬───────────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────────────────┐
                    │  User sees dropdown with names     │
                    │  "Lab Tests", "Nursing Care", ...  │
                    └────────────┬───────────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────────────────┐
                    │  User selects categories           │
                    │  _selectedCategoryIds = [id1, id2] │
                    └────────────┬───────────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────────────────┐
                    │  User fills form & submits         │
                    │  _onSubmit()                       │
                    └────────────┬───────────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────────────────┐
                    │  Create VendorEntity               │
                    │  categories: _selectedCategoryIds  │
                    │  (contains ObjectIds)              │
                    └────────────┬───────────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────────────────┐
                    │  VendorModel.toMultipartFields()   │
                    │  categoryIds[0]: "507f..."         │
                    │  categoryIds[1]: "507f..."         │
                    └────────────┬───────────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────────────────┐
                    │  ApiService.postMultipart()        │
                    │  POST /api/v1/vendor/create        │
                    │  with categoryIds                  │
                    └────────────┬───────────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────────────────┐
                    │  Backend Validation                │
                    │  ✅ ObjectIds are valid            │
                    │  ✅ Can cast to MongoDB ObjectId   │
                    │  ✅ Vendor created                 │
                    └────────────┬───────────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────────────────┐
                    │  Backend Response                  │
                    │  {success: true, vendorId: "..."}  │
                    │  Status: 200/201                   │
                    └────────────┬───────────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────────────────┐
                    │  Show Success Message              │
                    │  Vendor Profile Submitted!         │
                    └────────────────────────────────────┘
```

---

## Component Interaction Diagram

```
┌──────────���───────────────────────────────────────────────────────────┐
│                         HOME SCREEN                                  │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  _availableCategories: List<CategoryModel>                    │ │
│  │  [                                                             │ │
│  │    CategoryModel(id: "507f...", name: "Lab Tests"),           │ │
│  │    CategoryModel(id: "507f...", name: "Nursing Care"),        │ │
│  │    CategoryModel(id: "507f...", name: "Medicines")            │ │
│  │  ]                                                             │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ┌───────────────���────────────────────────────────────────────────┐ │
│  │  _categoryNameToId: Map<String, String>                       │ │
│  │  {                                                             │ │
│  │    "Lab Tests": "507f1f77bcf86cd799439011",                   │ │
│  │    "Nursing Care": "507f1f77bcf86cd799439012",                │ │
│  │    "Medicines": "507f1f77bcf86cd799439013"                    │ │
│  │  }                                                             │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  _selectedCategoryIds: List<String>                           │ │
│  │  ["507f1f77bcf86cd799439011", "507f1f77bcf86cd799439012"]    │ │
│  │                                                                │ │
���  │  (User selected "Lab Tests" and "Nursing Care")               │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  MultiSelectDropdown                                          │ │
│  │  ┌──────────────────────────────────────────────────────────┐ │ │
│  │  │ Business Categories *                                   │ │ │
│  │  │ ┌──────────────────────────────────────────────────────┐│ │ │
│  │  │ │ ☑ Lab Tests                                         ││ │ │
│  │  │ │ ☑ Nursing Care                                      ││ │ │
│  │  │ │ ☐ Medicines                                         │�� │ │
│  │  │ └──────────────────────────────────────────────────────┘│ │ │
│  │  └──────────────────────────────────────────────────────────┘ │ │
│  │                                                                │ │
│  │  items: ["Lab Tests", "Nursing Care", "Medicines"]           │ │
│  │  selectedValues: ["507f...", "507f..."]                      │ │
│  │  onChanged: (values) => _selectedCategoryIds = values        │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  Submit Button                                                │ │
│  │  onPressed: _onSubmit()                                       │ │
│  │                                                                │ │
│  │  Creates VendorEntity with:                                   │ │
│  │  categories: ["507f...", "507f..."]  (ObjectIds)             │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
                                 │
                                 │ VendorModel.toMultipartFields()
                                 │
                                 ▼
┌──────────────────────────────────────────────────────────────────────┐
│                      MULTIPART REQUEST                               │
│                                                                      │
│  categoryIds[0]: "507f1f77bcf86cd799439011"                         │
│  categoryIds[1]: "507f1f77bcf86cd799439012"                         │
│  firstName: "saba"                                                   │
│  lastName: "shaik"                                                   │
│  email: "ssanashajiya@gmail.com"                                    │
│  ... other fields ...                                               │
│  file: [binary PDF data]                                            │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
                                 │
                                 │ HTTP POST
                                 │
                                 ▼
┌──────────────────────────────────────────────────────────────────────┐
│                      BACKEND VALIDATION                              │
│                                                                      │
│  ✅ categoryIds[0] is valid ObjectId                                │
│  ✅ categoryIds[1] is valid ObjectId                                │
│  ✅ Can cast to MongoDB ObjectId type                               │
│  ✅ All other fields valid                                          │
│  ✅ Vendor document created in database                             │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
                                 │
                                 │ HTTP Response
                                 │
                                 ▼
┌──────────────────────────────────────────────────────────────────────┐
│                      SUCCESS RESPONSE                                │
│                                                                      │
│  Status: 200 OK                                                      │
│  {                                                                   │
│    "success": true,                                                 │
│    "message": "Vendor created successfully",                        │
│    "data": {                                                        │
│      "vendorId": "507f1f77bcf86cd799439099",                        │
│      "firstName": "saba",                                           │
│      "categoryIds": [                                               │
│        "507f1f77bcf86cd799439011",                                  │
│        "507f1f77bcf86cd799439012"                                   │
│      ]                                                              │
│    }                                                                │
│  }                                                                   │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## File Structure

```
lib/
├── core/
│   └── constants/
│       └── api_endpoints.dart
│           ├── getCategories = '/api/v1/categories/list'  ✅ NEW
│           └── createVendor = '/api/v1/employeevendor/vendor/create'
│
├── data/
│   ├── datasources/
│   │   └── remote/
│   │       └── api_service.dart
│   │           ├── getCategories(url)  ✅ NEW METHOD
│   │           └── postMultipart(...)
│   │
│   └── models/
│       ├── category_model.dart  ✅ NEW FILE
│       │   ├── id: String (ObjectId)
│       │   ├── name: String
│       │   └── fromJson()
│       │
│       └── vendor_model.dart
│           └── toMultipartFields()
│               └── categoryIds[$i]  ✅ CHANGED
│
└── presentation/
    └── screens/
        └── home/
            └── home_screen.dart
                ├── _availableCategories  ✅ NEW
                ├── _selectedCategoryIds  ✅ NEW
                ├── _fetchCategories()    ✅ NEW
                └── MultiSelectDropdown   ✅ UPDATED
```

---

## State Management Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    HOME SCREEN STATE                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Initial State:                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ _availableCategories = []                               │   │
│  │ _selectedCategoryIds = []                               │   │
│  │ _categoriesLoaded = false                               │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  After _fetchCategories():                                      │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ _availableCategories = [                                │   │
│  │   CategoryModel(id: "507f...", name: "Lab Tests"),      │   │
│  │   CategoryModel(id: "507f...", name: "Nursing Care"),   │   │
│  │   ...                                                   │   │
│  │ ]                                                       │   │
│  │ _selectedCategoryIds = []                               │   │
│  │ _categoriesLoaded = true                                │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  After User Selection:                                          │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ _availableCategories = [...]  (unchanged)               │   │
│  │ _selectedCategoryIds = [                                │   │
│  │   "507f1f77bcf86cd799439011",                           │   │
│  │   "507f1f77bcf86cd799439012"                            │   │
│  │ ]                                                       │   │
│  │ _categoriesLoaded = true                                │   │
│  └───────────────────────────────────────────��─────────────┘   │
│                                                                 │
│  After Form Submission:                                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ VendorEntity created with:                              │   │
│  │ categories: ["507f...", "507f..."]  (ObjectIds)         │   │
│  │                                                         │   │
│  │ Sent to backend via multipart request                   │   │
│  │ categoryIds[0]: "507f1f77bcf86cd799439011"              │   │
│  │ categoryIds[1]: "507f1f77bcf86cd799439012"              │   │
│  └──────────────────────────────���──────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Summary

The architecture ensures:
1. **Separation of Concerns** - UI displays names, backend uses IDs
2. **Type Safety** - ObjectIds are properly typed and validated
3. **Data Integrity** - Valid database references maintained
4. **User Experience** - Users see readable category names
5. **API Compliance** - Backend receives expected data format
