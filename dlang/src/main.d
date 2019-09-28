module dlang.src.main;
import std.stdio;
import std.array;
import std.uni;
import std.string;
import std.conv;

class ParsingException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}

enum AcceptStateType {
    acceptFirstOperand,
    acceptOperand,
    acceptAny,
};

enum TokenType {
    operand,
    operator
}

enum OperatorType {
    add,
    subtract,
    divide,
    multiply
}

struct ParseState {
    real val = 0;
    real[] vals = [];
    AcceptStateType acceptState = AcceptStateType.acceptFirstOperand;
}

struct Token {
    TokenType type;
    real value;
    OperatorType operator;
    string yytext;
}

Token parseRawToken(string rawToken) {
    immutable auto yytext = rawToken;
    try {
        immutable real numericValue = parse!real(rawToken);
        return Token(TokenType.operand, numericValue, OperatorType.add, yytext);
    } catch (Exception e) {
        //ok
    }
    OperatorType op;
    switch (yytext) {
    case "+":
        op = OperatorType.add;
        break;
    case "-":
        op = OperatorType.subtract;
        break;
    case "*":
        op = OperatorType.multiply;
        break;
    case "/":
        op = OperatorType.divide;
        break;
    default:
        throw new ParsingException("unknown token \"" ~ yytext ~ "\"");
    }
    return Token(TokenType.operator, 0, op, yytext);
}

Token[] tokenize(immutable string rawUserInput) {
    string[] rawTokens = rawUserInput.strip().split(" ");
    Token[] tokens = [];
    foreach (rawToken; rawTokens) {
        tokens ~= parseRawToken(rawToken);
    }
    return tokens;
}

bool canAcceptToken(const ParseState* state, immutable Token* token) {
    final switch (state.acceptState) {
    case AcceptStateType.acceptFirstOperand:
        return token.type == TokenType.operand;
    case AcceptStateType.acceptOperand:
        return token.type == TokenType.operand;
    case AcceptStateType.acceptAny:
        return true;
    }
}

void displayError(const ParseState* state, immutable Token* token) {
    string expectedTokenType;
    switch (state.acceptState) {
    case AcceptStateType.acceptFirstOperand:
        expectedTokenType = "operand";
        break;
    case AcceptStateType.acceptOperand:
        expectedTokenType = "operand";
        break;
    default:
        expectedTokenType = "any";
        break;
    }
    immutable auto errorText = "error at \"%s\": expected %s".format(token.yytext,
            expectedTokenType);
    throw new ParsingException(errorText);
}

real evaluateTokens(immutable Token[] tokens) {
    auto s = ParseState();
    foreach (token; tokens) {
        if (!canAcceptToken(&s, &token)) {
            displayError(&s, &token);
        }
        if (token.type == TokenType.operand) {
            final switch (s.acceptState) {
            case AcceptStateType.acceptFirstOperand:
                s.val = token.value;
                s.acceptState = AcceptStateType.acceptOperand;
                break;
            case AcceptStateType.acceptOperand:
                s.vals ~= token.value;
                s.acceptState = AcceptStateType.acceptAny;
                break;
            case AcceptStateType.acceptAny:
                s.vals ~= token.value;
                break;
            }
            continue;
        }
        immutable auto rval = s.vals.back;
        s.vals.popBack();
        final switch (token.operator) {
        case OperatorType.add:
            s.val += rval;
            break;
        case OperatorType.subtract:
            s.val -= rval;
            break;
        case OperatorType.multiply:
            s.val *= rval;
            break;
        case OperatorType.divide:
            s.val /= rval;
            break;
        }
        s.acceptState = AcceptStateType.acceptAny;
    }
    if (s.vals.length > 0) {
        displayError(&s, &tokens.back);
    }
    return s.val;
}

real evaluateExpr(immutable string rawUserInput) {
    return evaluateTokens(cast(immutable Token[]) tokenize(rawUserInput));
}

void main() {
    while (true) {
        try {
            writef("Enter an expression> ");
            immutable string input = readln;
            writeln(evaluateExpr(input));
        } catch (ParsingException e) {
            writeln(e.msg);
        }
    }
}
