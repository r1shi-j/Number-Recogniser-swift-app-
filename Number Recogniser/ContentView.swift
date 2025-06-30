//
//  ContentView.swift
//  Number Recogniser
//
//  Created by Rishi Jansari on 30/06/2025.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var isShowingAlert = false
    @State private var isEraserOn = false
    @State private var pixels: [Double] = Array(repeating: 1, count: 28 * 28)
    
    let buttonColor = Color(red: 250/255, green: 240/255, blue: 230/255)
    
    var body: some View {
        VStack {
            DrawingView(isShowingAlert: $isShowingAlert, isEraserOn: $isEraserOn, pixels: $pixels)
            HStack {
                Button {
                    isShowingAlert = true
                } label: {
                    Image(systemName: "questionmark.diamond")
                        .resizable()
                        .frame(width: 35, height: 35)
                }
                .buttonStyle(AppButton(color: buttonColor))
                .alert("Prediction from Image", isPresented: $isShowingAlert) {
                    Button("Okay!", role: .cancel) { }
                } message: {
                    Text("\(predictNumber(from: pixels))")
                }

                Button {
                    isEraserOn.toggle()
                } label: {
                    Image(systemName: "pencil.slash")
                        .resizable()
                        .frame(width: 35, height: 35)
                }
                .buttonStyle(AppButton(color: isEraserOn ? Color(red: 299/255, green: 190/255, blue: 168/255) : buttonColor))
                
                Button {
                    for index in 0..<pixels.count {
                        pixels[index] = 1
                    }
                } label: {
                    Image(systemName: "trash")
                        .resizable()
                        .frame(width: 35, height: 35)
                }
                .buttonStyle(AppButton(color: buttonColor))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(.green.opacity(0.35))
        .ignoresSafeArea()
    }
    
    private func predictNumber(from pixels: [Double]) -> Int {
        guard let model = try? MNIST_IMG_Recognizer() else {
            print("Could not create model")
            return -1
        }
        guard let tensorInput = try? MLMultiArray(shape: [1, 28, 28, 1], dataType: .float32) else {
            print("Could not create tensorInput")
            return -1
        }
        for i in 1..<pixels.count {
            tensorInput[i] = NSNumber(value: Float32(1 - pixels[i]))
        }
        do {
            let prediction = try model.prediction(input_1: tensorInput)
            return findMax(of: prediction.Identity)
        } catch {
            print("Error making prediction")
            return -1
        }
    }
    
    private func findMax(of tensor: MLMultiArray) -> Int {
        var max: Float = 0
        var maxIndex: Int = 0
        for i in 0..<tensor.count {
            if tensor[i].floatValue > max {
                max = tensor[i].floatValue
                maxIndex = i
            }
        }
        return maxIndex
    }
}

struct AppButton: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(color)
            .foregroundStyle(Color(red: 128/255, green: 0, blue: 0))
            .clipShape(.rect(cornerRadius: 10))
            .padding()
    }
}
#Preview {
    ContentView()
}
