#import "Basic";
#import "String";
#import "Hash_Table";

SYM_FORALL :: "forall";
SYM_EXISTS :: "exists";
SYM_IN     :: "in";
SYM_NOT    :: "not ";
SYM_OR     :: " or ";
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
    return s == "0" || s == "1";
}

is_function :: (s: string, arity: int) -> bool {
    return (s == "succ" && arity == 1) || (s == "+" && arity == 2) || (s == "*" && arity == 2);
}

is_relation :: (s: string, arity: int) -> bool {
    return s == "<" && arity == 2;
}

// todo I think jai already has this function.
is_digit_ :: (c: u8) -> bool {
    return c >= #char "0" && c <= #char "9";
}
