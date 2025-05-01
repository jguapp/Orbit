import SwiftUI

struct WelcomeView: View {
    @State private var isActive = false
    @State private var starOpacity = 0.0
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                
                // Animated stars
                ForEach(0..<50) { _ in
                    Circle()
                        .fill(Color.white)
                        .frame(width: CGFloat.random(in: 1...3))
                        .position(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                        )
                        .opacity(starOpacity)
                }
                
                // Planet gradient
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.2, green: 0.3, blue: 0.7),
                                Color(red: 0.3, green: 0.2, blue: 0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .offset(y: -100)
                    .shadow(color: Color(red: 0.3, green: 0.2, blue: 0.6).opacity(0.5), radius: 30)
                
                // Content
                VStack(spacing: 20) {
                    Text("ORBIT")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color(red: 0.3, green: 0.2, blue: 0.6), radius: 10)
                    
                    Text("Your Productivity Universe")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .padding(.bottom, 50)
                    
                    Button(action: {
                        withAnimation {
                            isActive = true
                        }
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.3, green: 0.2, blue: 0.6),
                                        Color(red: 0.5, green: 0.2, blue: 0.7)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                            .shadow(color: Color(red: 0.3, green: 0.2, blue: 0.6).opacity(0.5), radius: 10)
                    }
                }
            }
            .onAppear {
                withAnimation(.easeIn(duration: 2.0)) {
                    starOpacity = 0.8
                }
            }
        }
    }
}

#Preview {
    WelcomeView()
}