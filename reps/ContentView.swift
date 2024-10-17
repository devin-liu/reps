import SwiftUI
import UIKit

// Main ContentView struct conforming to the View protocol
struct ContentView: View {
    // State variables to manage timer, tasks, and UI states
    @State private var timeElapsed = 0.0 // Tracks the elapsed time
    @State private var timer: Timer? // Timer object
    @State private var isRunning = false // Indicates if the timer is running
    @State private var laps: [Double] = [] // Stores lap times
    @State private var taskInput: String = "" // User input for tasks
    @State private var tasks: [String] = [] // List of tasks
    @State private var currentTaskIndex = 0 // Index of the current task
    
    // Computed property to format the elapsed time as a string
    var formattedTime: String {
        let minutes = Int(timeElapsed) / 60
        let seconds = Int(timeElapsed) % 60
        let milliseconds = Int((timeElapsed.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
    
    // Computed property to get the current task or a completion message
    var currentTask: String {
        guard !tasks.isEmpty, currentTaskIndex < tasks.count else {
            return "All tasks completed!"
        }
        return tasks[currentTaskIndex]
    }
    
    // The body of the view
    var body: some View {
        VStack(spacing: 20) {
            // Task Input Section using a custom PasteAwareTextView
            PasteAwareTextView(text: $taskInput, onPaste: processTasks)
                .frame(height: 100) // Sets the height of the text view
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1)) // Adds a border
                .padding() // Adds padding around the text view
            
            // Display the current task if there are tasks
            if !tasks.isEmpty {
                Text("Current Task:")
                    .font(.headline) // Sets the font to headline
                Text(currentTask)
                    .font(.title3) // Sets the font to title3
                    .foregroundColor(.blue) // Sets the text color to blue
                    .padding() // Adds padding
                    .multilineTextAlignment(.center) // Centers the text
            }
            
            // Timer Display showing the formatted elapsed time
            Text(formattedTime)
                .font(.system(size: 50, weight: .bold, design: .monospaced)) // Monospaced bold font
                .padding() // Adds padding
            
            // Control Buttons for Start/Stop and Lap/Reset functionalities
            HStack(spacing: 30) {
                // Start or Stop button based on the timer state
                Button(action: {
                    if isRunning {
                        stopTimer() // Stops the timer if it's running
                    } else {
                        startTimer() // Starts the timer if it's stopped
                    }
                }) {
                    Text(isRunning ? "Stop" : "Start") // Button label changes based on state
                        .font(.title) // Sets the font to title
                        .foregroundColor(.white) // Sets the text color to white
                        .frame(width: 100, height: 50) // Sets the button size
                        .background(isRunning ? Color.red : Color.green) // Changes background color based on state
                        .cornerRadius(10) // Rounds the corners
                }
                
                // Lap or Reset button based on the timer state
                Button(action: {
                    if isRunning {
                        addLap() // Adds a lap if the timer is running
                        handleNextTask() // Moves to the next task
                    } else {
                        resetTimer() // Resets the timer if it's stopped
                    }
                }) {
                    Text(isRunning ? "Lap" : "Reset") // Button label changes based on state
                        .font(.title) // Sets the font to title
                        .foregroundColor(.white) // Sets the text color to white
                        .frame(width: 100, height: 50) // Sets the button size
                        .background(Color.blue) // Sets the background color to blue
                        .cornerRadius(10) // Rounds the corners
                }
            }
            
            // List to display lap times if there are any laps
            if !laps.isEmpty {
                List {
                    // Iterates over laps with their indices
                    ForEach(Array(zip(laps.indices, laps)), id: \.0) { index, lap in
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Task \(laps.count - index):") // Displays the task number
                                    .font(.headline) // Sets the font to headline
                                Spacer() // Adds space between elements
                                Text(formatTime(lap)) // Displays the formatted lap time
                                    .font(.system(.body, design: .monospaced)) // Monospaced body font
                            }
                            // Displays the task name if the index is within bounds
                            if index < tasks.count {
                                Text(tasks[min(laps.count - index - 1, tasks.count - 1)])
                                    .font(.subheadline) // Sets the font to subheadline
                                    .foregroundColor(.blue) // Sets the text color to blue
                            }
                        }
                    }
                }
                .frame(maxHeight: 200) // Limits the height of the list
            }
        }
        .padding() // Adds padding around the VStack
    }
    
    // Processes the tasks by splitting the input text into individual tasks
    private func processTasks() {
        tasks = taskInput.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } // Trims whitespace and newlines
            .filter { !$0.isEmpty } // Filters out empty lines
        
        currentTaskIndex = 0 // Resets the current task index
    }
    
    // Handles moving to the next task or stopping the timer if all tasks are completed
    private func handleNextTask() {
        if currentTaskIndex >= tasks.count - 1 {
            // This was the last task, stop the timer
            stopTimer()
            // Update the current task index to indicate completion
            currentTaskIndex = tasks.count
        } else {
            // Move to the next task
            currentTaskIndex += 1
        }
    }
    
    // Starts the timer and updates the elapsed time every 0.01 seconds
    private func startTimer() {
        isRunning = true // Sets the timer state to running
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            timeElapsed += 0.01 // Increments the elapsed time
        }
    }
    
    // Stops the timer and updates the state
    private func stopTimer() {
        timer?.invalidate() // Invalidates the timer
        timer = nil // Resets the timer object
        isRunning = false // Sets the timer state to not running
    }
    
    // Resets the timer, laps, and task index
    private func resetTimer() {
        timeElapsed = 0 // Resets the elapsed time
        laps.removeAll() // Clears all laps
        currentTaskIndex = 0 // Resets the current task index
    }
    
    // Adds the current elapsed time as a lap
    private func addLap() {
        laps.insert(timeElapsed, at: 0) // Inserts the lap at the beginning of the laps array
    }
    
    // Formats a given time in seconds to a string in MM:SS.MS format
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}

// Custom UIViewRepresentable to handle paste actions in a UITextView
struct PasteAwareTextView: UIViewRepresentable {
    @Binding var text: String // Binds the text content
    var onPaste: () -> Void // Closure to handle paste actions
    
    // Creates the UITextView
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator // Sets the delegate
        textView.font = UIFont.preferredFont(forTextStyle: .body) // Sets the font
        return textView
    }
    
    // Updates the UITextView with the latest text
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    // Creates the coordinator for handling UITextViewDelegate methods
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator class to act as the UITextViewDelegate
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: PasteAwareTextView // Reference to the parent view
        
        init(_ parent: PasteAwareTextView) {
            self.parent = parent
        }
        
        // Updates the bound text when the text view changes
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
        
        // Detects paste actions and triggers the onPaste closure
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if UIPasteboard.general.hasStrings {
                // Delay the onPaste call to ensure the text is updated first
                DispatchQueue.main.async {
                    self.parent.onPaste()
                }
            }
            return true // Allows the text change
        }
    }
}
