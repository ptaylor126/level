import SwiftUI
import SwiftData

struct BlockEditorSheet: View {
  @Environment(\.modelContext) private var context
  @Environment(\.dismiss) private var dismiss

  /// Pass nil to create a new block, pass an existing block to edit it.
  var existingBlock: ScheduleBlock?
  var onSave: (Int, Int, Int, Int, LevelMode) -> Void
  var onDelete: ((ScheduleBlock) -> Void)?

  @State private var startTime: Date
  @State private var endTime: Date
  @State private var selectedMode: LevelMode

  init(
    existingBlock: ScheduleBlock? = nil,
    onSave: @escaping (Int, Int, Int, Int, LevelMode) -> Void,
    onDelete: ((ScheduleBlock) -> Void)? = nil
  ) {
    self.existingBlock = existingBlock
    self.onSave = onSave
    self.onDelete = onDelete

    let cal = Calendar.current
    var comps = DateComponents()

    if let block = existingBlock {
      comps.hour = block.startHour
      comps.minute = block.startMinute
      _startTime = State(initialValue: cal.date(from: comps) ?? Date())

      comps.hour = block.endHour
      comps.minute = block.endMinute
      _endTime = State(initialValue: cal.date(from: comps) ?? Date())

      _selectedMode = State(initialValue: block.mode)
    } else {
      comps.hour = 9
      comps.minute = 0
      _startTime = State(initialValue: cal.date(from: comps) ?? Date())

      comps.hour = 17
      comps.minute = 0
      _endTime = State(initialValue: cal.date(from: comps) ?? Date())

      _selectedMode = State(initialValue: .base)
    }
  }

  var body: some View {
    ZStack {
      Color.vintageGrape.ignoresSafeArea()

      ScrollView(showsIndicators: false) {
        VStack(spacing: 24) {
          // Header
          HStack {
            Text(existingBlock == nil ? "Add time block" : "Edit time block")
              .font(.levelH1)
              .foregroundStyle(Color.cream)
            Spacer()
            Button {
              dismiss()
            } label: {
              Text("Cancel")
                .font(.levelBody)
                .foregroundStyle(Color.mutedGrape)
            }
            .buttonStyle(.plain)
          }
          .padding(.top, 8)

          // Start time picker
          LevelCard(background: .cream.opacity(0.1), showBorder: false) {
            VStack(alignment: .leading, spacing: 8) {
              Text("START TIME")
                .font(.levelLabel)
                .tracking(0.5)
                .foregroundStyle(Color.mutedGrape)

              DatePicker(
                "",
                selection: $startTime,
                displayedComponents: .hourAndMinute
              )
              .datePickerStyle(.wheel)
              .labelsHidden()
              .colorScheme(.dark)
              .frame(maxWidth: .infinity)
            }
          }

          // End time picker
          LevelCard(background: .cream.opacity(0.1), showBorder: false) {
            VStack(alignment: .leading, spacing: 8) {
              Text("END TIME")
                .font(.levelLabel)
                .tracking(0.5)
                .foregroundStyle(Color.mutedGrape)

              DatePicker(
                "",
                selection: $endTime,
                displayedComponents: .hourAndMinute
              )
              .datePickerStyle(.wheel)
              .labelsHidden()
              .colorScheme(.dark)
              .frame(maxWidth: .infinity)
            }
          }

          // Mode picker
          LevelCard(background: .cream, showBorder: true) {
            VStack(alignment: .leading, spacing: 12) {
              Text("MODE")
                .font(.levelLabel)
                .tracking(0.5)
                .foregroundStyle(Color.mutedGrape)

              VStack(spacing: 8) {
                ForEach(LevelMode.allCases.filter { $0 != .off }, id: \.self) { mode in
                  modeRow(mode)
                }
              }
            }
          }

          // Save button
          LevelButton(title: "Save", style: .primaryOnDark) {
            saveBlock()
          }

          // Delete button (editing only)
          if let block = existingBlock {
            Button {
              onDelete?(block)
              dismiss()
            } label: {
              Text("Delete block")
                .font(LevelFont.bold(15))
                .foregroundStyle(Color.rose)
                .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.plain)
          }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
      }
    }
    .presentationDragIndicator(.visible)
  }

  @ViewBuilder
  private func modeRow(_ mode: LevelMode) -> some View {
    Button {
      selectedMode = mode
    } label: {
      HStack(spacing: 12) {
        Circle()
          .fill(mode.segmentColor == .clear ? Color.warmGrey : mode.segmentColor)
          .frame(width: 12, height: 12)
          .overlay(
            Circle()
              .strokeBorder(Color.warmGrey, lineWidth: 0.5)
          )

        VStack(alignment: .leading, spacing: 2) {
          Text(mode.displayName)
            .font(LevelFont.bold(15))
            .foregroundStyle(Color.vintageGrape)
          Text(modeSubtitle(mode))
            .font(.levelCaption)
            .foregroundStyle(Color.mutedGrape)
        }

        Spacer()

        if selectedMode == mode {
          Image(systemName: "checkmark")
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(Color.vintageGrape)
        }
      }
      .padding(12)
      .background(
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .fill(selectedMode == mode ? mode.cardColor : Color.clear)
      )
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }

  private func modeSubtitle(_ mode: LevelMode) -> String {
    switch mode {
    case .boss: return "30s delay, 3 unlocks — maximum friction"
    case .base: return "10s delay, 10 unlocks — normal friction"
    case .rest: return "Fully blocked — no unlocks available"
    case .off: return "No restrictions"
    }
  }

  private func saveBlock() {
    let cal = Calendar.current
    let startHour = cal.component(.hour, from: startTime)
    let startMin = cal.component(.minute, from: startTime)
    let endHour = cal.component(.hour, from: endTime)
    let endMin = cal.component(.minute, from: endTime)

    onSave(startHour, startMin, endHour, endMin, selectedMode)
    dismiss()
  }
}

#Preview {
  BlockEditorSheet(
    onSave: { _, _, _, _, _ in }
  )
}
