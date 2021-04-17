//
//  ContentView.swift
//  BetterRest
//
//  Created by Adrià Ros on 17/4/21.
//

import SwiftUI

// Challenge

// 1. Replace each VStack in our form with a Section, where the text view is the title of the section.
// 2. Replace the “Number of cups” stepper with a Picker showing the same range of values.
// 3. Change the user interface so that it always shows their recommended bedtime using a nice and large font.

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    let cups = Array(0...99)
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    var body: some View {
        
        NavigationView {
            
            Form {
                
                Section { // 1.
                    Text("When do you want to wake up?")
                        .font(.headline)

                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())
                }
                

                Section {// 1.
                    Text("Desired amount of sleep")
                        .font(.headline)

                    Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                        Text("\(sleepAmount, specifier: "%g") hours")
                    }
                }
                
                Section {// 1.
                    Text("Daily coffee intake")
                        .font(.headline)

                    // 2.
                    Picker(selection: $coffeeAmount, label: Text("Number of cups"), content: {
                        ForEach(0 ..< cups.count) {
                            Text("\(self.cups[$0])")
                        }
                    })
                    
                    // 2.
//                    Stepper(value: $coffeeAmount, in: 1...20) {
//                        if coffeeAmount == 1 {
//                            Text("1 cup")
//                        } else {
//                            Text("\(coffeeAmount) cups")
//                        }
//                    }
                }
                
                Section {
                    Text("Your ideal bedtime is:")
                        .font(.headline)
                    Text("\(alertMessage)")
                }
            }
            
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            
            .navigationBarTitle("BetterRest")
            
            // 3.
            .onAppear() {
                calculateBedtime()
            }
            
            .onChange(of: sleepAmount, perform: { value in
                calculateBedtime()
            })
            
            .onChange(of: wakeUp, perform: { value in
                calculateBedtime()
            })
            
            // 3.
//            .navigationBarItems(trailing:
//                Button(action: calculateBedtime) {
//                    Text("Calculate")
//                }
//            )
        }
    }
    
    func calculateBedtime() {
        
        let model = SleepCalculator()
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short

            alertMessage = formatter.string(from: sleepTime)
            alertTitle = "Your ideal bedtime is…"
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        // 3.
//        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
