//
//  ContentView.swift
//  CalcuN2
//
//  Created by MAY 01 on 14/9/26.
//

import SwiftUI

struct ContentView: View {
    @State private var numberInput: String = ""
    
    // Tính n^2 từ dữ liệu nhập vào
    private var resultText: String {
        guard let n = Double(numberInput) else {
            return numberInput.isEmpty ? "Number pls" : "this is not a number"
        }
        
        let squared = pow(n, 2)
        return "Kết quả: \(squared)"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Power 2 (n^2)")
                .font(.title)
                .bold()
            
            TextField(" ", text: $numberInput)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            Text(resultText)
                .font(.title2)
                .foregroundColor(.blue)
                .padding()
            
            Button("<-") {
                numberInput = ""
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .disabled(numberInput.isEmpty)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
