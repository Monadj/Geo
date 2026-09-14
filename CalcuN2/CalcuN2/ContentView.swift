////  ContentView.swift
//  CalcuN2
//
//  Created by MAY 01 on 14/9/26.
//

import SwiftUI

struct ContentView: View {
    @State private var numberInput: String = ""
    @State private var a: Int = 1
    
    private var resultText: String {
        guard let n = Double(numberInput) else {
            return numberInput.isEmpty ? "Number pls" : "this is not a number"
        }
        
        switch a {
        case 1:
            return "Kết quả: \(pow(n, 2))"
        case 2:
            return "Kết quả: \(pow(n, 3))"
        case 3:
            return "Kết quả: \(pow(n, 4))"
        default:
            return "Lỗi"
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Power \(a + 1) (n^\(a + 1))")
                .font(.title)
                .bold()
            
            TextField("Nhập số...", text: $numberInput)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
        
            HStack(spacing: 15) {
                Button("2") { a = 1 }
                    .buttonStyle(.bordered)
                    .tint(a == 1 ? .blue : .gray)
                
                Button("3") { a = 2 }
                    .buttonStyle(.bordered)
                    .tint(a == 2 ? .blue : .gray)
                
                Button("4") { a = 3 }
                    .buttonStyle(.bordered)
                    .tint(a == 3 ? .blue : .gray)
            }
            
            Text(resultText)
                .font(.title2)
                .foregroundColor(.blue)
                .padding()
            
            Button("<- Clear") {
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
