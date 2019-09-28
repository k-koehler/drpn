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

enum accept_state_t {
    ACCEPT_LVAL,
    ACCEPT_RVAL,
    ACCEPT_OP
};

enum tok_t {
    TERM,
    OPERATOR
}

enum op_t {
    ADD,
    SUBTRACT,
    DIVIDE,
    MULTIPLY
}

struct ParseState {
    real val = 0;
    real lval;
    real rval;
    accept_state_t accept_state = accept_state_t.ACCEPT_LVAL;
}

struct Token {
    tok_t type;
    real value;
    op_t operator;
}

Token parse_raw_token(string raw_token) {
    try {
        real numeric_value = parse!real(raw_token,);
        return Token(tok_t.TERM, numeric_value);
    } catch (Exception e) {
        //ok
    }
    op_t op;
    switch (raw_token) {
    case "+":
        op = op_t.ADD;
        break;
    case "-":
        op = op_t.SUBTRACT;
        break;
    case "*":
        op = op_t.MULTIPLY;
        break;
    case "/":
        op = op_t.DIVIDE;
        break;
    default:
        throw new ParsingException("unexpected token");
    }
    return Token(tok_t.OPERATOR, 0, op);
}

Token[] tokenize(string raw_user_input) {
    string[] raw_tokens = raw_user_input.strip().split(" ");
    Token[] tokens = [];
    foreach (raw_token; raw_tokens) {
        tokens ~= parse_raw_token(raw_token);
    }
    return tokens;
}

bool can_accept(accept_state_t cur_state, tok_t cur_type) {
    if (cur_type == tok_t.TERM) {
        return cur_state == accept_state_t.ACCEPT_LVAL || cur_state == accept_state_t.ACCEPT_RVAL;
    }
    return cur_state == accept_state_t.ACCEPT_OP;
}

real evaluate_tokens(Token[] tokens) {
    auto s = ParseState();
    foreach (token; tokens) {
        if (!can_accept(s.accept_state, token.type)) {
            throw new ParsingException("unexpected token type");
        }
        if (token.type == tok_t.TERM) {
            if (s.accept_state == accept_state_t.ACCEPT_LVAL) {
                s.lval = token.value;
                s.accept_state = accept_state_t.ACCEPT_RVAL;
                continue;
            }
            s.rval = token.value;
            s.accept_state = accept_state_t.ACCEPT_OP;
        } else if (token.type == tok_t.OPERATOR) {
            final switch (token.operator) {
            case op_t.ADD:
                s.val = s.lval + s.rval;
                break;
            case op_t.SUBTRACT:
                s.val = s.lval - s.rval;
                break;
            case op_t.MULTIPLY:
                s.val = s.lval * s.rval;
                break;
            case op_t.DIVIDE:
                s.val = s.lval / s.rval;
                break;
            }
            s.lval = s.val;
            s.accept_state = accept_state_t.ACCEPT_RVAL;
        }

    }
    return s.val;
}

real evaluate_expr(string raw_user_input) {
    return evaluate_tokens(tokenize(raw_user_input));
}

void main() {
    while (true) {
        try {
            writef("Enter an expression> ");
            string input = readln;
            writeln(evaluate_expr(input));
        } catch (ParsingException e) {
            writefln(e.msg);
        }
    }
}
