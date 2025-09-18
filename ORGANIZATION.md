# rmProApp File Organization

## Current Structure (All Original Files Preserved)

### 📁 Original Structure (Preserved)
All original files remain in their current locations for backwards compatibility.

### 📁 Organized Structure (New - Use This Going Forward)

#### Models/
- **Core/**: Core business objects (RMTenant, RMProperty, RMUnit, etc.)
- **Transactions/**: Payment and transaction models
- **Charges/**: Charges, fees, and recurring charges
- **Supporting/**: Address, Contact, and other supporting models

#### Networking/
- **Essential API Manager/**: Core API functionality
- **RM Data Manager/**: Data management classes (includes organized UnitDataManager copy)
- **Notice Manager/**: Notice generation utilities
- **Parameters/**: All API parameters (organized copies from APIParameters and Views)

#### Views/
- **Organized/**: New organized view structure
  - **Root/**: Main app views (MainAppView, HomeView, LoginView)
  - **Residents/**: All resident/tenant management views
  - **Units/**: Unit management views
  - **RentIncrease/**: All rent increase related views (consolidated)
- **Components/**: Reusable UI components

#### Original Views/ (Preserved)
- **Tenant/**: Original tenant views
- **Unit/**: Original unit views
- **Need To Build/**: Development views
- **Archived/**: Archived views
- **Main/**: Main views
- **Rent Increase Notice/**: Original rent increase views
- **RentIncrease/**: Alternative rent increase views
- **Special API Tasks/**: API utility views

## Migration Path

1. **Immediate**: Use organized folders for new development
2. **Phase 1**: Update imports to use organized Models structure
3. **Phase 2**: Gradually migrate views to organized structure
4. **Phase 3**: Remove original scattered files once migration is complete

## Benefits

- ✅ Logical grouping by domain
- ✅ Clear separation of concerns
- ✅ All original files preserved
- ✅ Easy migration path
- ✅ Better maintainability
- ✅ Follows iOS development best practices

## Note

This organization provides a clean structure while preserving all existing work. You can gradually migrate to the organized structure without breaking existing functionality.