import sys
import datetime
from PyQt5.QtWidgets import QApplication, QDialog, QLineEdit, QTextEdit
from PyQt5.QtCore import pyqtSignal, Qt, QEvent, QThread, pyqtSlot, QTimer
from PyQt5.uic import loadUi
from main import Logger, automate_report

message = ''


class AutomationThread(QThread):
    # Define custom signals to communicate with the main thread
    progress_updated = pyqtSignal(int)
    finished = pyqtSignal()
    log_updated = pyqtSignal(str)  # Custom signal to send log messages
    password_text_updated = pyqtSignal(str)  # Custom signal for updating PasswordText label

    def __init__(self):
        super(AutomationThread, self).__init__()

        self.progress = 0
        self.total_steps = 100  # You can adjust this value based on the total steps in start_automation

    def run(self):
        # Run the start_automation function
        print('starting the function')

        # Call the start_automation function with progress_callback
        def progress_callback(step):
            self.progress = (step * 100) // self.total_steps
            self.progress_updated.emit(self.progress)

        # Call the start_automation function with progress_callback_text
        def progress_callback_text(text):
            self.password_text_updated.emit(text)  # Emit the signal to update the PasswordText label

        # start
        automate_report(progress_callback, progress_callback_text)
        # Emit the finished signal to indicate the completion
        self.finished.emit()


class MyDialog(QDialog):
    editing_finished = pyqtSignal()
    # Custom signal for progress updates
    progress_updated = pyqtSignal(int)

    @pyqtSlot(int)
    def update_progress(self, progress):
        # Update the progress bar
        self.progressBar.setValue(progress)

    @pyqtSlot(str)
    def update_password_text(self, text):
        # Update the PasswordText label with the provided message
        self.PasswordText.setText(text)

    @pyqtSlot(str)
    def update_display(self, message):
        self.TDisplay.append(message)
        # Scroll to the last row
        scrollbar = self.TDisplay.verticalScrollBar()
        scrollbar.setValue(scrollbar.maximum())

    def __init__(self):
        super(MyDialog, self).__init__()
        # Load the UI from the XML file
        loadUi("./UI/nbp_ui.ui", self)

        # Set the fixed size of the window
        self.setFixedSize(402, 202)

        # Connect the "Apply" buttons click events to their functions
        self.BFinished.clicked.connect(self.on_finished_clicked)

        # Create the logger object
        report_date = datetime.datetime.now().strftime("%Y-%m-%d")
        log_file_name = f'Log/{report_date}_LOG.txt'
        log_file = open(log_file_name, "w")
        self.logger = Logger(log_file)

        # Connect the log_updated signal from the logger to the update_display slot
        self.logger.log_updated.connect(self.update_display)

        # Assign the logger as the new sys.stdout
        sys.stdout = self.logger

    def save_logs(self):
        report_date = datetime.datetime.now().strftime("%Y-%m-%d")
        log_file_name = f'Log/{report_date}_LOG.txt'
        with open(log_file_name, 'w') as log_file:
            log_file.write(self.TDisplay.toPlainText())

    def on_start(self):
        # Create the AutomationThread and start it
        self.automation_thread = AutomationThread()

        # Connect the password_text_updated signal from the AutomationThread to the update_password_text slot
        self.automation_thread.password_text_updated.connect(self.update_password_text)
        # Connect the progress_updated signal from the AutomationThread to the update_progress slot
        self.automation_thread.progress_updated.connect(self.update_progress)
        # Connect the log_updated signal to the logger.log_updated signal
        self.automation_thread.log_updated.connect(self.logger.log_updated)

        self.automation_thread.finished.connect(self.on_automation_finished)

        self.progressBar.setEnabled(True)
        # Start the automation thread
        self.automation_thread.start()

    @staticmethod
    def on_finished_clicked():
        # Close the application
        QApplication.quit()  # or sys.exit()

    def on_automation_finished(self):
        # Enable the "Start" button when the automation is finished
        self.BFinished.setEnabled(True)
        # Save the logs to the log file
        self.save_logs()


if __name__ == "__main__":
    try:
        # Your main program logic here
        app = QApplication(sys.argv)
        dialog = MyDialog()
        dialog.show()
        dialog.on_start()  # Call on_start function to start the automation thread
        sys.exit(app.exec_())
    except Exception as e:
        print("An error occurred:", e)
        input("Press Enter to exit...")
        sys.exit(1)

