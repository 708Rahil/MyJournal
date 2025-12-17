//
//  ContentView.swift
//  MyJournal
//
//  Created by Rahil Gandhi on 2025-12-16.
//

//
//  ContentView.swift
//  MyJournal
//
//  Created by Rahil Gandhi on 2025-12-16.
//

import SwiftUI
import CoreData

// Formatter for written timestamp
private let entryDateTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

// Formatter for header date
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .full
    return formatter
}()



struct CalendarSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()

                Spacer()
            }
            .navigationTitle("Pick a Date")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: Entry.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.createdAt, ascending: false)]
    ) private var allEntries: FetchedResults<Entry>

    @State private var journalText = ""
    @State private var selectedMood: Int16 = 3
    @State private var selectedDate = Date()
    @State private var isShowingCalendar = false

    // Filter entries by the DAY they are for
    private var filteredEntries: [Entry] {
        allEntries.filter {
            guard let entryDate = $0.entryDate else { return false }
            return Calendar.current.isDate(entryDate, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {

                // 📅 Journal day (changes with calendar)
                Text(selectedDate, formatter: dateFormatter)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // 😊 Mood picker
                HStack {
                    ForEach(1...5, id: \.self) { mood in
                        Text(moodEmoji(for: mood))
                            .font(.largeTitle)
                            .opacity(selectedMood == mood ? 1 : 0.4)
                            .onTapGesture {
                                selectedMood = Int16(mood)
                            }
                    }
                }

                // 📝 Journal editor
                TextEditor(text: $journalText)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.4))
                    )
                    .frame(height: 250)

                // 💾 Save button
                Button(action: saveEntry) {
                    Text("Save Entry")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(journalText.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(journalText.isEmpty)

                // 📖 Entries list
                List {
                    if filteredEntries.isEmpty {
                        Text("No entries for this day.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(filteredEntries) { entry in
                            VStack(alignment: .leading, spacing: 6) {

                                // Written timestamp (REAL)
                                if let createdAt = entry.createdAt {
                                    Text("Written \(createdAt, formatter: entryDateTimeFormatter)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                HStack {
                                    Text(entry.text ?? "")
                                    Spacer()
                                    Text(moodEmoji(for: Int(entry.mood)))
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: deleteEntries)
                    }
                }
            }
            .padding()
            .navigationTitle("Daily Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingCalendar.toggle()
                    } label: {
                        Image(systemName: "calendar")
                    }
                }
            }
            .sheet(isPresented: $isShowingCalendar) {
                CalendarSheet(selectedDate: $selectedDate)
            }
        }
        .dismissKeyboardOnTap()

    }

    // Emoji helper
    func moodEmoji(for mood: Int) -> String {
        switch mood {
        case 1: return "😞"
        case 2: return "🙁"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😄"
        default: return "😐"
        }
    }

    // Save with TWO dates
    private func saveEntry() {
        let newEntry = Entry(context: viewContext)
        newEntry.id = UUID()
        newEntry.entryDate = selectedDate      // day the entry is FOR
        newEntry.createdAt = Date()             // moment it was WRITTEN
        newEntry.text = journalText
        newEntry.mood = selectedMood

        try? viewContext.save()

        journalText = ""
        selectedMood = 3
    }

    private func deleteEntries(offsets: IndexSet) {
        offsets.map { filteredEntries[$0] }.forEach(viewContext.delete)
        try? viewContext.save()
    }
}
extension View {
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
}


#Preview {
    ContentView()
}

