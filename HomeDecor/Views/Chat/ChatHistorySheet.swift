//
//  ChatHistorySheet.swift
//  HomeDecor
//
//  AI Chat — saved conversation history. Tap a row to reopen it; enter select
//  mode to delete one or many (with a confirmation). Coral Glass theme.
//

import SwiftUI
import Factory

struct ChatHistorySheet: View {
    @InjectedObject(\.chatStore) private var store: ChatStore
    var onClose: () -> Void

    @State private var selectMode = false
    @State private var selected: Set<String> = []
    @State private var showDelete = false

    var body: some View {
        VStack(spacing: 0) {
            header
            if store.conversations.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(store.conversations) { row($0) }
                    }
                    .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 20)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BlobBackground().ignoresSafeArea())
        .confirmationDialog(
            String(format: "delete_chats_title".localized, selected.count),
            isPresented: $showDelete, titleVisibility: .visible
        ) {
            Button("delete".localized, role: .destructive) {
                store.delete(selected); exitSelect()
            }
            Button("cancel".localized, role: .cancel) { }
        } message: {
            Text("delete_chats_message".localized)
        }
        .animation(.easeInOut(duration: 0.2), value: selected.isEmpty)
    }

    // MARK: Header

    private var header: some View {
        ZStack {
            Text(selectMode ? String(format: "n_selected".localized, selected.count) : "chat_history".localized)
                .font(.system(size: 17, weight: .semibold)).foregroundStyle(AppColor.ink)
            HStack {
                Button { selectMode ? exitSelect() : onClose() } label: {
                    Image(systemName: selectMode ? "xmark" : "chevron.left")
                        .font(.system(size: 17, weight: .semibold)).foregroundStyle(AppColor.ink)
                        .frame(width: 44, height: 44).glassButton()
                }
                .buttonStyle(PressableStyle())
                Spacer()
                if store.conversations.isEmpty {
                    Color.clear.frame(width: 44, height: 44)
                } else if selectMode {
                    HStack(spacing: 6) {
                        Button { toggleAll() } label: {
                            Text("all".localized).font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(AppColor.coral).frame(height: 44)
                        }
                        Button { if !selected.isEmpty { showDelete = true } } label: {
                            Image(systemName: "trash").font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(selected.isEmpty ? AppColor.inkTertiary : Color(hex: 0xFF5A4A))
                                .frame(width: 44, height: 44).glassButton()
                        }
                        .buttonStyle(PressableStyle())
                        .disabled(selected.isEmpty)
                    }
                } else {
                    Button { selectMode = true } label: {
                        Image(systemName: "checkmark.circle").font(.system(size: 18, weight: .medium))
                            .foregroundStyle(AppColor.ink).frame(width: 44, height: 44).glassButton()
                    }
                    .buttonStyle(PressableStyle())
                }
            }
        }
        .frame(height: 44).padding(.horizontal, 24).padding(.top, 12).padding(.bottom, 10)
    }

    // MARK: Row

    private func row(_ convo: ChatConversation) -> some View {
        let isOn = selected.contains(convo.id)
        return Button {
            if selectMode { toggle(convo.id) }
            else { store.open(convo); onClose() }
        } label: {
            HStack(spacing: 12) {
                if selectMode {
                    Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22)).foregroundStyle(isOn ? AppColor.coral : AppColor.inkTertiary)
                }
                AIAvatar(size: 40)
                VStack(alignment: .leading, spacing: 3) {
                    Text(convo.title).font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColor.ink).lineLimit(1)
                    Text(convo.preview).font(.system(size: 13))
                        .foregroundStyle(AppColor.inkSecondary).lineLimit(1)
                }
                Spacer(minLength: 8)
                Text(dateLabel(convo.updatedAt)).font(.system(size: 12))
                    .foregroundStyle(AppColor.inkTertiary)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .glassPanel(22)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle())
    }

    // MARK: Empty

    private var emptyState: some View {
        VStack(spacing: 10) {
            Spacer()
            AIAvatar(size: 96).opacity(0.9)
            Text("no_history".localized)
                .font(.system(size: 16, weight: .semibold)).foregroundStyle(AppColor.ink)
                .padding(.top, 6)
            Spacer(); Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Helpers

    private func toggle(_ id: String) {
        if selected.contains(id) { selected.remove(id) } else { selected.insert(id) }
    }
    private func toggleAll() {
        let all = Set(store.conversations.map(\.id))
        selected = selected.count == all.count ? [] : all
    }
    private func exitSelect() { selectMode = false; selected = [] }

    private func dateLabel(_ d: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = Calendar.current.isDateInToday(d) ? "HH:mm" : "d MMM"
        return f.string(from: d)
    }
}
