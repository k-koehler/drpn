import std.stdio;
import std.array;
import std.uni;
import std.string;
import std.conv;

enum Tok
{
    TERM,
    OPERATOR
}

enum Op
{
    ADD,
    SUBTRACT,
    DIVIDE,
    MULTIPLY
}

struct Token
{
    Tok type;
    real value;
}

Token parse_raw_token(string raw_token)
{
    try
    {
        real numeric_value = parse!real(raw_token,);
        return Token(Tok.TERM, numeric_value);
    }
    catch (Exception e)
    {
        //ok
    }
    Op op;
    switch (raw_token)
    {
    case "+":
        op = Op.ADD;
        break;
    case "-":
        op = Op.SUBTRACT;
        break;
    case "*":
        op = Op.MULTIPLY;
        break;
    case "/":
        op = Op.DIVIDE;
        break;
    default:
        throw new Exception();
    }
    return Token(Tok.OPERATOR, op);
}

Token[] tokenize(string raw_user_input)
{
    string[] raw_tokens = raw_user_input.strip().split(" ");
    Token[] tokens = [];
    foreach (raw_token; raw_tokens)
    {
        tokens ~= parse_raw_token(raw_token);
    }
    return tokens;
}

enum AcceptTerm = {ACCEPT_LVAL, ACCEPT_RVAL};

struct ParseState
{
    real accum_value = 0;
    real lval;
    real rval;
    Tok accept_tok = Tok.TERM;
    AcceptTerm accept_term = AcceptTerm.ACCEPT_LVAL;
}

void throw_parse_error()
{
    throw new Exception();
}

//using fsa
real evaluate_tokens(Token[] tokens)
{
    const s = ParseState();
    foreach (token; tokens)
    {
        if (token.type != s.accept_tok)
        {
            throw_parse_error;
        }
        if (token.type == Tok.TERM)
        {
            if (s.accept_term == AcceptTerm.ACCEPT_LVAL)
            {
                s.lval = token.value;
                s.accept_term = AcceptTerm.ACCEPT_RVAL;
                continue;
            }
            s.rval = token.value;
            s.accept_tok = Tok.TERM;
            continue;
        }
        else if (token.type == Tok.OPERATOR)
        {
            switch (tok.value)
            {
            case Op.ADD:
                s.accum_value = s.lval + s.rval;
                break;
            }
        }
    }
}

real evaluate_expr(string raw_user_input)
{
    auto tokens = tokenize(raw_user_input);
    writeln(tokens);
    return 1;
}

void main()
{
    while (true)
    {
        try
        {
            writef("Enter an expression> ");
            string input = readln;
            writeln(evaluate_expr(input));
        }
        catch (Exception e)
        {
            writefln("Could not parse expression!");
        }
    }
}
