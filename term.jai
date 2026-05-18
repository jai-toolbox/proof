Term_Kind :: enum {
    VARIABLE;
    CONSTANT;
    FUNCTION;
    TUPLE;
    FINITE_SET;
}

Variable_Term :: struct {
    var: string;
}

Constant_Term :: struct {
    c: string;
}

Function_Term :: struct {
    f: string;
    args: [..]*Term;
}

Tuple_Term :: struct {
    args: [..]*Term;
}

Finite_Set_Term :: struct {
    elements: [..]*Term;
}

Term :: struct {
    kind: Term_Kind;
    using data: union {
        variable: Variable_Term;
        constant: Constant_Term;
        function_term: Function_Term;
        tuple: Tuple_Term;
        finite_set: Finite_Set_Term;
    };
}

make_variable :: (v: string) -> *Term {
    t := New(Term);
    t.kind = .VARIABLE;
    t.variable.var = v;
    return t;
}

make_constant :: (c: string) -> *Term {
    t := New(Term);
    t.kind = .CONSTANT;
    t.constant.c = c;
    return t;
}

make_function :: (f: string, args: ..*Term) -> *Term {
    t := New(Term);
    t.kind = .FUNCTION;
    t.function_term.f = f;
    for arg: args {
        array_add(*t.function_term.args, arg);
    }
    return t;
}

make_function_from_array :: (f: string, args: []*Term) -> *Term {
    t := New(Term);
    t.kind = .FUNCTION;
    t.function_term.f = f;
    for arg: args {
        array_add(*t.function_term.args, arg);
    }
    return t;
}

make_tuple :: (args: ..*Term) -> *Term {
    t := New(Term);
    t.kind = .TUPLE;
    for arg: args {
        array_add(*t.tuple.args, arg);
    }
    return t;
}

make_tuple_from_array :: (args: []*Term) -> *Term {
    t := New(Term);
    t.kind = .TUPLE;
    for arg: args {
        array_add(*t.tuple.args, arg);
    }
    return t;
}

make_finite_set :: (elements: ..*Term) -> *Term {
    t := New(Term);
    t.kind = .FINITE_SET;
    for element: elements {
        array_add(*t.finite_set.elements, element);
    }
    return t;
}

make_finite_set_from_array :: (elements: []*Term) -> *Term {
    t := New(Term);
    t.kind = .FINITE_SET;
    for element: elements {
        array_add(*t.finite_set.elements, element);
    }
    return t;
}

term_to_string :: (t: *Term) -> string {
    if !t return "?";
    
    builder: String_Builder;
    
    if t.kind == {
        case .VARIABLE;
            return t.variable.var;
            
        case .CONSTANT;
            return t.constant.c;
            
        case .FUNCTION;
            is_infix := (t.function_term.f == "+" || t.function_term.f == "-" || t.function_term.f == "*" || t.function_term.f == "/" || t.function_term.f == SYM_IN);
            if is_infix && t.function_term.args.count == 2 {
                append(*builder, "(");
                append(*builder, term_to_string(t.function_term.args[0]));
                append(*builder, " ");
                append(*builder, t.function_term.f);
                append(*builder, " ");
                append(*builder, term_to_string(t.function_term.args[1]));
                append(*builder, ")");
            } else if t.function_term.f == "domain" && t.function_term.args.count == 1 {
                append(*builder, "domain(");
                append(*builder, term_to_string(t.function_term.args[0]));
                append(*builder, ")");
            } else if t.function_term.f == "image" && t.function_term.args.count == 1 {
                append(*builder, "image(");
                append(*builder, term_to_string(t.function_term.args[0]));
                append(*builder, ")");
            } else if t.function_term.f == "card" && t.function_term.args.count == 1 {
                append(*builder, "|");
                append(*builder, term_to_string(t.function_term.args[0]));
                append(*builder, "|");
            } else {
                append(*builder, t.function_term.f);
                append(*builder, "(");
                for arg, i: t.function_term.args {
                    append(*builder, term_to_string(arg));
                    if i + 1 < t.function_term.args.count {
                        append(*builder, ", ");
                    }
                }
                append(*builder, ")");
            }
            return builder_to_string(*builder);
            
        case .TUPLE;
            append(*builder, "(");
            for arg, i: t.tuple.args {
                append(*builder, term_to_string(arg));
                if i + 1 < t.tuple.args.count {
                    append(*builder, ", ");
                }
            }
            append(*builder, ")");
            return builder_to_string(*builder);

        case .FINITE_SET;
            append(*builder, "{");
            for element, i: t.finite_set.elements {
                append(*builder, term_to_string(element));
                if i + 1 < t.finite_set.elements.count {
                    append(*builder, ", ");
                }
            }
            append(*builder, "}");
            return builder_to_string(*builder);
    }
    
    return "?";
}

term_is_well_formed :: (t: *Term, err: *string = null) -> bool {
    if !t {
        if err then err.* = "null term";
        return false;
    }
    
    if t.kind == {
        case .VARIABLE;
            if !is_variable(t.variable.var) {
                if err then err.* = "bad var";
                return false;
            }
            return true;
            
        case .CONSTANT;
            if !is_constant_(t.constant.c) {
                if err then err.* = "bad const";
                return false;
            }
            return true;
            
        case .FUNCTION;
            if !is_function(t.function_term.f, t.function_term.args.count) {
                if err then err.* = "bad function/arity";
                return false;
            }
            for arg: t.function_term.args {
                if !term_is_well_formed(arg, err) return false;
            }
            return true;
            
        case .TUPLE;
            for arg: t.tuple.args {
                if !term_is_well_formed(arg, err) return false;
            }
            return true;

        case .FINITE_SET;
            for element: t.finite_set.elements {
                if !term_is_well_formed(element, err) return false;
            }
            return true;
    }
    
    return false;
}

occurs_in_term :: (v: string, t: *Term) -> bool {
    if !t return false;
    
    if t.kind == {
        case .VARIABLE;
            return t.variable.var == v;
        case .CONSTANT;
            return false;
        case .FUNCTION;
            for arg: t.function_term.args {
                if occurs_in_term(v, arg) return true;
            }
        case .TUPLE;
            for arg: t.tuple.args {
                if occurs_in_term(v, arg) return true;
            }
        case .FINITE_SET;
            for element: t.finite_set.elements {
                if occurs_in_term(v, element) return true;
            }
    }
    return false;
}

collect_vars_in_term :: (t: *Term, vars: *Table(string, bool)) {
    if !t return;
    
    if t.kind == {
        case .VARIABLE;
            table_add(vars, t.variable.var, true);
        case .FUNCTION;
            for arg: t.function_term.args {
                collect_vars_in_term(arg, vars);
            }
        case .TUPLE;
            for arg: t.tuple.args {
                collect_vars_in_term(arg, vars);
            }
        case .FINITE_SET;
            for element: t.finite_set.elements {
                collect_vars_in_term(element, vars);
            }
    }
}

substitute_term_in_term :: (u: *Term, pattern: *Term, replacement: *Term) -> *Term {
    if !u return null;
    
    if term_to_string(u) == term_to_string(pattern) {
        return replacement;
    }
    
    if u.kind == {
        case .FUNCTION;
            new_args: [..]*Term;
            for arg: u.function_term.args {
                array_add(*new_args, substitute_term_in_term(arg, pattern, replacement));
            }
            return make_function_from_array(u.function_term.f, new_args);
            
        case .TUPLE;
            new_args: [..]*Term;
            for arg: u.tuple.args {
                array_add(*new_args, substitute_term_in_term(arg, pattern, replacement));
            }
            return make_tuple_from_array(new_args);

        case .FINITE_SET;
            new_elements: [..]*Term;
            for element: u.finite_set.elements {
                array_add(*new_elements, substitute_term_in_term(element, pattern, replacement));
            }
            return make_finite_set_from_array(new_elements);
            
        case .VARIABLE;
            return make_variable(u.variable.var);
            
        case .CONSTANT;
            return make_constant(u.constant.c);
    }
    
    return null;
}

substitute_term_occurrence_in_term :: (u: *Term, pattern: *Term, replacement: *Term, target_occurrence: int, seen: *int) -> *Term {
    if !u return null;
    
    if term_to_string(u) == term_to_string(pattern) {
        if seen.* == target_occurrence {
            seen.* += 1;
            return copy_term(replacement);
        }
        seen.* += 1;
    }
    
    if u.kind == {
        case .FUNCTION;
            new_args: [..]*Term;
            for arg: u.function_term.args {
                array_add(*new_args, substitute_term_occurrence_in_term(arg, pattern, replacement, target_occurrence, seen));
            }
            return make_function_from_array(u.function_term.f, new_args);
            
        case .TUPLE;
            new_args: [..]*Term;
            for arg: u.tuple.args {
                array_add(*new_args, substitute_term_occurrence_in_term(arg, pattern, replacement, target_occurrence, seen));
            }
            return make_tuple_from_array(new_args);

        case .FINITE_SET;
            new_elements: [..]*Term;
            for element: u.finite_set.elements {
                array_add(*new_elements, substitute_term_occurrence_in_term(element, pattern, replacement, target_occurrence, seen));
            }
            return make_finite_set_from_array(new_elements);
            
        case .VARIABLE;
            return make_variable(u.variable.var);
            
        case .CONSTANT;
            return make_constant(u.constant.c);
    }
    
    return null;
}

// Substitute variable var with term t in term u
substitute_in_term :: (u: *Term, var: *Term, t: *Term) -> *Term {
    if !u return null;
    
    if u.kind == {
        case .VARIABLE;
            if var && u.variable.var == var.variable.var {
                return t;
            } else {
                return make_variable(u.variable.var);
            }
            
        case .CONSTANT;
            return make_constant(u.constant.c);
            
        case .FUNCTION;
            new_args: [..]*Term;
            for arg: u.function_term.args {
                array_add(*new_args, substitute_in_term(arg, var, t));
            }
            return make_function_from_array(u.function_term.f, new_args);
            
        case .TUPLE;
            new_args: [..]*Term;
            for arg: u.tuple.args {
                array_add(*new_args, substitute_in_term(arg, var, t));
            }
            return make_tuple_from_array(new_args);

        case .FINITE_SET;
            new_elements: [..]*Term;
            for element: u.finite_set.elements {
                array_add(*new_elements, substitute_in_term(element, var, t));
            }
            return make_finite_set_from_array(new_elements);
    }
    
    return null;
}

copy_term :: (t: *Term) -> *Term {
    if !t return null;
    
    if t.kind == {
        case .VARIABLE;
            return make_variable(t.variable.var);
        case .CONSTANT;
            return make_constant(t.constant.c);
        case .FUNCTION;
            new_args: [..]*Term;
            for arg: t.function_term.args {
                array_add(*new_args, copy_term(arg));
            }
            return make_function_from_array(t.function_term.f, new_args);
        case .TUPLE;
            new_args: [..]*Term;
            for arg: t.tuple.args {
                array_add(*new_args, copy_term(arg));
            }
            return make_tuple_from_array(new_args);
        case .FINITE_SET;
            new_elements: [..]*Term;
            for element: t.finite_set.elements {
                array_add(*new_elements, copy_term(element));
            }
            return make_finite_set_from_array(new_elements);
    }
    return null;
}

free_term :: (t: *Term) {
    if !t return;
    
    if t.kind == {
        case .FUNCTION;
            for arg: t.function_term.args {
                free_term(arg);
            }
            array_free(t.function_term.args);
        case .TUPLE;
            for arg: t.tuple.args {
                free_term(arg);
            }
            array_free(t.tuple.args);
        case .FINITE_SET;
            for element: t.finite_set.elements {
                free_term(element);
            }
            array_free(t.finite_set.elements);
    }
    free(t);
}
