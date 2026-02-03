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
    active_target_idx: int;
    lines: [..]Proof_Line;
    target_history: [..][..]*Formula;
    rules: Table(string, Line_Rule);
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
 P(0)
 forall k in N, P(k) => P(k+1)
 ------
 forall n in N, P(n)
*/
induction_rule :: (inputs: []*Formula, claimed: *Formula) -> *Formula {
    if inputs.count != 2 {
        print("INDUCTION requires 2 inputs: base P(0) and step ∀k(P(k) → P(k+1))\n");
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
    
    Pk := implies_f.l;
    
    P0 := substitute_in_formula(Pk, var_term, zero_term);
    if formula_to_string(P0) != formula_to_string(base) {
        print("Base mismatch: expected % but got %\n", formula_to_string(base), formula_to_string(P0));
        return null;
    }
    
    Psucc := substitute_in_formula(Pk, var_term, succ_term);
    if formula_to_string(implies_f.r) != formula_to_string(Psucc) {
        print("Step conclusion mismatch\n");
        return null;
    }
    
    n_term := make_variable("n");
    Pn := substitute_in_formula(Pk, var_term, n_term);
    
    natural_numbers := make_constant(SYM_NAT);
    result := make_forall("n", natural_numbers, Pn);
    
    if formula_to_string(claimed) != formula_to_string(result) {
        print("Claimed % does not match derived %\n", formula_to_string(claimed), formula_to_string(result));
        return null;
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
    register_rule(*proof, "IMPLIES", implies_rule);
    register_rule(*proof, "FORALL", forall_rule);
    register_rule(*proof, "EQ", eq_rule);
    register_rule(*proof, "AND", and_rule);
    
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
            print("Invalid assumption: %\n", formula_to_string(claimed));
            return;
        }
    } else {
        derived := (<<rule)(dep_statements, claimed);
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
            break;
        }
    }
}

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
    
    N := make_constant(SYM_NAT);
    membership_assumption := make_rel(SYM_IN, arbitrary_variable, N);
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
    
    // Base case: P(0)
    zero_term := make_constant("0");
    var_term := make_variable(var);
    P0 := substitute_in_formula(Pn, var_term, zero_term);
    
    // Step case: ∀k (P(k) → P(k+1))
    k_term := make_variable("k");
    succ_term := make_function("+", k_term, make_constant("1"));
    Pk := substitute_in_formula(Pn, var_term, k_term);
    Psucc := substitute_in_formula(Pn, var_term, succ_term);
    step_impl := make_implies(Pk, Psucc);
    
    natural_numbers := make_constant(SYM_NAT);
    step_forall := make_forall("k", natural_numbers, step_impl);
    
    old_targets: [..]*Formula;
    for t: proof.targets {
        array_add(*old_targets, t);
    }
    array_add(*proof.target_history, old_targets);
    
    proof.targets[proof.active_target_idx] = P0;
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
