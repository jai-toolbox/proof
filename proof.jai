Proof_Line :: struct {
    statement: *Formula;
    justification: string;
    dependencies: [..]int;
}

// note that these types are pointers to functions that have this signature.
// also note that functions are defined at compile time, so pointers pointing to constant data.
Line_Rule :: #type (inputs: []*Formula, claimed: *Formula) -> *Formula;
Proof_Modification_Rule :: #type (proof: *Proof, terms: []*Term);

Proof :: struct {
    assumptions: [..]*Formula;
    targets: [..]*Formula;
    suspended_targets: [..]*Formula;
    active_target_idx: int;
    lines: [..]Proof_Line;
    target_history: [..][..]*Formula;
    // we should use an enum to rule map instead.
    rules: Table(string, Line_Rule);

    // these modify the target
    target_rules: Table(string, Proof_Modification_Rule);
}

/*
 A
 --
 A 
*/
// note: this is probably redundant, but for some reason we need this, and that reason is probably wrong.
assumption_rule :: (inputs: []*Formula, claimed: *Formula) -> *Formula {
    return claimed;
}

/*
 A
 B
 -------
 A and B
*/
and_rule :: (inputs: []*Formula, claimed: *Formula) -> *Formula {
    if inputs.count != 2 {
        print("AND rule needs 2 inputs\n");
        return null;
    }
    
    expected := make_and(inputs[0], inputs[1]);
    
    if formula_to_string(expected) != formula_to_string(claimed) {
        print("Claimed does not match AND result\n");
        return null;
    }
    
    return claimed;
}

and_left_rule :: (inputs: []*Formula, claimed: *Formula) -> *Formula {
    if inputs.count != 1 {
        print("AND_LEFT needs 1 input\n");
        return null;
    }

    if inputs[0].kind != .AND {
        print("AND_LEFT input must be an AND\n");
        return null;
    }

    if formula_to_string(inputs[0].and_formula.l) != formula_to_string(claimed) {
        print("AND_LEFT claimed formula does not match left side\n");
        return null;
    }

    return claimed;
}

and_right_rule :: (inputs: []*Formula, claimed: *Formula) -> *Formula {
    if inputs.count != 1 {
        print("AND_RIGHT needs 1 input\n");
        return null;
    }

    if inputs[0].kind != .AND {
        print("AND_RIGHT input must be an AND\n");
        return null;
    }

    if formula_to_string(inputs[0].and_formula.r) != formula_to_string(claimed) {
        print("AND_RIGHT claimed formula does not match right side\n");
        return null;
    }

    return claimed;
}

/*
BLAH = BLAH
*/
eq_rule :: (inputs: []*Formula, claimed: *Formula) -> *Formula {
    if inputs.count != 0 {
        print("EQ_SIMPLIFY rule takes no inputs\n");
        return null;
    }
    
    if claimed.kind != .EQUALITY {
        print("Claimed formula is not an equality\n");
        return null;
    }
    
    if term_to_string(claimed.equality.l) != term_to_string(claimed.equality.r) {
        print("Left and right sides of equality are not equal\n");
        return null;
    }
    
    return claimed;
}

/*
 P
 not P
 ------
 contradiction
*/
contradiction_rule :: (inputs: []*Formula, claimed: *Formula) -> *Formula {
    if inputs.count != 2 {
        print("CONTRADICTION requires 2 inputs: P and not P\n");
        return null;
    }

    if claimed.kind != .RELATION || claimed.relation.R != "contradiction" || claimed.relation.args.count != 0 {
        print("CONTRADICTION: claimed formula must be contradiction()\n");
        return null;
    }

    if inputs[1].kind != .NOT {
        print("CONTRADICTION: second input must be not P\n");
        return null;
    }

    if formula_to_string(inputs[0]) != formula_to_string(inputs[1].not_formula.inner) {
        print("CONTRADICTION: inputs must be P and not P\n");
        return null;
    }

    return claimed;
}

/*
 A
 B
 ------
 not (A xor B)
*/
xor_both_rule :: (inputs: []*Formula, claimed: *Formula) -> *Formula {
    if inputs.count != 2 {
        print("XOR_BOTH requires 2 inputs: A and B\n");
        return null;
    }

    if claimed.kind != .NOT || claimed.not_formula.inner.kind != .XOR {
        print("XOR_BOTH: claimed formula must be not (A xor B)\n");
        return null;
    }

    xor_formula := claimed.not_formula.inner.xor_formula;
    if formula_to_string(xor_formula.l) != formula_to_string(inputs[0]) {
        print("XOR_BOTH: first input must match the left side of the XOR\n");
        return null;
    }

    if formula_to_string(xor_formula.r) != formula_to_string(inputs[1]) {
        print("XOR_BOTH: second input must match the right side of the XOR\n");
        return null;
    }

    return claimed;
}

// if your target is A => B, then you can make your goal B, and get the assumption A, 
// I don't think this function does that though, could be old and needs updating.
implication_intro_rule :: (inputs: []*Formula, current_target: *Formula) -> *Formula {
    if current_target.kind != .IMPLIES {
        print("implication_intro: target is not an implication A -> B\n");
        return null;
    }
    
    return current_target.implies.r;
}

/*
 A
 B
 -------
 A implies B
*/
implies_intro_line_rule :: (inputs: []*Formula, claimed: *Formula) -> *Formula {
    if inputs.count != 2 {
        print("IMPLIES_INTRO requires 2 inputs: assumed antecedent and derived consequent\n");
        return null;
    }

    if claimed.kind != .IMPLIES {
        print("IMPLIES_INTRO claimed formula must be an implication\n");
        return null;
    }

    if formula_to_string(claimed.implies.l) != formula_to_string(inputs[0]) {
        print("IMPLIES_INTRO first input must match implication antecedent\n");
        return null;
    }

    if formula_to_string(claimed.implies.r) != formula_to_string(inputs[1]) {
        print("IMPLIES_INTRO second input must match implication consequent\n");
        return null;
    }

    return claimed;
}

/*
 forall n in N, P(n)
 k in N 
 -------
 P(k)
*/
forall_rule :: (inputs: []*Formula, claimed: *Formula) -> *Formula {
    if inputs.count != 2 {
        print("FORALL rule requires 2 inputs: a forall and a term membership fact\n");
        return null;
    }
    
    if inputs[0].kind != .FORALL {
        print("First input must be a forall formula\n");
        return null;
    }
    forall_f := *inputs[0].forall;
    
    if inputs[1].kind != .RELATION || inputs[1].relation.args.count != 2 || inputs[1].relation.R != SYM_IN {
        print("Second input must be a membership relation (element ∈ domain)\n");
        return null;
    }
    
    elem := inputs[1].relation.args[0];
    fact_domain := inputs[1].relation.args[1];
    
    if term_to_string(forall_f.domain) != term_to_string(fact_domain) {
        print("Element's domain does not match forall domain\n");
        return null;
    }
    
    var_term := make_variable(forall_f.v);
    instantiated := substitute_in_formula(forall_f.inner, var_term, elem);
    
    if formula_to_string(instantiated) != formula_to_string(claimed) {
        print("Claimed formula % does not match derived formula %\n", 
              formula_to_string(claimed), formula_to_string(instantiated));
        return null;
    }
    
    return claimed;
}

/*
 (forall x1 in X1) ( (forall x2 in X2) ( ... (forall xn in Xn) ( P(x1, x2, ..., xn) ) )  )
 k1 in X1
 k2 in X2
 ...
 kn in Xn
 -------
 P(k1, k2, ..., kn)
*/
generalized_forall_rule :: (inputs: []*Formula, claimed: *Formula) -> *Formula {

    if inputs.count < 2 {
        print("generalized forall requires at least 2 elements, ");
        return null;
    }
    
    if inputs[0].kind != .FORALL {
        print("First input must be a forall formula\n");
        return null;
    }

    current_unwrapped_formula : *Formula = inputs[0];
    num_membership_relations := inputs.count - 1;

    for index : 1..num_membership_relations {

        if current_unwrapped_formula.kind != .FORALL {
            log("you passed in too many element membership formula to instantiate the forall");
            return null;
        }

        current_forall := current_unwrapped_formula.forall;

        formula := inputs[index];
        isnt_membership := formula.kind != .RELATION || formula.relation.args.count != 2 || formula.relation.R != SYM_IN;

        if isnt_membership {
            print("the formula % wasn't an element membership formula", formula.*);
            return null;
        }

        elem := formula.relation.args[0];
        domain := formula.relation.args[1];
        
        if term_to_string(current_forall.domain) != term_to_string(domain) {
            print("Element's domain does not match forall domain \n");
            return null;
        }

        // at this point we've verified that we can now do the substitution.
        
        var_term := make_variable(current_forall.v);
        current_unwrapped_formula = substitute_in_formula(current_forall.inner, var_term, elem);
    }

    if formula_to_string(current_unwrapped_formula) != formula_to_string(claimed) {
        print("Claimed formula % does not match derived formula %\n", 
              formula_to_string(claimed), formula_to_string(current_unwrapped_formula));
        return null;
    }

    return claimed;
}



/*
 A => B
 A
 ------
 B
*/
implies_rule :: (inputs: []*Formula, claimed: *Formula) -> *Formula {
    if inputs.count != 2 {
        print("IMPLIES rule requires 2 inputs: an implication and its antecedent\n");
        return null;
    }
    
    if inputs[0].kind != .IMPLIES {
        print("First input must be an implication formula\n");
        return null;
    }
    
    antecedent := inputs[0].implies.l;
    consequent := inputs[0].implies.r;
    
    if formula_to_string(antecedent) != formula_to_string(inputs[1]) {
        print("Second input does not match the antecedent of the implication\n");
        return null;
    }
    
    if formula_to_string(consequent) != formula_to_string(claimed) {
        print("Claimed formula does not match the implication's consequent\n");
        return null;
    }
    
    return claimed;
}

/*
 ------
 X or (not X)
*/
excluded_middle_rule :: (inputs: []*Formula, claimed: *Formula) -> *Formula {
    if inputs.count != 0 {
        print("LEM requires no inputs\n");
        return null;
    }
    
    if claimed.kind != .OR {
        print("LEM: claimed formula is not an OR\n");
        return null;
    }
    
    if claimed.or_formula.r.kind != .NOT {
        print("LEM: right-hand side is not a NOT\n");
        return null;
    }
    
    if formula_to_string(claimed.or_formula.l) != formula_to_string(claimed.or_formula.r.not_formula.inner) {
        print("LEM: must be of the form (P ∨ ¬P)\n");
        return null;
    }
    
    return claimed;
}


/*
 X -> Y
 (not X) -> Y
 ------
 Y
*/
// you've proven that no matter the value of X, that Y holds true
// this probably needs to be generalized to things which have a finite number of values.
cases_rule :: (inputs: []*Formula, claimed: *Formula) -> *Formula {
    if inputs.count != 2 {
        print("CASES requires 2 inputs: (f -> t) and (¬f -> t)\n");
        return null;
    }
    
    if inputs[0].kind != .IMPLIES {
        print("CASES: first input must be an implication\n");
        return null;
    }
    
    if inputs[1].kind != .IMPLIES {
        print("CASES: second input must be an implication\n");
        return null;
    }
    
    f := inputs[0].implies.l;
    t1 := inputs[0].implies.r;
    left2 := inputs[1].implies.l;
    t2 := inputs[1].implies.r;
    
    if formula_to_string(t1) != formula_to_string(claimed) || formula_to_string(t2) != formula_to_string(claimed) {
        print("CASES: both implications must derive the claimed formula\n");
        return null;
    }
    
    if left2.kind != .NOT {
        print("CASES: second implication must have ¬f on the left side\n");
        return null;
    }
    
    if formula_to_string(left2.not_formula.inner) != formula_to_string(f) {
        print("CASES: mismatched f and ¬f assumptions\n");
        return null;
    }
    
    return claimed;
}

/*
 A or B
 A -> C
 B -> C
 ------
 C
*/
or_elim_rule :: (inputs: []*Formula, claimed: *Formula) -> *Formula {
    if inputs.count != 3 {
        print("OR_ELIM requires 3 inputs: (A or B), (A -> C), and (B -> C)\n");
        return null;
    }

    if inputs[0].kind != .OR {
        print("OR_ELIM: first input must be an OR\n");
        return null;
    }

    if inputs[1].kind != .IMPLIES || inputs[2].kind != .IMPLIES {
        print("OR_ELIM: second and third inputs must be implications\n");
        return null;
    }

    A := inputs[0].or_formula.l;
    B := inputs[0].or_formula.r;
    A_imp := inputs[1].implies;
    B_imp := inputs[2].implies;

    if formula_to_string(A_imp.l) != formula_to_string(A) {
        print("OR_ELIM: second implication must start from the left disjunct\n");
        return null;
    }

    if formula_to_string(B_imp.l) != formula_to_string(B) {
        print("OR_ELIM: third implication must start from the right disjunct\n");
        return null;
    }

    if formula_to_string(A_imp.r) != formula_to_string(claimed) || formula_to_string(B_imp.r) != formula_to_string(claimed) {
        print("OR_ELIM: both branches must derive the claimed formula\n");
        return null;
    }

    return claimed;
}

/*
 A xor B
 B -> contradiction
 ------
 A
*/
xor_refute_right_rule :: (inputs: []*Formula, claimed: *Formula) -> *Formula {
    if inputs.count != 2 {
        print("XOR_REFUTE_RIGHT requires 2 inputs: (A xor B) and (B -> contradiction)\n");
        return null;
    }

    if inputs[0].kind != .XOR {
        print("XOR_REFUTE_RIGHT: first input must be an XOR\n");
        return null;
    }

    if inputs[1].kind != .IMPLIES {
        print("XOR_REFUTE_RIGHT: second input must be an implication\n");
        return null;
    }

    A := inputs[0].xor_formula.l;
    B := inputs[0].xor_formula.r;
    branch := inputs[1].implies;

    if formula_to_string(claimed) != formula_to_string(A) {
        print("XOR_REFUTE_RIGHT: claimed formula must be the left side of the XOR\n");
        return null;
    }

    if formula_to_string(branch.l) != formula_to_string(B) {
        print("XOR_REFUTE_RIGHT: implication must assume the right side of the XOR\n");
        return null;
    }

    if branch.r.kind != .RELATION || branch.r.relation.R != "contradiction" || branch.r.relation.args.count != 0 {
        print("XOR_REFUTE_RIGHT: implication must derive contradiction\n");
        return null;
    }

    return claimed;
}

/*
 A or B
 B -> contradiction
 ------
 A
*/
or_refute_right_rule :: (inputs: []*Formula, claimed: *Formula) -> *Formula {
    if inputs.count != 2 {
        print("OR_REFUTE_RIGHT requires 2 inputs: (A or B) and (B -> contradiction)\n");
        return null;
    }

    if inputs[0].kind != .OR {
        print("OR_REFUTE_RIGHT: first input must be an OR\n");
        return null;
    }

    if inputs[1].kind != .IMPLIES {
        print("OR_REFUTE_RIGHT: second input must be an implication\n");
        return null;
    }

    A := inputs[0].or_formula.l;
    B := inputs[0].or_formula.r;
    branch := inputs[1].implies;

    if formula_to_string(claimed) != formula_to_string(A) {
        print("OR_REFUTE_RIGHT: claimed formula must be the left side of the OR\n");
        return null;
    }

    if formula_to_string(branch.l) != formula_to_string(B) {
        print("OR_REFUTE_RIGHT: implication must assume the right side of the OR\n");
        return null;
    }

    if branch.r.kind != .RELATION || branch.r.relation.R != "contradiction" || branch.r.relation.args.count != 0 {
        print("OR_REFUTE_RIGHT: implication must derive contradiction\n");
        return null;
    }

    return claimed;
}

/*
 P(0) or P(1)
 forall k in N, P(k) => P(k+1)
 ------
 forall n in N, P(n)
*/
induction_rule :: (inputs: []*Formula, claimed: *Formula) -> *Formula {
    if inputs.count != 2 {
        print("INDUCTION requires 2 inputs: base P(0)/P(1) and step forall k(P(k) -> P(k+1))\n");
        return null;
    }
    
    base := inputs[0];
    
    if inputs[1].kind != .FORALL {
        print("Step must be a forall formula\n");
        return null;
    }
    forall_f := *inputs[1].forall;
    
    var := forall_f.v;
    if forall_f.inner.kind != .IMPLIES {
        print("Step must be an implication (P(k) → P(k+1))\n");
        return null;
    }
    implies_f := *forall_f.inner.implies;
    
    var_term := make_variable(var);
    succ_term := make_function("+", var_term, make_constant("1"));
    zero_term := make_constant("0");
    one_term := make_constant("1");
    
    Pk := implies_f.l;
    
    P0 := substitute_in_formula(Pk, var_term, zero_term);
    P1 := substitute_in_formula(Pk, var_term, one_term);
    if formula_to_string(P0) != formula_to_string(base) && formula_to_string(P1) != formula_to_string(base) {
        print("Base mismatch: expected % but got neither % nor %\n", formula_to_string(base), formula_to_string(P0), formula_to_string(P1));
        return null;
    }
    
    Psucc := substitute_in_formula(Pk, var_term, succ_term);
    if formula_to_string(implies_f.r) != formula_to_string(Psucc) {
        print("Step conclusion mismatch\n");
        return null;
    }
    
    n_term := make_variable("n");
    Pn := substitute_in_formula(Pk, var_term, n_term);
    
    result := make_forall("n", forall_f.domain, Pn);
    
    if formula_to_string(claimed) != formula_to_string(result) {
        print("Claimed % does not match derived %\n", formula_to_string(claimed), formula_to_string(result));
        return null;
    }
    
    return claimed;
}

/*
 P(start)
 forall i in N, ((start <= i) and (i < end)) -> (P(i) -> P(i+1))
 ------
 forall n in N, ((start <= n) and (n <= end)) -> P(n)
*/
finite_induction_rule :: (inputs: []*Formula, claimed: *Formula) -> *Formula {
    if inputs.count != 2 {
        print("FINITE_INDUCTION requires base P(start) and finite step forall i\n");
        return null;
    }

    if claimed.kind != .FORALL {
        print("FINITE_INDUCTION claimed statement must be a forall\n");
        return null;
    }

    n_name := claimed.forall.v;
    n_term := make_variable(n_name);

    if claimed.forall.inner.kind != .IMPLIES {
        print("FINITE_INDUCTION forall body must be range -> P(n)\n");
        return null;
    }

    target_impl := claimed.forall.inner;
    if target_impl.implies.l.kind != .AND {
        print("FINITE_INDUCTION range must be (start <= n) and (n <= end)\n");
        return null;
    }

    lower_bound := target_impl.implies.l.and_formula.l;
    upper_bound := target_impl.implies.l.and_formula.r;

    if lower_bound.kind != .RELATION || lower_bound.relation.R != SYM_LEQ || lower_bound.relation.args.count != 2 {
        print("FINITE_INDUCTION lower bound must be start <= n\n");
        return null;
    }

    if upper_bound.kind != .RELATION || upper_bound.relation.R != SYM_LEQ || upper_bound.relation.args.count != 2 {
        print("FINITE_INDUCTION upper bound must be n <= end\n");
        return null;
    }

    start := lower_bound.relation.args[0];
    lower_var := lower_bound.relation.args[1];
    upper_var := upper_bound.relation.args[0];
    end := upper_bound.relation.args[1];

    if term_to_string(lower_var) != term_to_string(n_term) || term_to_string(upper_var) != term_to_string(n_term) {
        print("FINITE_INDUCTION range must bind the claimed forall variable\n");
        return null;
    }

    Pn := target_impl.implies.r;
    expected_base := substitute_in_formula(Pn, n_term, start);
    if formula_to_string(inputs[0]) != formula_to_string(expected_base) {
        print("FINITE_INDUCTION base mismatch: expected % but got %\n", formula_to_string(expected_base), formula_to_string(inputs[0]));
        return null;
    }

    if inputs[1].kind != .FORALL {
        print("FINITE_INDUCTION step must be a forall\n");
        return null;
    }

    step_forall := inputs[1].forall;
    if term_to_string(step_forall.domain) != term_to_string(claimed.forall.domain) {
        print("FINITE_INDUCTION step domain must match claimed domain\n");
        return null;
    }

    i_term := make_variable(step_forall.v);
    i_plus_one := make_function("+", i_term, make_constant("1"));

    Pi := substitute_in_formula(Pn, n_term, i_term);
    Psucc := substitute_in_formula(Pn, n_term, i_plus_one);

    step_range := make_and(
        make_rel(SYM_LEQ, start, i_term),
        make_rel("<", i_term, end)
    );
    expected_step := make_implies(step_range, make_implies(Pi, Psucc));

    if formula_to_string(step_forall.inner) != formula_to_string(expected_step) {
        print("FINITE_INDUCTION step mismatch: expected % but got %\n", formula_to_string(expected_step), formula_to_string(step_forall.inner));
        return null;
    }

    return claimed;
}

/*
 P(a)
 P(b)
 P(c)
 ------
 forall x in {a, b, c}, P(x)
*/
finite_forall_rule :: (inputs: []*Formula, claimed: *Formula) -> *Formula {
    if claimed.kind != .FORALL {
        print("FINITE_FORALL claimed statement must be a forall\n");
        return null;
    }

    domain := claimed.forall.domain;
    if domain.kind != .FINITE_SET {
        print("FINITE_FORALL domain must be a finite set\n");
        return null;
    }

    if inputs.count != domain.finite_set.elements.count {
        print("FINITE_FORALL input count must match finite set size\n");
        return null;
    }

    var_term := make_variable(claimed.forall.v);
    for element, i: domain.finite_set.elements {
        expected := substitute_in_formula(claimed.forall.inner, var_term, element);
        if formula_to_string(inputs[i]) != formula_to_string(expected) {
            print("FINITE_FORALL input % mismatch: expected % but got %\n", i, formula_to_string(expected), formula_to_string(inputs[i]));
            return null;
        }
    }

    return claimed;
}

// ==================== Proof Functions ====================
register_rule :: (proof: *Proof, name: string, rule: Line_Rule) {
    table_add(*proof.rules, name, rule);
}

get_active_target :: (proof: *Proof) -> *Formula {
    if proof.active_target_idx >= proof.targets.count {
        print("Active goal index out of range\n");
        return null;
    }
    return proof.targets[proof.active_target_idx];
}

is_valid :: (proof: *Proof) -> bool {
    return proof.targets.count == 0;
}

print_proof :: (proof: *Proof) {
    print("===== Proof State =====\n");
    
    print("Assumptions:\n");
    for assumption, i: proof.assumptions {
        print("  [%] %\n", i, formula_to_string(assumption));
    }
    
    print("Proof Lines:\n");
    for line, i: proof.lines {
        print("  (%) %    [%", i, formula_to_string(line.statement), line.justification);
        if line.dependencies.count > 0 {
            print(" deps:");
            for d: line.dependencies {
                print(" %", d);
            }
        }
        print("]\n");
    }
    
    print("Targets (% remaining):\n", proof.targets.count);
    for target, i: proof.targets {
        print("  [%] %", i, formula_to_string(target));
        if i == proof.active_target_idx {
            print("   <-- active goal");
        }
        print("\n");
    }
    if proof.targets.count == 0 {
        print("  <all targets completed>\n");
    }
    if proof.suspended_targets.count > 0 {
        print("Suspended targets:\n");
        for target, i: proof.suspended_targets {
            print("  [%] %\n", i, formula_to_string(target));
        }
    }
    
    print("=======================\n");
}

create_proof :: (assumptions: []*Formula, target: *Formula) -> Proof {
    proof: Proof;
    
    array_add(*proof.targets, target);
    for a: assumptions {
        array_add(*proof.assumptions, a);
    }
    
    // Register the ASSUMPTION rule as a closure-like function
    // Note: In Jai, we need to handle this differently since we need access to proof
    register_rule(*proof, "ASSUMPTION", (inputs: []*Formula, claimed: *Formula) -> *Formula {
        // This is a simplified version - in practice you'd need context
        return claimed;
    });
    register_rule(*proof, "IMPLIES_ASSUMPTION", (inputs: []*Formula, claimed: *Formula) -> *Formula {
        return claimed;
    });
    register_rule(*proof, "FORALL_ASSUMPTION", (inputs: []*Formula, claimed: *Formula) -> *Formula {
        return claimed;
    });
    // TODO: we should replace these with enums so that we get proper errors, lazy for now
    register_rule(*proof, "IMPLIES", implies_rule);
    register_rule(*proof, "IMPLIES_INTRO", implies_intro_line_rule);
    register_rule(*proof, "FORALL", forall_rule);
    register_rule(*proof, "GENERALIZED_FORALL", generalized_forall_rule);
    register_rule(*proof, "EQ", eq_rule);
    register_rule(*proof, "AND", and_rule);
    register_rule(*proof, "AND_LEFT", and_left_rule);
    register_rule(*proof, "AND_RIGHT", and_right_rule);
    register_rule(*proof, "LEM", excluded_middle_rule);
    register_rule(*proof, "CONTRADICTION", contradiction_rule);
    register_rule(*proof, "XOR_BOTH", xor_both_rule);
    register_rule(*proof, "OR_ELIM", or_elim_rule);
    register_rule(*proof, "OR_REFUTE_RIGHT", or_refute_right_rule);
    register_rule(*proof, "XOR_REFUTE_RIGHT", xor_refute_right_rule);
    register_rule(*proof, "INDUCTION", induction_rule);
    register_rule(*proof, "FINITE_INDUCTION", finite_induction_rule);
    register_rule(*proof, "FINITE_FORALL", finite_forall_rule);
    
    return proof;
}

add_line_to_proof :: (proof: *Proof, claimed: *Formula, rule_name: string, deps: ..int) {
    rule := table_find_pointer(*proof.rules, rule_name);
    if !rule {
        print("Unknown rule: %\n", rule_name);
        return;
    }
    
    dep_statements: [..]*Formula;
    for idx: deps {
        if idx < 0 || idx >= proof.lines.count {
            print("Invalid dependency index\n");
            return;
        }
        array_add(*dep_statements, proof.lines[idx].statement);
    }
    
    // Special handling for ASSUMPTION rule
    if rule_name == "ASSUMPTION" {
        found := false;
        for a: proof.assumptions {
            if formula_to_string(a) == formula_to_string(claimed) {
                found = true;
                break;
            }
        }
        if !found {
            if rule_name != "IMPLIES_ASSUMPTION" && rule_name != "FORALL_ASSUMPTION" {
                print("Invalid assumption: %\n", formula_to_string(claimed));
                return;
            }
        }

        if !found {
            array_add(*proof.assumptions, claimed);
        }
    } else if rule_name == "IMPLIES_ASSUMPTION" || rule_name == "FORALL_ASSUMPTION" {
        found := false;
        for a: proof.assumptions {
            if formula_to_string(a) == formula_to_string(claimed) {
                found = true;
                break;
            }
        }
        if !found {
            array_add(*proof.assumptions, claimed);
        }
    } else {
        derived := (rule.*)(dep_statements, claimed);
        if !derived || formula_to_string(derived) != formula_to_string(claimed) {
            print("Claimed statement does not match derived\n");
            return;
        }
    }
    
    line: Proof_Line;
    line.statement = claimed;
    line.justification = rule_name;
    for d: deps {
        array_add(*line.dependencies, d);
    }
    array_add(*proof.lines, line);
    
    // Check if this line completes any targets
    for i: 0..proof.targets.count-1 {
        if formula_to_string(proof.targets[i]) == formula_to_string(claimed) {
            array_ordered_remove_by_index(*proof.targets, i);
            if proof.active_target_idx >= i && proof.active_target_idx > 0 {
                proof.active_target_idx -= 1;
            }
            if proof.targets.count == 0 && proof.suspended_targets.count > 0 {
                restored := proof.suspended_targets[proof.suspended_targets.count - 1];
                array_ordered_remove_by_index(*proof.suspended_targets, proof.suspended_targets.count - 1);
                array_add(*proof.targets, restored);
                proof.active_target_idx = 0;
            }
            break;
        }
    }
}

begin_subproof :: (proof: *Proof, subgoal: *Formula) {
    current_goal := get_active_target(proof);
    if !current_goal return;

    array_add(*proof.suspended_targets, current_goal);

    old_targets: [..]*Formula;
    for t: proof.targets {
        array_add(*old_targets, t);
    }
    array_add(*proof.target_history, old_targets);

    proof.targets[proof.active_target_idx] = subgoal;
}

// instantiations all modify the target.

instantiate_forall :: (proof: *Proof, requested_variable: *Term = null) {
    if proof.targets.count == 0 {
        print("No active goals to instantiate\n");
        return;
    }
    
    current_goal := proof.targets[proof.active_target_idx];
    if current_goal.kind != .FORALL {
        print("instantiate_forall: active goal is not a forall formula\n");
        return;
    }
    
    arbitrary_variable := ifx requested_variable then requested_variable else make_variable(current_goal.forall.v);
    
    membership_assumption := make_rel(SYM_IN, arbitrary_variable, current_goal.forall.domain);
    array_add(*proof.assumptions, membership_assumption);
    
    bound_var := make_variable(current_goal.forall.v);
    new_goal := substitute_in_formula(current_goal.forall.inner, bound_var, arbitrary_variable);
    
    old_targets: [..]*Formula;
    for t: proof.targets {
        array_add(*old_targets, t);
    }
    array_add(*proof.target_history, old_targets);
    
    proof.targets[proof.active_target_idx] = new_goal;
}

instantiate_implication :: (proof: *Proof) {
    if proof.targets.count == 0 {
        print("No active goals to instantiate\n");
        return;
    }
    
    current_goal := proof.targets[proof.active_target_idx];
    if current_goal.kind != .IMPLIES {
        print("instantiate_implication: active goal is not an implication formula\n");
        return;
    }
    
    array_add(*proof.assumptions, current_goal.implies.l);
    
    old_targets: [..]*Formula;
    for t: proof.targets {
        array_add(*old_targets, t);
    }
    array_add(*proof.target_history, old_targets);
    
    proof.targets[proof.active_target_idx] = current_goal.implies.r;
}

instantiate_induction :: (proof: *Proof) {
    current_goal := get_active_target(proof);
    if !current_goal || current_goal.kind != .FORALL {
        print("instantiate_induction: active goal is not a forall formula\n");
        return;
    }
    
    var := current_goal.forall.v;
    Pn := current_goal.forall.inner;
    
    // Base case: P(1)
    one_term := make_constant("1");
    var_term := make_variable(var);
    P1 := substitute_in_formula(Pn, var_term, one_term);
    
    // Step case: ∀k (P(k) → P(k+1))
    k_term := make_variable("k");
    succ_term := make_function("+", k_term, make_constant("1"));
    Pk := substitute_in_formula(Pn, var_term, k_term);
    Psucc := substitute_in_formula(Pn, var_term, succ_term);
    step_impl := make_implies(Pk, Psucc);
    
    step_forall := make_forall("k", current_goal.forall.domain, step_impl);
    
    old_targets: [..]*Formula;
    for t: proof.targets {
        array_add(*old_targets, t);
    }
    array_add(*proof.target_history, old_targets);
    
    proof.targets[proof.active_target_idx] = P1;
    array_add(*proof.targets, step_forall);
}

rewrite_target_using_equality :: (proof: *Proof, equality_proof_line: int) {
    if proof.targets.count == 0 {
        print("No active goals to rewrite\n");
        return;
    }
    
    if equality_proof_line < 0 || equality_proof_line >= proof.lines.count {
        print("Invalid equality line index\n");
        return;
    }
    
    equality_formula := proof.lines[equality_proof_line].statement;
    if equality_formula.kind != .EQUALITY {
        print("Selected line is not an equality\n");
        return;
    }
    
    lhs := equality_formula.equality.l;
    rhs := equality_formula.equality.r;
    
    current_goal := proof.targets[proof.active_target_idx];
    new_goal := substitute_term_in_formula(current_goal, lhs, rhs);
    
    old_targets: [..]*Formula;
    for t: proof.targets {
        array_add(*old_targets, t);
    }
    array_add(*proof.target_history, old_targets);
    
    proof.targets[proof.active_target_idx] = new_goal;
}

rewrite_target_using_equality_occurrence :: (proof: *Proof, equality_proof_line: int, occurrence: int) {
    if proof.targets.count == 0 {
        print("No active goals to rewrite\n");
        return;
    }
    
    if equality_proof_line < 0 || equality_proof_line >= proof.lines.count {
        print("Invalid equality line index\n");
        return;
    }
    
    equality_formula := proof.lines[equality_proof_line].statement;
    if equality_formula.kind != .EQUALITY {
        print("Selected line is not an equality\n");
        return;
    }
    
    lhs := equality_formula.equality.l;
    rhs := equality_formula.equality.r;
    
    current_goal := proof.targets[proof.active_target_idx];
    seen := 0;
    new_goal := substitute_term_occurrence_in_formula(current_goal, lhs, rhs, occurrence, *seen);
    
    if seen <= occurrence {
        print("Rewrite occurrence % was not found; only saw % occurrence(s)\n", occurrence, seen);
        return;
    }
    
    old_targets: [..]*Formula;
    for t: proof.targets {
        array_add(*old_targets, t);
    }
    array_add(*proof.target_history, old_targets);
    
    proof.targets[proof.active_target_idx] = new_goal;
}
