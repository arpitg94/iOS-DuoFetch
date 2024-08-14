import SwiftUI

struct APITestView: View {
    @State private var name: String = ""
    @State private var email: String = ""

    var body: some View {
        VStack {
            TextField("Name", text: $name)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Email", text: $email)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: {
                submitUser()
            }) {
                Text("Submit")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }

    func submitUser() {
        guard let url = URL(string: "http://localhost:8080/users") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let user = ["name": name, "email": email]
        request.httpBody = try? JSONSerialization.data(withJSONObject: user, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
            } else {
                print("Success")
            }
        }
        task.resume()
    }
}

struct APITestView_Previews: PreviewProvider {
    static var previews: some View {
        APITestView()
    }
}
