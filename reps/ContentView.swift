import SwiftUI
import UIKit

struct ContentView: View {
    @State private var timeElapsed = 0.0
    @State private var timer: Timer?
    @State private var isRunning = false
    @State private var laps: [Double] = []
    @State private var taskInput: String = ""
    @State private var tasks: [String] = []
    @State private var currentTaskIndex = 0
    
    var formattedTime: String {
        let minutes = Int(timeElapsed) / 60
        let seconds = Int(timeElapsed) % 60
        let milliseconds = Int((timeElapsed.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
    
    var currentTask: String {
        guard !tasks.isEmpty, currentTaskIndex < tasks.count else {
            return "All tasks completed!"
        }
        return tasks[currentTaskIndex]
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Task Input Section
            PasteAwareTextView(text: $taskInput, onPaste: processTasks)
                .frame(height: 100)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                .padding()
            
            // Current Task Display
            if !tasks.isEmpty {
                Text("Current Task:")
                    .font(.headline)
                Text(currentTask)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .padding()
                    .multilineTextAlignment(.center)
            }
            
            // Timer Display
            Text(formattedTime)
                .font(.system(size: 50, weight: .bold, design: .monospaced))
                .padding()
            
            // Control Buttons
            HStack(spacing: 30) {
                Button(action: {
                    if isRunning {
                        stopTimer()
                    } else {
                        startTimer()
                    }
                }) {
                    Text(isRunning ? "Stop" : "Start")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 100, height: 50)
                        .background(isRunning ? Color.red : Color.green)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    if isRunning {
                        addLap()
                        handleNextTask()
                    } else {
                        resetTimer()
                    }
                }) {
                    Text(isRunning ? "Lap" : "Reset")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 100, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            
            // Lap Times List
            if !laps.isEmpty {
                List {
                    ForEach(Array(zip(laps.indices, laps)), id: \.0) { index, lap in
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Task \(laps.count - index):")
                                    .font(.headline)
                                Spacer()
                                Text(formatTime(lap))
                                    .font(.system(.body, design: .monospaced))
                            }
                            if index < tasks.count {
                                Text(tasks[min(laps.count - index - 1, tasks.count - 1)])
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
        }
        .padding()
    }
    
    private func processTasks() {
        tasks = taskInput.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        currentTaskIndex = 0
    }
    
    private func handleNextTask() {
        if currentTaskIndex >= tasks.count - 1 {
            // This was the last task, stop the timer
            stopTimer()
            // Show completion state
            currentTaskIndex = tasks.count
        } else {
            // Move to next task
            currentTaskIndex += 1
        }
    }
    
    private func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            timeElapsed += 0.01
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    private func resetTimer() {
        timeElapsed = 0
        laps.removeAll()
        currentTaskIndex = 0
    }
    
    private func addLap() {
        laps.insert(timeElapsed, at: 0)
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}

struct PasteAwareTextView: UIViewRepresentable {
    @Binding var text: String
    var onPaste: () -> Void
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: PasteAwareTextView
        
        init(_ parent: PasteAwareTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if UIPasteboard.general.hasStrings {
                // Delay the onPaste call to ensure the text is updated first
                DispatchQueue.main.async {
                    self.parent.onPaste()
                }
            }
            return true
        }
    }
}
