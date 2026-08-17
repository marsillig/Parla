import Foundation

enum Difficulty: String, Codable, CaseIterable, Sendable {
    case a1, a2, b1

    var label: String {
        rawValue.uppercased()
    }
}

enum Topic: String, Codable, CaseIterable, Sendable {
    case caffe = "caffe"
    case ristorante
    case mercato
    case viaggio
    case lavoro
    case riunioni
    case banca
    case social
    case tempoLibero = "tempo_libero"
    case amicizie
    case appuntamenti
    case salute
    case tecnologia
    case casa
    case informatica
    case cultura

    var label: String {
        switch self {
        case .caffe: return "Caffè e Bar"
        case .ristorante: return "Ristorante e Cibo"
        case .mercato: return "Mercato e Spesa"
        case .viaggio: return "Viaggio e Trasporti"
        case .lavoro: return "Lavoro e Ufficio"
        case .riunioni: return "Riunioni e Business"
        case .banca: return "Banca e Finanza"
        case .social: return "Vita Sociale"
        case .tempoLibero: return "Tempo Libero"
        case .amicizie: return "Amicizie"
        case .appuntamenti: return "Appuntamenti"
        case .salute: return "Salute e Benessere"
        case .tecnologia: return "Tecnologia"
        case .informatica: return "Informatica e Cloud"
        case .casa: return "Casa"
        case .cultura: return "Cultura e Attualità"
        }
    }
}

enum ExerciseMode: String, Codable, Sendable {
    case dictation
    case pronunciation
    case matching
}

struct Phrase: Codable, Identifiable, Equatable, Sendable {
    let id: Int
    let italian: String
    let spanish: String
    let difficulty: Difficulty
    let topic: Topic
    let grammarNote: String?

    init(id: Int, italian: String, spanish: String, difficulty: Difficulty, topic: Topic, grammarNote: String? = nil) {
        self.id = id
        self.italian = italian
        self.spanish = spanish
        self.difficulty = difficulty
        self.topic = topic
        self.grammarNote = grammarNote
    }
}
