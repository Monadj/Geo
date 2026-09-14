import SwiftUI

struct ContentView: View {
    // MARK: - State Variables
    @State private var inputN: String = "5"
    @State private var inputA: String = "12"
    @State private var inputB: String = "18"
    
    @State private var showHelpAlert: Bool = false
    
    // MARK: - Dynamic Computations
    private var nValue: Int? { Int(inputN) }
    private var aValue: Int? { Int(inputA) }
    private var bValue: Int? { Int(inputB) }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Header
                VStack(spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "number.square.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.primary)
                        Text("Number Tools")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    Text("Small numbers, big possibilities!")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                }
                .padding(.top, 16)
                
                // MARK: - Section 1: Single Number (n)
                VStack(alignment: .leading, spacing: 16) {
                    Text("Single Number (n)")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Enter a number:")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        HStack {
                            TextField("Enter n", text: $inputN)
                                .keyboardType(.numberPad)
                                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                            
                            if !inputN.isEmpty {
                                Button(action: { inputN = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                    
                    // Results Card for n
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Results for n = \(inputN.isEmpty ? "-" : inputN)")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 10) {
                            MonoResultBox(label: "n² (Square)", value: computeSquare(nValue))
                            MonoResultBox(label: "n³ (Cube)", value: computeCube(nValue))
                            MonoResultBox(label: "n! (Factorial)", value: computeFactorial(nValue))
                            MonoResultBox(label: "Prime Check", value: checkPrime(nValue))
                        }
                    }
                    .padding()
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.1), lineWidth: 1))
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.primary.opacity(0.15), lineWidth: 1))
                
                // MARK: - Section 2: Two Numbers (a, b)
                VStack(alignment: .leading, spacing: 16) {
                    Text("Two Numbers (a, b)")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Enter a:")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                            TextField("a", text: $inputA)
                                .keyboardType(.numberPad)
                                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Enter b:")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                            TextField("b", text: $inputB)
                                .keyboardType(.numberPad)
                                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                        }
                    }
                    
                    // Results Card for a & b
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Results for a = \(inputA.isEmpty ? "-" : inputA), b = \(inputB.isEmpty ? "-" : inputB)")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            MonoResultBox(label: "UCLN (GCD)", value: computeGCD(aValue, bValue))
                            MonoResultBox(label: "BCNN (LCM)", value: computeLCM(aValue, bValue))
                        }
                    }
                    .padding()
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.1), lineWidth: 1))
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.primary.opacity(0.15), lineWidth: 1))
                
                // MARK: - Footer Actions
                HStack(spacing: 12) {
                    Button(action: clearAll) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Clear All")
                        }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.2), lineWidth: 1))
                    }
                    
                    Button(action: { showHelpAlert = true }) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("Help")
                        }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.primary)
                        .cornerRadius(12)
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 16)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .alert(isPresented: $showHelpAlert) {
            Alert(
                title: Text("Number Tools"),
                message: Text("Type any number into the input fields and the calculated values will appear automatically."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Logic Calculations
    private func computeSquare(_ n: Int?) -> String {
        guard let n = n else { return "-" }
        return "\(n * n)"
    }
    
    private func computeCube(_ n: Int?) -> String {
        guard let n = n else { return "-" }
        return "\(n * n * n)"
    }
    
    private func computeFactorial(_ n: Int?) -> String {
        guard let n = n, n >= 0 else { return "-" }
        if n > 20 { return "Overflow" }
        var fact: UInt64 = 1
        if n > 0 {
            for i in 1...n { fact *= UInt64(i) }
        }
        return "\(fact)"
    }
    
    private func checkPrime(_ n: Int?) -> String {
        guard let n = n, n >= 0 else { return "-" }
        if n <= 1 { return "No" }
        if n <= 3 { return "Yes" }
        if n % 2 == 0 || n % 3 == 0 { return "No" }
        var i = 5
        while i * i <= n {
            if n % i == 0 || n % (i + 2) == 0 { return "No" }
            i += 6
        }
        return "Yes"
    }
    
    private func computeGCD(_ a: Int?, _ b: Int?) -> String {
        guard let a = a, let b = b, a > 0, b > 0 else { return "-" }
        var x = a
        var y = b
        while y != 0 {
            let temp = y
            y = x % y
            x = temp
        }
        return "\(x)"
    }
    
    private func computeLCM(_ a: Int?, _ b: Int?) -> String {
        guard let a = a, let b = b, a > 0, b > 0 else { return "-" }
        let gcdVal = Int(computeGCD(a, b)) ?? 1
        return "\((a * b) / gcdVal)"
    }
    
    private func clearAll() {
        inputN = ""
        inputA = ""
        inputB = ""
    }
}

// MARK: - Monochrome Result Box Component
struct MonoResultBox: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.primary.opacity(0.12), lineWidth: 1))
    }
}

#Preview {
    ContentView()
}
