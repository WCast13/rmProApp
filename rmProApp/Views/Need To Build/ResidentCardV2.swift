//
//  ResidentCardV2.swift
//  rmProApp
//
//  Created by William Castellano on 9/4/25.
//


import SwiftUI
// New Resident Card with Fire Protection toggle
struct ResidentCardV2: View {
    let tenant: WCLeaseTenant
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject private var tenantDataManager: TenantDataManager
    
    @State private var isFireProtMember: Bool = false
    @State private var isUpdatingFireProt: Bool = false
    @State private var updateError: Bool = false
    
    private var initialsText: String {
        initials(from: tenant.name ?? "N/A")
    }
    
    private var unitNameText: String? {
        tenant.lease?.unit?.name
    }
    
    private var positiveBalanceText: Text? {
        guard let balance = tenant.openBalance, balance > 0 else { return nil }
        let number = balance as NSDecimalNumber
        let formatted = Text(number as Decimal.FormatStyle.Currency.FormatInput, format: .currency(code: "USD"))
        return Text("Balance: ") + formatted
    }
    
    var body: some View {
        Button(action: {
            navigationPath.append(AppDestination.residentDetails(tenant))
        }) {
            HStack(alignment: .center, spacing: 12) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.blue, .black], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 50, height: 50)
                    Text(initialsText)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                // Details
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(tenant.name ?? "N/A")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Spacer(minLength: 8)
                        
                        // Fire Protection toggle button
                        fireProtectionButton
                    }
                    
                    if let unitName = unitNameText {
                        Text("Unit: \(unitName)")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    
                    if let balanceText = positiveBalanceText {
                        balanceText
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.red)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(.plain)
        .alert("Update Failed", isPresented: $updateError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("We couldn't update Fire Protection Group membership. Please try again.")
        }
        .onAppear {
            // initialize local state from current UDFs if present
            isFireProtMember = computeFireProtectionMembership(from: tenant)
        }
    }
    
    private var fireProtectionButton: some View {
        Button {
            Task {
                await toggleFireProtection()
            }
        } label: {
            HStack(spacing: 6) {
                if isUpdatingFireProt {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: isFireProtMember ? "shield.checkerboard" : "shield")
                        .imageScale(.small)
                }
                Text("Fire Prot.")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isFireProtMember ? Color.green.opacity(0.9) : Color.gray.opacity(0.3))
            )
            .foregroundColor(isFireProtMember ? .white : .primary)
        }
        .buttonStyle(.plain)
        .disabled(isUpdatingFireProt || tenant.tenantID == nil)
        .accessibilityLabel("Toggle Fire Protection Group membership")
        .accessibilityValue(isFireProtMember ? "Member" : "Not a member")
    }
    
    private func computeFireProtectionMembership(from tenant: WCLeaseTenant) -> Bool {
        guard let udfs = tenant.udfs else { return false }
        // UDF 59: "HEI- Fire Protection Approved 2025" with "Yes"/"No"
        return udfs.contains { $0.userDefinedFieldID == 64 && ($0.value?.localizedCaseInsensitiveCompare("Yes") == .orderedSame) }
    }
    
    private func toggleFireProtection() async {
        guard let id = tenant.tenantID else { return }
        isUpdatingFireProt = true
        defer { isUpdatingFireProt = false }
        
        // Get the latest UDFs for this tenant (ensures we base the toggle on current server state)
        guard let newTenant = TenantDataManager.shared.allTenants.first(where: { $0.tenantID == id }) else { return }
        let udfData = await TenantDataManager.shared.fetchSection(for: [newTenant], embeds: TenantEmbeds.udfEmbeds, fields: TenantFields.udfFields, section: .userDefinedValues)
        
        // Read current value from UDF 64 (2026)
        var isFireProtMember = false
        
        print("UdfData Count: \(udfData.count)")
        let udfTenant = udfData.first(where: { $0.tenantID == id })
        
        print("UdfTenant: \(udfTenant?.udfs?.filter { $0.userDefinedFieldID == 64 }.first?.value ?? "N/A")")
        let value = udfTenant?.udfs?.filter { $0.userDefinedFieldID == 64 }.first?.value ?? "N/A"
        
        print("Value: \(value)")
        
        if value == "Yes" {
            isFireProtMember = true
        }
        
        print("Value2: \(value)")
        
        let newIsMember = !isFireProtMember
        
        print("Current FPG Resident: \(isFireProtMember) -> New: \(newIsMember)")
        
        // Post the desired new state
        TenantDataManager.shared.updateFireProtectionGroup(tenantID: id, isFPGResident: newIsMember)
        
        // Optimistically update local UI state
        isFireProtMember = newIsMember
        
        // Optionally, you could re-fetch the UDFs and verify; if it fails, revert and show alert.
        /*
        let verify = await TenantDataManager.shared.fetchSection(for: [newTenant], embeds: TenantEmbeds.udfEmbeds, fields: TenantFields.udfFields, section: .userDefinedValues)
        let serverIsMember = (verify.first?.udfs?.first { $0.userDefinedFieldID == 59 }?.value ?? "").localizedCaseInsensitiveCompare("Yes") == .orderedSame
        if serverIsMember != newIsMember {
            updateError = true
            isFireProtMember = serverIsMember
        }
        */
    }
}

private func initials(from name: String) -> String {
   let components = name.split(separator: " ")
   let initials = components.prefix(2).map { $0.first?.uppercased() ?? "" }.joined()
   return initials.isEmpty ? "N/A" : initials
}
