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
        ZStack {
            // Banner view that slides down when timer is running
            if isRunning {
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(currentTask)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(formattedTime)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue)
                    .transition(.move(edge: .top))
                    Spacer()
                }
                .zIndex(1) // Ensure banner stays on top
            }
            
            // Main content
            VStack(spacing: 20) {
                // Add padding at the top when banner is showing
                if isRunning {
                    Spacer()
                        .frame(height: 70)
                }
                
                PasteAwareTextView(text: $taskInput, onPaste: processTasks)
                    .frame(height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    .padding()
                
                if !tasks.isEmpty && !isRunning {
                    Text("Current Task:")
                        .font(.headline)
                    Text(currentTask)
                        .font(.title3)
                        .foregroundColor(.blue)
                        .padding()
                        .multilineTextAlignment(.center)
                }
                
                Text(formattedTime)
                    .font(.system(size: 50, weight: .bold, design: .monospaced))
                    .padding()
                
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
            .animation(.easeInOut, value: isRunning)
        }
    }
    
    // Existing helper functions remain the same
    private func processTasks() {
        tasks = taskInput.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        currentTaskIndex = 0
    }
    
    private func handleNextTask() {
        if currentTaskIndex >= tasks.count - 1 {
            stopTimer()
            currentTaskIndex = tasks.count
        } else {
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

// PasteAwareTextView struct remains unchanged
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
                DispatchQueue.main.async {
                    self.parent.onPaste()
                }
            }
            return true
        }
    }
}
