#import "Basic";
#import "String";
#import "Hash_Table";

SYM_FORALL :: "forall";
SYM_EXISTS :: "exists";
SYM_IN     :: "in";
SYM_NOT    :: "not ";
SYM_OR     :: " or ";
SYM_XOR    :: " xor ";
SYM_IFF    :: " iff ";
SYM_AND    :: " and ";
SYM_IMPL   :: " implies ";
SYM_NAT    :: "Nat";
SYM_LEQ    :: "<=";

// load just means dump this file in here.
#load "term.jai";
#load "formula.jai";
#load "proof.jai";

is_variable :: (s: string) -> bool {
    if s.count == 0 || s[0] != #char "v" return false;
    for i: 1..s.count-1 {
        if !is_digit_(s[i]) return false;
    }
    return s.count > 1;
}

is_constant_ :: (s: string) -> bool {
    if s.count == 0 return false;
    for c: s {
        if !is_digit_(c) return false;
    }
    return true;
}

is_function :: (s: string, arity: int) -> bool {
    return (s == "succ" && arity == 1) ||
           (s == "sum" && arity == 1) ||
           (s == "sum_of_1_to_n" && arity == 1) ||
           (s == "hits" && arity == 1) ||
           (s == "ES" && arity == 1) ||
           (s == "va" && arity == 2) ||
           (s == "domain" && arity == 1) ||
           (s == "image" && arity == 1) ||
           (s == "card" && arity == 1) ||
           (s == "+" && arity == 2) ||
           (s == "-" && arity == 2) ||
           (s == "*" && arity == 2) ||
           (s == "/" && arity == 2);
}

is_relation :: (s: string, arity: int) -> bool {
    return (s == "<" && arity == 2) ||
           (s == ">" && arity == 2) ||
           (s == "<=" && arity == 2) ||
           (s == ">=" && arity == 2) ||
           (s == "==" && arity == 2) ||
           (s == "!=" && arity == 2) ||
           (s == "truthy" && arity == 1) ||
           (s == "contradiction" && arity == 0) ||
           (s == "function_type" && arity == 3);
}

// todo I think jai already has this function.
is_digit_ :: (c: u8) -> bool {
    return c >= #char "0" && c <= #char "9";
}
