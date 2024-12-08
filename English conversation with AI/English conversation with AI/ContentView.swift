//
//  ContentView.swift
//  English conversation with AI
//
//  Created by 白井 達也 on 2024/12/08.
//

import SwiftUI
import GoogleGenerativeAI

struct ContentView: View {
    let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: APIKey.default)
    
    enum SegmentType: CaseIterable {
        case jp_trans
        case en_trans
        case correct
        case word1
        case word2
        case free
    }
    
    @State var selectedLayout: SegmentType = .jp_trans
    @State var Prompt = ""
    @State var Respons = ""
    @State var isLoading = false
    @State var allPrompts = ""
    @State var mainPrompt = "この文章を和訳して"
    
    var body: some View {
        ZStack {
            VStack {
                Text("Let's Start English Conversation!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                ScrollView {
                    Text(Respons)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                Picker("Layout", selection: $selectedLayout) {
                    ForEach(SegmentType.allCases, id: \.self) {
                        type in
                        switch type {
                        case .jp_trans:
                            Text("和訳")
                        case .en_trans:
                            Text("英訳")
                        case .correct:
                            Text("添削")
                        case .word1:
                            Text("単語")
                        case .word2:
                            Text("類義語")
                        case .free:
                            Text("自由")
                        }
                        
                    }
                }.pickerStyle(SegmentedPickerStyle())
                    .padding(2)
                    .onChange(of: selectedLayout) { newValue in
                        handleSegmentChange(to: newValue)
                    }
                HStack(spacing: 20) {
                    Button(action: pasteText) {
                        Text("ペースト")
                            .font(.system(size: 14)) // フォントサイズを小さく
                            .padding(6) // ボタン内の余白を小さく
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(4) // 角丸を小さく
                    }
                    Button(action: copyText) {
                        Text("コピー")
                            .font(.system(size: 14)) // フォントサイズを小さく
                            .padding(6) // ボタン内の余白を小さく
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(4) // 角丸を小さく
                    }
                }
                .padding(1) // HStack全体の余白を調整
                
                HStack(spacing: 1) {
                    
                    VStack {
                        TextEditor(text: $Prompt)
                            .frame(maxWidth: .infinity, maxHeight: 200) // 高さを指定
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }.padding(.horizontal, 10)
                    

                    Button(action: {
                        generateRespons()
                    }){
                        Image(systemName: "arrow.up")
                            .frame(width: 40, height: 40)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }.padding(5)
                    
                }
            }
            
            if isLoading {
                Color.black.opacity(0.3)
                ProgressView()
            }
        }
    }
    
    private func pasteText() {
        if let clipboardText = UIPasteboard.general.string {
            Prompt = clipboardText
        } else {
            print("クリップボードにテキストがありません")
        }
    }
    private func copyText() {
        UIPasteboard.general.string = Respons
        print("テキストがコピーされました: \(Respons)")
    }
    func handleSegmentChange(to newValue: SegmentType) {
//        Respons = ""
        switch newValue {
        case .jp_trans:
            print("和訳モードが選択されました")
            mainPrompt = "この文章を和訳して:"
        case .en_trans:
            print("英訳モードが選択されました")
            mainPrompt = "この文章を英訳して(英訳文だけ出力して):"
        case .correct:
            print("添削モードが選択されました(添削箇所を'日本語'で教えて)")
            mainPrompt = "この文章を添削して:"
        case .word1:
            print("単語モードが選択されました")
            mainPrompt = "この言葉の英単語を教えて(英単語だけ出力して):"
        case .word2:
            print("単語モードが選択されました")
            mainPrompt = "この言葉の英単語を複数教えて，()で使い分けを日本語で簡単に説明して:"
        case .free:
            print("自由モードが選択されました")
            mainPrompt = ""
        }
    }
    func generateRespons() {
        isLoading = true
        Respons = ""
        allPrompts = mainPrompt + Prompt
        
        Task {
            do {
                let result = try await model.generateContent(allPrompts)
                isLoading = false
                Respons = result.text ?? "No Respons found"
                Prompt = ""
            } catch {
                Respons = "Sometimes went wrong \n \(error.localizedDescription)"
                isLoading = false
                Prompt = ""
            }
        }
    }
}
