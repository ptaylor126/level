import SwiftData
import SwiftUI

// MARK: - ScheduleBlock Identifiable

extension ScheduleBlock: Identifiable {}

// MARK: - Outer wrapper resolves environment then hands off to inner view

struct ScheduleView: View {
  @EnvironmentObject private var scheduleManager: ScheduleManager

  var body: some View {
    ScheduleInnerView(manager: scheduleManager)
  }
}

// MARK: - Inner view owns the view model (receives manager at init time)

private struct ScheduleInnerView: View {
  @Environment(\.modelContext) private var context
  @Environment(\.scenePhase) private var scenePhase

  @StateObject private var viewModel: ScheduleViewModel

  @State private var appeared = false
  @State private var showAddSheet = false
  @State private var editingBlock: ScheduleBlock? = nil

  init(manager: ScheduleManager) {
    _viewModel = StateObject(wrappedValue: ScheduleViewModel(manager: manager))
  }

  var body: some View {
    ZStack {
      Color.vintageGrape.ignoresSafeArea()

      ScrollView(showsIndicators: false) {
        VStack(spacing: 20) {
          topBar

          if viewModel.hasSchedule {
            scheduledContent
          } else {
            EmptyScheduleCard(
              onUseSuggested: {
                viewModel.installDefault(context: context)
              },
              onBuildOwn: {
                showAddSheet = true
              }
            )
          }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 32)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.2), value: appeared)
      }
    }
    .onAppear {
      appeared = true
      viewModel.refresh(context: context)
    }
    .onChange(of: scenePhase) { _, phase in
      if phase == .active {
        viewModel.refresh(context: context)
      }
    }
    .sheet(isPresented: $showAddSheet) {
      BlockEditorSheet(
        onSave: { startH, startM, endH, endM, mode in
          viewModel.addBlock(
            startHour: startH,
            startMinute: startM,
            endHour: endH,
            endMinute: endM,
            mode: mode,
            context: context
          )
        }
      )
    }
    .sheet(item: $editingBlock) { block in
      BlockEditorSheet(
        existingBlock: block,
        onSave: { startH, startM, endH, endM, mode in
          block.startHour = startH
          block.startMinute = startM
          block.endHour = endH
          block.endMinute = endM
          block.mode = mode
          try? context.save()
          viewModel.refresh(context: context)
        },
        onDelete: { b in
          viewModel.removeBlock(b, context: context)
        }
      )
    }
  }

  // MARK: - Top Bar

  private var topBar: some View {
    HStack {
      Text("Schedule")
        .font(.levelH1)
        .foregroundStyle(Color.cream)
      Spacer()
    }
    .padding(.vertical, 4)
  }

  // MARK: - Scheduled Content

  @ViewBuilder
  private var scheduledContent: some View {
    CurrentModeCard(
      mode: viewModel.currentMode,
      modeTitle: viewModel.currentModeTitle,
      nextChangeLabel: viewModel.nextChangeLabel
    )

    quickActionRow

    ScheduleTimelineCard(blocks: viewModel.blocks)

    BlockListCard(
      blocks: viewModel.blocks,
      onEdit: { block in
        editingBlock = block
      },
      onDelete: { block in
        viewModel.removeBlock(block, context: context)
      }
    )

    LevelButton(title: "Add time block", style: .ghostOnDark) {
      showAddSheet = true
    }
  }

  // MARK: - Quick Actions

  private var quickActionRow: some View {
    HStack(spacing: 12) {
      LevelButton(title: "Boss Level now", style: .ghostOnDark) {
        viewModel.setQuickMode(.boss, context: context)
      }
      LevelButton(title: "Rest Level now", style: .ghostOnDark) {
        viewModel.setQuickMode(.rest, context: context)
      }
    }
  }
}

#Preview {
  ScheduleView()
    .environmentObject(ScheduleManager())
    .modelContainer(DataStore.shared.container)
}
