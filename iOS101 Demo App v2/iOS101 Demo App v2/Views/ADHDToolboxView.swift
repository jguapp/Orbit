import SwiftUI

struct ADHDToolboxView: View {
    @StateObject private var toolboxManager = ADHDToolboxManager()
    @State private var selectedCategory: ADHDTip.Category?
    @State private var showingBookmarksOnly = false
    @State private var searchText = ""
    
    var filteredTips: [ADHDTip] {
        var tips = toolboxManager.tips
        if showingBookmarksOnly {
            tips = tips.filter { $0.isBookmarked }
        }
        if let category = selectedCategory {
            tips = tips.filter { $0.category == category }
        }
        if !searchText.isEmpty {
            tips = tips.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        return tips
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Search and filter section
                VStack(spacing: 12) {
                    SearchBar(text: $searchText)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            CategoryButton(title: "All", isSelected: selectedCategory == nil) {
                                selectedCategory = nil
                            }
                            
                            ForEach(ADHDTip.Category.allCases, id: \.self) { category in
                                CategoryButton(
                                    title: category.rawValue,
                                    icon: category.icon,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Toggle("Show Bookmarks Only", isOn: $showingBookmarksOnly)
                        .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color(UIColor.systemBackground))
                
                // Tips List
                LazyVStack(spacing: 16) {
                    ForEach(filteredTips) { tip in
                        TipCardView(tip: tip, toolboxManager: toolboxManager)
                            .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("ADHD Toolbox")
        .background(Color(UIColor.systemGroupedBackground))
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search tips", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
    }
}

struct CategoryButton: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.purple : Color(UIColor.secondarySystemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct TipCardView: View {
    let tip: ADHDTip
    @ObservedObject var toolboxManager: ADHDToolboxManager
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: tip.category.icon)
                    .foregroundColor(.purple)
                Text(tip.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: { toolboxManager.toggleBookmark(for: tip) }) {
                    Image(systemName: tip.isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(.purple)
                }
            }
            
            Text(tip.title)
                .font(.headline)
                .lineLimit(2)
            
            Text(tip.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            if let examples = tip.examples {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Examples:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(examples.prefix(2), id: \.self) { example in
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.caption)
                                .foregroundColor(.purple)
                            Text(example)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if examples.count > 2 {
                        Text("And more...")
                            .font(.caption)
                            .foregroundColor(.purple)
                    }
                }
            }
            
            Button("Read More") {
                showingDetail = true
            }
            .font(.caption)
            .foregroundColor(.purple)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5)
        .sheet(isPresented: $showingDetail) {
            TipDetailView(tip: tip, toolboxManager: toolboxManager, isPresented: $showingDetail)
        }
    }
}

struct TipDetailView: View {
    let tip: ADHDTip
    @ObservedObject var toolboxManager: ADHDToolboxManager
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: tip.category.icon)
                            .foregroundColor(.purple)
                        Text(tip.category.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(tip.title)
                        .font(.title)
                        .bold()
                    
                    Text(tip.description)
                        .font(.body)
                    
                    if let examples = tip.examples {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Examples")
                                .font(.headline)
                            
                            ForEach(examples, id: \.self) { example in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .foregroundColor(.purple)
                                    Text(example)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { toolboxManager.toggleBookmark(for: tip) }) {
                        Image(systemName: tip.isBookmarked ? "bookmark.fill" : "bookmark")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
