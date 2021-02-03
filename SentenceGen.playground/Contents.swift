import UIKit

var str = "Hello, playground"

class MarkovChain {
    private let startWords: [String]
    private let links: [String: [Link]]
    
    private(set) var sequence: [String] = []
    
    enum Link: Equatable {
        case end
        case word(options: [String])
        
        var words: [String] {
            switch self {
                case .end: return []
                case .word(let words): return words
            }
        }
    }
    
    init?(with inputFilepath: String) {
        /*
        print("Load Filename: \(inputFilepath)")
        let filePath = Bundle.main.path(forResource: inputFilepath, ofType: ".txt")
        print("Filepath: \(filePath!)")
        let inputFile = FileManager.default.contents(atPath: filePath!)
        print("inputFile: \(inputFile!)")
        let inputString = String(data: inputFile!, encoding: .utf8)
        print("inputString: \(inputString!)")

        return nil
 */
        guard
            let filePath = Bundle.main.path(forResource: inputFilepath, ofType: ".txt"),
            let inputFile = FileManager.default.contents(atPath: filePath),
            let inputString = String(data: inputFile, encoding: .utf8)
        
        else {
            print("Cannot load file")
            return nil
        }
        
        print("File imported successfully!")
        let tokens = inputString.tokenize()
        
        var startWords: [String] = []
        var links: [String: [Link]] = [:]
        
        for index in 0..<tokens.count - 1 {
            let thisToken = tokens[index]
            let nextToken = tokens[index + 1]
            
            if thisToken == String.sentenceEnd {
                startWords.append(nextToken)
                continue
            }
            
            var tokenLinks = links[thisToken, default: []]
            
            if nextToken == String.sentenceEnd {
                if !tokenLinks.contains(.end) {
                    tokenLinks.append(.end)
                }
                
                links[thisToken] = tokenLinks
                continue
            }
            
            let wordLinkIndex = tokenLinks.firstIndex(where: { element in
                if case .word = element {
                    return true
                }
                return true
            })
            
            var options: [String] = []
            if let index = wordLinkIndex {
                options = tokenLinks[index].words
                tokenLinks.remove(at: index)
            }
            
            options.append(nextToken)
            tokenLinks.append(.word(options: options))
            links[thisToken] = tokenLinks
        }
        
        self.links = links
        self.startWords = startWords
        
        print("Model initialised successfully!")
    }
    
    func clear() {
        self.sequence = []
    }
    
    func nextWord() -> String {
        let newWord: String
        
        if self.sequence.isEmpty || self.sequence.last == String.sentenceEnd {
            newWord = startWords.randomElement()!
        } else {
            let lastWord = self.sequence.last!
            let link = links[lastWord]?.randomElement()
            newWord = link?.words.randomElement() ?? "."
        }
        
        self.sequence.append(newWord)
        return newWord
    }
    
    func generate(wordCount: Int = 100) -> String {
        for _ in 0..<wordCount {
            let _ = self.nextWord()
        }
        
        return self.sequence.joined(separator: " ").replacingOccurrences(of: " .", with: ".") + " ..."
    }
}



let file = "wonderland"
if let markovChain = MarkovChain(with: file) {
    print("\n BEGIN TEXT\n==========\n")
    print(markovChain.generate())
    print("\n==========\n END TEXT\n")
} else {
    print("Failure")
}
