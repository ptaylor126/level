import SwiftUI

struct ComingSoonCard: View {
  let title: String
  let description: String
  let iconName: String
  @Binding var isSignedUp: Bool
  @Binding var emailInput: String

  @State private var showEmailField: Bool = false
  @State private var localEmail: String = ""
  @FocusState private var emailFocused: Bool

  // Pre-fill with any partially typed value passed in
  private var emailIsValid: Bool {
    localEmail.contains("@")
  }

  var body: some View {
    LevelCard(background: .cream, showBorder: true) {
      VStack(alignment: .leading, spacing: 12) {
        // Title row
        HStack(spacing: 10) {
          Image(systemName: iconName)
            .font(LevelFont.bold(17))
            .foregroundStyle(Color.vintageGrape)
          Text(title)
            .font(.levelH2)
            .foregroundStyle(Color.vintageGrape)
          Spacer()
        }

        Text(description)
          .font(.levelBody)
          .foregroundStyle(Color.mutedGrape)
          .fixedSize(horizontal: false, vertical: true)

        if isSignedUp {
          confirmedView
        } else if showEmailField {
          emailCaptureView
        } else {
          notifyButton
        }
      }
    }
  }

  // MARK: - Sub-views

  private var notifyButton: some View {
    Button {
      withAnimation(.easeInOut(duration: 0.2)) {
        showEmailField = true
        emailFocused = true
      }
    } label: {
      Text("Notify me")
        .font(LevelFont.bold(15))
        .frame(maxWidth: .infinity, minHeight: 48)
        .foregroundStyle(Color.vintageGrape)
        .background(Color.warmGrey)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    .buttonStyle(.plain)
  }

  private var emailCaptureView: some View {
    VStack(spacing: 10) {
      TextField("Your email", text: $localEmail)
        .font(.levelBody)
        .foregroundStyle(Color.vintageGrape)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.warmGrey.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
          RoundedRectangle(cornerRadius: 10, style: .continuous)
            .strokeBorder(Color.warmGrey, lineWidth: 1)
        )
        .keyboardType(.emailAddress)
        .textContentType(.emailAddress)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .focused($emailFocused)

      Button {
        guard emailIsValid else { return }
        emailInput = localEmail
        withAnimation(.easeInOut(duration: 0.2)) {
          isSignedUp = true
          showEmailField = false
        }
      } label: {
        Text("Get notified")
          .font(LevelFont.bold(15))
          .frame(maxWidth: .infinity, minHeight: 48)
          .foregroundStyle(emailIsValid ? Color.cream : Color.mutedGrape)
          .background(emailIsValid ? Color.vintageGrape : Color.warmGrey)
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
      }
      .buttonStyle(.plain)
      .disabled(!emailIsValid)
      .animation(.easeInOut(duration: 0.15), value: emailIsValid)
    }
  }

  private var confirmedView: some View {
    HStack(spacing: 8) {
      Image(systemName: "checkmark.circle.fill")
        .foregroundStyle(Color.teaGreen)
        .font(LevelFont.bold(15))
      Text("We'll let you know.")
        .font(LevelFont.bold(15))
        .foregroundStyle(Color.vintageGrape)
    }
    .frame(maxWidth: .infinity, minHeight: 48, alignment: .center)
  }
}

#Preview {
  @Previewable @State var signedup = false
  @Previewable @State var email = ""
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    VStack(spacing: 16) {
      ComingSoonCard(
        title: "Level-headed leaders",
        description: "Coming soon — invite friends to Level",
        iconName: "person.2",
        isSignedUp: $signedup,
        emailInput: $email
      )
      ComingSoonCard(
        title: "Group up",
        description: "Coming soon — team up with friends",
        iconName: "person.3",
        isSignedUp: $signedup,
        emailInput: $email
      )
    }
    .padding(20)
  }
}
