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

// Date formatter for displaying today's date under the title
private let entryDateTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium   // Dec 10, 2025
    formatter.timeStyle = .short    // 9:42 PM
    return formatter
}()
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .full  // e.g. Monday, December 16, 2025
    return formatter
}()

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: Entry.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.date, ascending: false)]
    ) private var allEntries: FetchedResults<Entry>

    @State private var journalText: String = ""
    @State private var selectedMood: Int16 = 3  // Default mood rating (1 to 5)

    @State private var selectedDate: Date = Date()
    @State private var isShowingCalendar = false

    private var filteredEntries: [Entry] {
        allEntries.filter { entry in
            guard let entryDate = entry.date else { return false }
            return Calendar.current.isDate(entryDate, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Spacer()
                // Emoji mood picker
                HStack {
                    
                    Spacer()
                    ForEach(1...5, id: \.self) { mood in
                        Text(moodEmoji(for: mood))
                            .font(.largeTitle)
                            .opacity(selectedMood == mood ? 1.0 : 0.5)  // Dim unselected emojis
                            .onTapGesture {
                                selectedMood = Int16(mood)
                            }
                    }
                    Spacer()
                }
                .padding(.horizontal)

                // Text editor for journal entry
                TextEditor(text: $journalText)
                    .padding()
                    .border(Color.gray, width: 1)
                    .frame(height: 350)

                // Save button
                Button(action: saveEntry) {
                    Text("Save Entry")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(journalText.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(journalText.isEmpty)
                .padding(.horizontal)

                // List of entries filtered by selected date
                List {
                    if filteredEntries.isEmpty {
                        Text("No entries for this day.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(filteredEntries) { entry in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    if let entryDate = entry.date {
                                        Text(entryDate, formatter: entryDateTimeFormatter)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }


                                    Spacer()

                                    Text(moodEmoji(for: Int(entry.mood)))
                                        .font(.title2)
                                }
                                Text(entry.text ?? "")
                                    .font(.body)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: deleteEntries)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Spacer()
                        Text("Daily Journal")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.primary)
                        Spacer()
                        Text(selectedDate, formatter: dateFormatter)
                            .font(.headline)
                            .bold()
                            .foregroundColor(.primary)
                    }
                    
                }
                

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingCalendar.toggle()
                    } label: {
                        Image(systemName: "calendar")
                    }
                    .accessibilityLabel("Select date")
                }
            }
            .sheet(isPresented: $isShowingCalendar) {
                CalendarSheet(selectedDate: $selectedDate)
            }
        }
    }

    // Helper function to get emoji for mood rating
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

    private func saveEntry() {
        withAnimation {
            let newEntry = Entry(context: viewContext)
            newEntry.id = UUID()
            newEntry.date = selectedDate
            newEntry.text = journalText
            newEntry.mood = selectedMood

            do {
                try viewContext.save()
                journalText = ""
                selectedMood = 3  // Reset mood to neutral
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteEntries(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredEntries[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// Calendar modal sheet view
struct CalendarSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) var dismiss

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

#Preview {
    ContentView()
}

