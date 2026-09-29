import SwiftUI

struct LoginView: View {
    @State private var host = ""
    @State private var username = ""
    @State private var password = ""
    @State private var isConnecting = false
    
    let onConnect: (String, String, String) -> Void
    
    // Brand Colors
    private let brandRed = Color(red: 229/255, green: 9/255, blue: 20/255)
    private let darkBackground = Color(red: 0.08, green: 0.04, blue: 0.04)
    private let inputBackground = Color(white: 0.12)
    
    var body: some View {
        ZStack {
      
            RadialGradient(
                gradient: Gradient(colors: [Color(red: 0.25, green: 0, blue: 0), .black]),
                center: .top,
                startRadius: 0,
                endRadius: 1500
            )
            .ignoresSafeArea()
            
            VStack {
                HStack {
                    Text("NETFLIX")
                        .font(.system(size: 64, weight: .black, design: .default))
                        .foregroundColor(brandRed)
                    Spacer()
                }
                .padding(.leading, 80)
                .padding(.top, 60)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text("Enter your info to sign in")
                    .font(.system(size: 54, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 16)
                
                Text("Or get started with a new account.")
                    .font(.system(size: 28))
                    .foregroundColor(Color(white: 0.7))
                    .padding(.bottom, 40)
                
                VStack(spacing: 16) {
                    CustomTvOSInputField(
                        placeholder: "Host URL",
                        text: $host
                    )
                    
                    CustomTvOSInputField(
                        placeholder: "Username",
                        text: $username
                    )
                    
                    CustomTvOSInputField(
                        placeholder: "Password",
                        text: $password,
                        isSecure: true
                    )
                }
                .padding(.bottom, 40)
                
                NetflixConnectButton(title: "Connect", isConnecting: isConnecting) {
                    isConnecting = true
                    onConnect(host, username, password)
                }
                .padding(.bottom, 30)
                
                Button(action: {}) {
                    HStack(spacing: 8) {
                        Text("Get Help")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
                .padding(.bottom, 60)
                
                // Disclaimer
                Text("This page is protected by Google reCAPTCHA to ensure you're not a bot.\nLearn more")
                    .font(.system(size: 18))
                    .foregroundColor(Color(white: 0.5))
                    .lineSpacing(4)
            }
            .frame(width: 750) 
        }
    }
}

struct CustomTvOSInputField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .textFieldStyle(.plain) 
        .padding(.horizontal, 24)
        .padding(.vertical, 22)
        .background(Color(white: 0.12))
        .foregroundColor(.white)
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isFocused ? Color.white : Color(white: 0.3), lineWidth: isFocused ? 3 : 1)
        )
        .focused($isFocused)
        .scaleEffect(isFocused ? 1.02 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isFocused)
    }
}

struct NetflixConnectButton: View {
    let title: String
    let isConnecting: Bool
    let action: () -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                if isConnecting {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.2)
                } else {
                    Text(title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding(.vertical, 24)
            .background(Color(red: 229/255, green: 9/255, blue: 20/255))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .focused($isFocused)
        .scaleEffect(isFocused ? 1.04 : 1.0)
        .shadow(color: isFocused ? Color.white.opacity(0.2) : .clear, radius: 10, y: 5)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isFocused)
    }
}