//
//  ViewController.swift
//  Calculator
//
//  Created by Paulina Zabielska on 24/03/2025.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var displayResult: UILabel!
    
    var currentNumber: String = "0"
    var previousNumber: Double?
    var operation: String?
    let maxDigits = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayResult.text = currentNumber
        displayResult.numberOfLines = 1
        displayResult.lineBreakMode = .byTruncatingTail
        displayResult.adjustsFontSizeToFitWidth = true
    }
    
    
    // Function to animate button press with scaling effect.
    func buttonPressed(_ sender: UIButton, duration: TimeInterval = 0.1) {
        UIView.animate(withDuration: duration, animations: {
            sender.alpha = 0.6 // Reduce the alpha (opacity) of the button.
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9) // Scale the button down.
        }) { _ in
            UIView.animate(withDuration: duration) {
                sender.alpha = 1.0 // Restore the original opacity.
                sender.transform = .identity // Reset scale back to normal.
            }
        }
    }
    
    
    // Function to handle number button press.
    @IBAction func numberPressed(_ sender: UIButton) {
        buttonPressed(sender)

        if let number = sender.titleLabel?.text { // Get the number from the button.
            if currentNumber == "0" || currentNumber == "-0" {
                // Prevent leading zero when number is 0 or -0.
                currentNumber = number == "0" && currentNumber == "-0" ? "-0" : number
            } else if currentNumber == "-" {
                currentNumber += number
            } else {
                currentNumber += number
            }
            
            currentNumber = String(currentNumber.prefix(maxDigits))
            displayResult.text = currentNumber
        }
    }

    
    // Function to handle AC (clear) button press.
    @IBAction func acPressed(_ sender: UIButton) {
        buttonPressed(sender)
        currentNumber = "0"
        previousNumber = nil
        operation = nil
        displayResult.text = currentNumber
    }
    
    
    // Function to handle comma (decimal) button press.
    @IBAction func commaPressed(_ sender: UIButton) {
        buttonPressed(sender)
        
        if !currentNumber.contains(".") {
            if currentNumber == "-" {
                currentNumber = "-0."
                } else {
                    currentNumber += currentNumber.isEmpty ? "0." : "."
                }
            }
        
        displayResult.text = currentNumber
    }
    
    
    // Function to perform the selected mathematical operation.
    func performCalculation(num1: Double, num2: Double, op: String) -> Double? {
        let operations: [String: (Double, Double) -> Double?] = [
            "+": (+),
            "-": (-),
            "x": (*),
            "/": { $1 == 0 ? nil : $0 / $1 } // Division (handle division by zero).
        ]
        return operations[op]?(num1, num2) // Execute the operation.
    }
    
    
    // Function to format the result to a string.
    func formatResult(_ result: Double) -> String {
        let formattedResult = result == floor(result) ? String(format: "%.0f", result) : String(result) // If integer, remove decimals.
        // Limit decimal precision.
        return formattedResult.count > maxDigits ? String(result.formatted(.number.precision(.fractionLength(5)))) : formattedResult
    }
    
    
    // Function to handle operation button press (+, -, x, /).
    @IBAction func operationPressed(_ sender: UIButton) {
        buttonPressed(sender)

        guard let op = sender.titleLabel?.text else { return }

        if currentNumber.isEmpty || currentNumber == "0" { // Handle empty or zero entry.
            if op == "-" && previousNumber == nil {
                currentNumber = "-" // Handle negative number entry.
                displayResult.text = currentNumber
                return
            }
        }

        if let num = Double(currentNumber) {
            if let prevNum = previousNumber, let currentOp = operation {
                if let result = performCalculation(num1: prevNum, num2: num, op: currentOp) {
                    displayResult.text = formatResult(result) // Display result of calculation.
                    previousNumber = result
                } else {
                    displayResult.text = "Error" // Display error if calculation fails.
                    previousNumber = nil
                    return
                }
            } else {
                previousNumber = num // Set the current number as previous number.
            }
        }

        currentNumber = "" // Reset current number for next input.
        operation = op // Set the selected operation.
    }

    
    // Function to handle equals button press (perform calculation and show result).
    @IBAction func equalsPressed(_ sender: UIButton) {
        buttonPressed(sender)

        guard let op = operation, let num1 = previousNumber else { return }

        let num2 = Double(currentNumber) ?? num1 // Use current number or previous number if empty.

        if let result = performCalculation(num1: num1, num2: num2, op: op) {
            displayResult.text = formatResult(result) // Display the result.
            previousNumber = result // Update previous number for future operations.
        } else {
            displayResult.text = "Error" // Display error in case of invalid calculation.
            previousNumber = nil
        }

        currentNumber = "" // Reset current number for next input.
        operation = nil // Clear operation after calculation.
    }
}
