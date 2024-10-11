# Reps

Reps is a SwiftUI-based stopwatch application designed to help you manage and track your tasks efficiently. With integrated lap timing and task management features, Reps allows you to monitor the time spent on each task, ensuring productivity and effective time management.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Screenshots](#screenshots)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Precise Timing**

  - Digital display showing minutes, seconds, and centiseconds.
  - Timer updates every 0.01 seconds for high accuracy.

- **Start/Stop Functionality**

  - Toggle the timer with a Start/Stop button that changes color between green (active) and red (inactive).

- **Lap Timer**

  - Record lap times for individual tasks.
  - Lap times are displayed in a scrollable list, showing both the time and the corresponding task.

- **Task Management**

  - Input a list of tasks using a text editor, with each task on a new line.
  - Process tasks into an array of strings for sequential tracking.
  - Display the current task above the timer.
  - Automatically advance to the next task with each lap.
  - Stop the timer automatically when all tasks are completed, displaying a completion message.

- **User-Friendly Interface**
  - Responsive design with a maximum height for the lap list to optimize screen space.
  - Clear visual indicators for current task and timer status.

## Installation

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yourusername/reps.git
   ```

2. **Open in Xcode**

   Navigate to the project directory and open `Reps.xcodeproj` with Xcode.

3. **Run the Application**

   - Select the desired simulator or your physical device.
   - Click the **Run** button (▶️) in Xcode to build and launch the app.

## Usage

1. **Enter Your Tasks**

   - Open the app and navigate to the task input area.
   - Enter each task on a separate line in the text editor.

2. **Process Tasks**

   - Click the **Process Tasks** button to parse the input text into individual tasks.
   - The first task will appear above the timer.

3. **Start the Timer**

   - Press the **Start** button to begin the stopwatch.

4. **Record Laps**

   - For each task, press the **Lap** button to record the time spent.
   - The next task will automatically appear, and the timer will continue.

5. **Completion**

   - After the final task, pressing **Lap** will record the last time and automatically stop the timer.
   - A message stating "All tasks completed!" will be displayed.

6. **Reset**
   - When the timer is stopped, you can reset it to clear all laps and tasks.

## Screenshots



## Contributing

Contributions are welcome! Please follow these steps:

1. **Fork the Repository**

2. **Create a Feature Branch**

   ```bash
   git checkout -b feature/YourFeature
   ```

3. **Commit Your Changes**

   ```bash
   git commit -m "Add your feature"
   ```

4. **Push to the Branch**

   ```bash
   git push origin feature/YourFeature
   ```

5. **Open a Pull Request**

## License

This project is licensed under the [GPL-3.0 license](LICENSE).
