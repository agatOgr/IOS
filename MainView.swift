import SwiftUI

struct MainView: View {
    @State private var showSettings = false
    @State private var selectedTab = 1

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            TabView(selection: $selectedTab) {
                // Dodaj miejsce
                NavigationStack {
                    AddPlaceView()
                        .navigationTitle("Dodaj miejsce")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 0 ? "plus.circle.fill" : "plus.circle")
                        Text("Dodaj")
                    }
                }
                .tag(0)

                // Gra
                NavigationStack {
                    StartScreenView()
                        .navigationTitle("GeoGuessr")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    showSettings.toggle()
                                } label: {
                                    Image(systemName: "gearshape.fill")
                                        .imageScale(.large)
                                }
                                .accessibilityLabel("Ustawienia gry")
                            }
                        }
                        .sheet(isPresented: $showSettings) {
                            GameSettingsView()
                        }
                }
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 1 ? "gamecontroller.fill" : "gamecontroller")
                        Text("Gra")
                    }
                }
                .tag(1)

                // Historia gry
                NavigationStack {
                    GameHistoryView()
                        .navigationTitle("Historia")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 2 ? "clock.arrow.circlepath" : "clock")
                        Text("Historia")
                    }
                }
                .tag(2)
            }
            .accentColor(.blue)
            .animation(.easeInOut(duration: 0.25), value: selectedTab)
        }
    }
}
