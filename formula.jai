Formula_Kind :: enum {
    EQUALITY;
    RELATION;
    NOT;
    OR;
    AND;
    IMPLIES;
    FORALL;
    EXISTS;
}

Equality_Formula :: struct {
    l: *Term;
    r: *Term;
}

Relation_Formula :: struct {
    R: string;
    args: [..]*Term;
}

Not_Formula :: struct {
    inner: *Formula;
}

Or_Formula :: struct {
    l: *Formula;
    r: *Formula;
}

And_Formula :: struct {
    l: *Formula;
    r: *Formula;
}

Implies_Formula :: struct {
    l: *Formula;
    r: *Formula;
}

Forall_Formula :: struct {
    v: string;
    domain: *Term;
    inner: *Formula;
}

Exists_Formula :: struct {
    v: string;
    domain: *Term;
    inner: *Formula;
}

Formula :: struct {
    kind: Formula_Kind;
    using data: union {
        equality: Equality_Formula;
        relation: Relation_Formula;
        not_formula: Not_Formula;
        or_formula: Or_Formula;
        and_formula: And_Formula;
        implies: Implies_Formula;
        forall: Forall_Formula;
        exists: Exists_Formula;
    };
}

make_eq :: (a: *Term, b: *Term) -> *Formula {
    f := New(Formula);
    f.kind = .EQUALITY;
    f.equality.l = a;
    f.equality.r = b;
    return f;
}

make_rel :: (R: string, args: ..*Term) -> *Formula {
    f := New(Formula);
    f.kind = .RELATION;
    f.relation.R = R;
    for arg: args {
        array_add(*f.relation.args, arg);
    }
    return f;
}

make_rel_from_array :: (R: string, args: []*Term) -> *Formula {
    f := New(Formula);
    f.kind = .RELATION;
    f.relation.R = R;
    for arg: args {
        array_add(*f.relation.args, arg);
    }
    return f;
}

make_not :: (inner: *Formula) -> *Formula {
    f := New(Formula);
    f.kind = .NOT;
    f.not_formula.inner = inner;
    return f;
}

make_or :: (a: *Formula, b: *Formula) -> *Formula {
    f := New(Formula);
    f.kind = .OR;
    f.or_formula.l = a;
    f.or_formula.r = b;
    return f;
}

make_and :: (a: *Formula, b: *Formula) -> *Formula {
    f := New(Formula);
    f.kind = .AND;
    f.and_formula.l = a;
    f.and_formula.r = b;
    return f;
}

make_implies :: (a: *Formula, b: *Formula) -> *Formula {
    f := New(Formula);
    f.kind = .IMPLIES;
    f.implies.l = a;
    f.implies.r = b;
    return f;
}

make_forall :: (v: string, domain: *Term, inner: *Formula) -> *Formula {
    f := New(Formula);
    f.kind = .FORALL;
    f.forall.v = v;
    f.forall.domain = domain;
    f.forall.inner = inner;
    return f;
}

make_exists :: (v: string, domain: *Term, inner: *Formula) -> *Formula {
    f := New(Formula);
    f.kind = .EXISTS;
    f.exists.v = v;
    f.exists.domain = domain;
    f.exists.inner = inner;
    return f;
}

formula_to_string :: (f: *Formula) -> string {
    if !f return "?";
    
    builder: String_Builder;
    
    if f.kind == {
        case .EQUALITY;
            append(*builder, "(");
            append(*builder, term_to_string(f.equality.l));
            append(*builder, " = ");
            append(*builder, term_to_string(f.equality.r));
            append(*builder, ")");
            return builder_to_string(*builder);
            
        case .RELATION;
            is_infix := (f.relation.R == "=" || f.relation.R == SYM_IN || 
                        f.relation.R == "<" || f.relation.R == SYM_LEQ || f.relation.R == ">");
            if is_infix && f.relation.args.count == 2 {
                append(*builder, "(");
                append(*builder, term_to_string(f.relation.args[0]));
                append(*builder, " ");
                append(*builder, f.relation.R);
                append(*builder, " ");
                append(*builder, term_to_string(f.relation.args[1]));
                append(*builder, ")");
            } else {
                append(*builder, f.relation.R);
                append(*builder, "(");
                for arg, i: f.relation.args {
                    if i > 0 then append(*builder, ", ");
                    append(*builder, term_to_string(arg));
                }
                append(*builder, ")");
            }
            return builder_to_string(*builder);
            
        case .NOT;
            append(*builder, "(");
            append(*builder, SYM_NOT);
            append(*builder, formula_to_string(f.not_formula.inner));
            append(*builder, ")");
            return builder_to_string(*builder);
            
        case .OR;
            append(*builder, "(");
            append(*builder, formula_to_string(f.or_formula.l));
            append(*builder, " ");
            append(*builder, SYM_OR);
            append(*builder, " ");
            append(*builder, formula_to_string(f.or_formula.r));
            append(*builder, ")");
            return builder_to_string(*builder);
            
        case .AND;
            append(*builder, "(");
            append(*builder, formula_to_string(f.and_formula.l));
            append(*builder, " ");
            append(*builder, SYM_AND);
            append(*builder, " ");
            append(*builder, formula_to_string(f.and_formula.r));
            append(*builder, ")");
            return builder_to_string(*builder);
            
        case .IMPLIES;
            append(*builder, "(");
            append(*builder, formula_to_string(f.implies.l));
            append(*builder, " ");
            append(*builder, SYM_IMPL);
            append(*builder, " ");
            append(*builder, formula_to_string(f.implies.r));
            append(*builder, ")");
            return builder_to_string(*builder);
            
        case .FORALL;
            append(*builder, "(");
            append(*builder, SYM_FORALL);
            append(*builder, " ");
            append(*builder, f.forall.v);
            append(*builder, " ");
            append(*builder, SYM_IN);
            append(*builder, " ");
            append(*builder, term_to_string(f.forall.domain));
            append(*builder, ")(");
            append(*builder, formula_to_string(f.forall.inner));
            append(*builder, ")");
            return builder_to_string(*builder);
            
        case .EXISTS;
            append(*builder, "(");
            append(*builder, SYM_EXISTS);
            append(*builder, " ");
            append(*builder, f.exists.v);
            append(*builder, " ");
            append(*builder, SYM_IN);
            append(*builder, " ");
            append(*builder, term_to_string(f.exists.domain));
            append(*builder, ")(");
            append(*builder, formula_to_string(f.exists.inner));
            append(*builder, ")");
            return builder_to_string(*builder);
    }
    
    return "?";
}

formula_is_well_formed :: (f: *Formula, err: *string = null) -> bool {
    if !f {
        if err then <<err = "null formula";
        return false;
    }
    
    if f.kind == {
        case .EQUALITY;
            return term_is_well_formed(f.equality.l, err) && term_is_well_formed(f.equality.r, err);
            
        case .RELATION;
            if !is_relation(f.relation.R, f.relation.args.count) {
                if err then <<err = "bad relation/arity";
                return false;
            }
            for arg: f.relation.args {
                if !term_is_well_formed(arg, err) return false;
            }
            return true;
            
        case .NOT;
            return formula_is_well_formed(f.not_formula.inner, err);
            
        case .OR;
            return formula_is_well_formed(f.or_formula.l, err) && formula_is_well_formed(f.or_formula.r, err);
            
        case .AND;
            return formula_is_well_formed(f.and_formula.l, err) && formula_is_well_formed(f.and_formula.r, err);
            
        case .IMPLIES;
            return formula_is_well_formed(f.implies.l, err) && formula_is_well_formed(f.implies.r, err);
            
        case .FORALL;
            if !is_variable(f.forall.v) {
                if err then <<err = "bad forall var";
                return false;
            }
            return formula_is_well_formed(f.forall.inner, err);
            
        case .EXISTS;
            if !is_variable(f.exists.v) {
                if err then <<err = "bad exists var";
                return false;
            }
            return formula_is_well_formed(f.exists.inner, err);
    }
    
    return false;
}

is_free_in :: (v: string, f: *Formula) -> bool {
    if !f return false;
    
    if f.kind == {
        case .EQUALITY;
            return occurs_in_term(v, f.equality.l) || occurs_in_term(v, f.equality.r);
            
        case .RELATION;
            for arg: f.relation.args {
                if occurs_in_term(v, arg) return true;
            }
            return false;
            
        case .NOT;
            return is_free_in(v, f.not_formula.inner);
            
        case .OR;
            return is_free_in(v, f.or_formula.l) || is_free_in(v, f.or_formula.r);
            
        case .AND;
            return is_free_in(v, f.and_formula.l) || is_free_in(v, f.and_formula.r);
            
        case .IMPLIES;
            return is_free_in(v, f.implies.l) || is_free_in(v, f.implies.r);
            
        case .FORALL;
            if f.forall.v == v return false;
            return is_free_in(v, f.forall.inner);
            
        case .EXISTS;
            if f.exists.v == v return false;
            return is_free_in(v, f.exists.inner);
    }
    return false;
}

collect_vars_in_formula :: (f: *Formula, vars: *Table(string, bool)) {
    if !f return;
    
    if f.kind == {
        case .EQUALITY;
            collect_vars_in_term(f.equality.l, vars);
            collect_vars_in_term(f.equality.r, vars);
            
        case .RELATION;
            for arg: f.relation.args {
                collect_vars_in_term(arg, vars);
            }
            
        case .NOT;
            collect_vars_in_formula(f.not_formula.inner, vars);
            
        case .OR;
            collect_vars_in_formula(f.or_formula.l, vars);
            collect_vars_in_formula(f.or_formula.r, vars);
            
        case .AND;
            collect_vars_in_formula(f.and_formula.l, vars);
            collect_vars_in_formula(f.and_formula.r, vars);
            
        case .IMPLIES;
            collect_vars_in_formula(f.implies.l, vars);
            collect_vars_in_formula(f.implies.r, vars);
            
        case .FORALL;
            collect_vars_in_formula(f.forall.inner, vars);
            
        case .EXISTS;
            collect_vars_in_formula(f.exists.inner, vars);
    }
}

is_sentence :: (f: *Formula) -> bool {
    vars: Table(string, bool);
    collect_vars_in_formula(f, *vars);
    
    for vars {
        if is_free_in(it_index, f) return false;
    }
    return true;
}

substitute_term_in_formula :: (phi: *Formula, pattern: *Term, replacement: *Term) -> *Formula {
    if !phi return null;
    
    if phi.kind == {
        case .EQUALITY;
            new_l := substitute_term_in_term(phi.equality.l, pattern, replacement);
            new_r := substitute_term_in_term(phi.equality.r, pattern, replacement);
            return make_eq(new_l, new_r);
            
        case .RELATION;
            new_args: [..]*Term;
            for arg: phi.relation.args {
                array_add(*new_args, substitute_term_in_term(arg, pattern, replacement));
            }
            return make_rel_from_array(phi.relation.R, new_args);
            
        case .NOT;
            return make_not(substitute_term_in_formula(phi.not_formula.inner, pattern, replacement));
            
        case .OR;
            new_l := substitute_term_in_formula(phi.or_formula.l, pattern, replacement);
            new_r := substitute_term_in_formula(phi.or_formula.r, pattern, replacement);
            return make_or(new_l, new_r);
            
        case .AND;
            new_l := substitute_term_in_formula(phi.and_formula.l, pattern, replacement);
            new_r := substitute_term_in_formula(phi.and_formula.r, pattern, replacement);
            return make_and(new_l, new_r);
            
        case .IMPLIES;
            new_l := substitute_term_in_formula(phi.implies.l, pattern, replacement);
            new_r := substitute_term_in_formula(phi.implies.r, pattern, replacement);
            return make_implies(new_l, new_r);
            
        case .FORALL;
            return make_forall(phi.forall.v, phi.forall.domain, 
                              substitute_term_in_formula(phi.forall.inner, pattern, replacement));
            
        case .EXISTS;
            return make_exists(phi.exists.v, phi.exists.domain,
                              substitute_term_in_formula(phi.exists.inner, pattern, replacement));
    }
    
    return null;
}

// Substitute variable 'var' with term 't' in formula 'phi'
substitute_in_formula :: (phi: *Formula, var: *Term, t: *Term) -> *Formula {
    if !phi return null;
    
    if phi.kind == {
        case .EQUALITY;
            new_l := substitute_in_term(phi.equality.l, var, t);
            new_r := substitute_in_term(phi.equality.r, var, t);
            return make_eq(new_l, new_r);
            
        case .RELATION;
            new_args: [..]*Term;
            for arg: phi.relation.args {
                array_add(*new_args, substitute_in_term(arg, var, t));
            }
            return make_rel_from_array(phi.relation.R, new_args);
            
        case .NOT;
            return make_not(substitute_in_formula(phi.not_formula.inner, var, t));
            
        case .OR;
            new_l := substitute_in_formula(phi.or_formula.l, var, t);
            new_r := substitute_in_formula(phi.or_formula.r, var, t);
            return make_or(new_l, new_r);
            
        case .AND;
            new_l := substitute_in_formula(phi.and_formula.l, var, t);
            new_r := substitute_in_formula(phi.and_formula.r, var, t);
            return make_and(new_l, new_r);
            
        case .IMPLIES;
            new_l := substitute_in_formula(phi.implies.l, var, t);
            new_r := substitute_in_formula(phi.implies.r, var, t);
            return make_implies(new_l, new_r);
            
        case .FORALL;
            if var && phi.forall.v == var.variable.var {
                return phi;
            }
            return make_forall(phi.forall.v, phi.forall.domain, 
                              substitute_in_formula(phi.forall.inner, var, t));
            
        case .EXISTS;
            if var && phi.exists.v == var.variable.var {
                return phi;
            }
            return make_exists(phi.exists.v, phi.exists.domain,
                              substitute_in_formula(phi.exists.inner, var, t));
    }
    
    return null;
}

// Check if term t is substitutable for variable var in formula phi
is_substitutable :: (phi: *Formula, var: *Term, t: *Term) -> bool {
    if !phi || !var || !t return false;
    
    if phi.kind == {
        case .EQUALITY;
            return true;
        case .RELATION;
            return true;
            
        case .NOT;
            return is_substitutable(phi.not_formula.inner, var, t);
            
        case .OR;
            return is_substitutable(phi.or_formula.l, var, t) && is_substitutable(phi.or_formula.r, var, t);
            
        case .AND;
            return is_substitutable(phi.and_formula.l, var, t) && is_substitutable(phi.and_formula.r, var, t);
            
        case .IMPLIES;
            return is_substitutable(phi.implies.l, var, t) && is_substitutable(phi.implies.r, var, t);
            
        case .FORALL;
            x_name := var.variable.var;
            y_name := phi.forall.v;
            
            if !is_free_in(x_name, phi) return true;
            if !occurs_in_term(y_name, t) return is_substitutable(phi.forall.inner, var, t);
            return false;
            
        case .EXISTS;
            x_name := var.variable.var;
            y_name := phi.exists.v;
            
            if !is_free_in(x_name, phi) return true;
            if !occurs_in_term(y_name, t) return is_substitutable(phi.exists.inner, var, t);
            return false;
    }
    
    return false;
}

copy_formula :: (f: *Formula) -> *Formula {
    if !f return null;
    
    if f.kind == {
        case .EQUALITY;
            return make_eq(copy_term(f.equality.l), copy_term(f.equality.r));
        case .RELATION;
            new_args: [..]*Term;
            for arg: f.relation.args {
                array_add(*new_args, copy_term(arg));
            }
            return make_rel_from_array(f.relation.R, new_args);
        case .NOT;
            return make_not(copy_formula(f.not_formula.inner));
        case .OR;
            return make_or(copy_formula(f.or_formula.l), copy_formula(f.or_formula.r));
        case .AND;
            return make_and(copy_formula(f.and_formula.l), copy_formula(f.and_formula.r));
        case .IMPLIES;
            return make_implies(copy_formula(f.implies.l), copy_formula(f.implies.r));
        case .FORALL;
            return make_forall(f.forall.v, copy_term(f.forall.domain), copy_formula(f.forall.inner));
        case .EXISTS;
            return make_exists(f.exists.v, copy_term(f.exists.domain), copy_formula(f.exists.inner));
    }
    return null;
}

free_formula :: (f: *Formula) {
    if !f return;
    
    if f.kind == {
        case .EQUALITY;
            free_term(f.equality.l);
            free_term(f.equality.r);
        case .RELATION;
            for arg: f.relation.args {
                free_term(arg);
            }
            array_free(f.relation.args);
        case .NOT;
            free_formula(f.not_formula.inner);
        case .OR;
            free_formula(f.or_formula.l);
            free_formula(f.or_formula.r);
        case .AND;
            free_formula(f.and_formula.l);
            free_formula(f.and_formula.r);
        case .IMPLIES;
            free_formula(f.implies.l);
            free_formula(f.implies.r);
        case .FORALL;
            free_term(f.forall.domain);
            free_formula(f.forall.inner);
        case .EXISTS;
            free_term(f.exists.domain);
            free_formula(f.exists.inner);
    }
    free(f);
}
