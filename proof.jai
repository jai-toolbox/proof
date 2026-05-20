Proof_Rule :: enum {
    ASSUMPTION;
    IMPLIES_ASSUMPTION;
    FORALL_ASSUMPTION;
    IMPLIES;
    IMPLIES_INTRO;
    IFF_INTRO;
    IFF_LEFT;
    IFF_RIGHT;
    FORALL;
    GENERALIZED_FORALL;
    AND;
    AND_LEFT;
    AND_RIGHT;
    LEM;
    CASES;
    CONTRADICTION;
    XOR_BOTH;
    OR_ELIM;
    OR_REFUTE_RIGHT;
    XOR_REFUTE_RIGHT;
    INDUCTION;
    FINITE_INDUCTION;
    FINITE_FORALL;
    REWRITE_LHS;
    REWRITE_RHS;
    REWRITE_LHS_ALL;
    REWRITE_RHS_ALL;
    REWRITE_LHS_AT;
    REWRITE_RHS_AT;
}

Proof_Rule_Info :: struct {
    rule: Proof_Rule;
    usage: string;
    description: string;
}

PROOF_RULE_COUNT :: 29;

proof_rule_name :: (rule: Proof_Rule) -> string {
    return to_lower_copy(tprint("%", rule));
}

parse_proof_rule :: (name: string) -> Proof_Rule, bool {
    for i: 0..PROOF_RULE_COUNT-1 {
        rule := cast(Proof_Rule) i;
        if name == proof_rule_name(rule) return rule, true;
        if name == tprint("%", rule) return rule, true;
    }

    return .AND, false;
}

proof_rule_info :: (rule: Proof_Rule) -> Proof_Rule_Info {
    info: Proof_Rule_Info;
    info.rule = rule;

    if rule == {
        case .ASSUMPTION;
            info.usage = "assume <assumption-index>";
            info.description = "Adds an existing global assumption as a proof line.";
        case .IMPLIES_ASSUMPTION;
            info.usage = "internal";
            info.description = "Records the antecedent temporarily assumed while proving an implication.";
        case .FORALL_ASSUMPTION;
            info.usage = "internal";
            info.description = "Records the arbitrary element assumption used while proving a forall.";
        case .AND;
            info.usage = "derive and <left-line> <right-line>";
            info.description = "From proof lines P and Q, derives (P and Q).";
        case .AND_LEFT;
            info.usage = "derive and_left <and-line>";
            info.description = "From (P and Q), derives P.";
        case .AND_RIGHT;
            info.usage = "derive and_right <and-line>";
            info.description = "From (P and Q), derives Q.";
        case .IMPLIES;
            info.usage = "derive implies <implication-line> <antecedent-line>";
            info.description = "From (P implies Q) and P, derives Q.";
        case .IMPLIES_INTRO;
            info.usage = "derive implies_intro <antecedent-line> <consequent-line>";
            info.description = "From an assumed antecedent line P and a derived line Q, records (P implies Q).";
        case .IFF_INTRO;
            info.usage = "derive iff_intro <p-implies-q-line> <q-implies-p-line>";
            info.description = "From P implies Q and Q implies P, derives (P iff Q).";
        case .IFF_LEFT;
            info.usage = "derive iff_left <iff-line>";
            info.description = "From P iff Q, derives P implies Q.";
        case .IFF_RIGHT;
            info.usage = "derive iff_right <iff-line>";
            info.description = "From P iff Q, derives Q implies P.";
        case .FORALL;
            info.usage = "derive forall <forall-line> <membership-line>";
            info.description = "Instantiates a forall with an element known to be in its domain.";
        case .GENERALIZED_FORALL;
            info.usage = "derive generalized_forall <forall-line> <membership-lines...>";
            info.description = "Instantiates nested forall formulas with several membership facts.";
        case .LEM;
            info.usage = "lem <assumption-index>";
            info.description = "Adds P or not P for a selected formula P.";
        case .CASES;
            info.usage = "derive cases <p-implies-c-line> <not-p-implies-c-line>";
            info.description = "From P implies C and not P implies C, derives C.";
        case .CONTRADICTION;
            info.usage = "derive contradiction <p-line> <not-p-line>";
            info.description = "From P and not P, derives contradiction().";
        case .XOR_BOTH;
            info.usage = "derive xor_both <a-line> <b-line>";
            info.description = "From A and B, derives not (A xor B).";
        case .OR_ELIM;
            info.usage = "derive or_elim <or-line> <left-branch-line> <right-branch-line>";
            info.description = "From A or B, A implies C, and B implies C, derives C.";
        case .OR_REFUTE_RIGHT;
            info.usage = "derive or_refute_right <or-line> <right-contradiction-line>";
            info.description = "From A or B and B implies contradiction(), derives A.";
        case .XOR_REFUTE_RIGHT;
            info.usage = "derive xor_refute_right <xor-line> <right-contradiction-line>";
            info.description = "From A xor B and B implies contradiction(), derives A.";
        case .INDUCTION;
            info.usage = "derive induction <base-line> <step-line>";
            info.description = "Uses a base case and an inductive step to prove the active forall goal.";
        case .FINITE_INDUCTION;
            info.usage = "derive finite_induction <base-line> <step-line>";
            info.description = "Uses finite-range induction to prove the active bounded forall goal.";
        case .FINITE_FORALL;
            info.usage = "derive finite_forall <case-lines...>";
            info.description = "Proves a forall over a finite set by proving every element case.";
        case .REWRITE_LHS;
            info.usage = "derive rewrite_lhs <formula-line> <equality-line-or-proof-file>";
            info.description = "Given a = b, replaces the first occurrence of a in the formula line with b.";
        case .REWRITE_RHS;
            info.usage = "derive rewrite_rhs <formula-line> <equality-line-or-proof-file>";
            info.description = "Given a = b, replaces the first occurrence of b in the formula line with a.";
        case .REWRITE_LHS_ALL;
            info.usage = "derive rewrite_lhs_all <formula-line> <equality-line-or-proof-file>";
            info.description = "Given a = b, replaces every occurrence of a in the formula line with b.";
        case .REWRITE_RHS_ALL;
            info.usage = "derive rewrite_rhs_all <formula-line> <equality-line-or-proof-file>";
            info.description = "Given a = b, replaces every occurrence of b in the formula line with a.";
        case .REWRITE_LHS_AT;
            info.usage = "derive rewrite_lhs_at <formula-line> <equality-line-or-proof-file> <occurrence>";
            info.description = "Given a = b, replaces one indexed occurrence of a with b. Occurrences are leftmost-first from 0.";
        case .REWRITE_RHS_AT;
            info.usage = "derive rewrite_rhs_at <formula-line> <equality-line-or-proof-file> <occurrence>";
            info.description = "Given a = b, replaces one indexed occurrence of b with a. Occurrences are leftmost-first from 0.";
    }

    return info;
}

proof_command_string :: (rule_name: string, deps: []int) -> string {
    builder: String_Builder;
    defer free_buffers(*builder);

    print_to_builder(*builder, "derive %", rule_name);
    for d: deps {
        print_to_builder(*builder, " %", d);
    }

    return builder_to_string(*builder);
}

goal_command_string :: (rule_name: string, equality_line: int = -1, mode: Rewrite_Mode = .OCCURRENCE, occurrence: int = 0) -> string {
    if equality_line < 0 return tprint("goal %", rule_name);

    if mode == .OCCURRENCE && occurrence != 0 {
        return tprint("goal % % %", rule_name, equality_line, occurrence);
    }

    return tprint("goal % %", rule_name, equality_line);
}

Proof_Line :: struct {
    statement: *Formula;
    justification: string;
    dependencies: [..]int;
}

Proof_Goal_Rule :: enum {
    EQ;
    REWRITE_LHS;
    REWRITE_RHS;
    REWRITE_LHS_ALL;
    REWRITE_RHS_ALL;
    REWRITE_LHS_AT;
    REWRITE_RHS_AT;
}

Proof_Goal_Rule_Info :: struct {
    rule: Proof_Goal_Rule;
    usage: string;
    description: string;
}

PROOF_GOAL_RULE_COUNT :: 7;

proof_goal_rule_name :: (rule: Proof_Goal_Rule) -> string {
    return to_lower_copy(tprint("%", rule));
}

parse_proof_goal_rule :: (name: string) -> Proof_Goal_Rule, bool {
    for i: 0..PROOF_GOAL_RULE_COUNT-1 {
        rule := cast(Proof_Goal_Rule) i;
        if name == proof_goal_rule_name(rule) return rule, true;
        if name == tprint("%", rule) return rule, true;
    }

    return .REWRITE_LHS, false;
}

proof_goal_rule_info :: (rule: Proof_Goal_Rule) -> Proof_Goal_Rule_Info {
    info: Proof_Goal_Rule_Info;
    info.rule = rule;

    if rule == {
        case .EQ;
            info.usage = "goal eq";
            info.description = "Completes the active goal when it is syntactically t = t.";
        case .REWRITE_LHS;
            info.usage = "goal rewrite_lhs <equality-line-or-proof-file>";
            info.description = "Given a = b, rewrites the first occurrence of a in the active goal to b.";
        case .REWRITE_RHS;
            info.usage = "goal rewrite_rhs <equality-line-or-proof-file>";
            info.description = "Given a = b, rewrites the first occurrence of b in the active goal to a.";
        case .REWRITE_LHS_ALL;
            info.usage = "goal rewrite_lhs_all <equality-line-or-proof-file>";
            info.description = "Given a = b, rewrites every occurrence of a in the active goal to b.";
        case .REWRITE_RHS_ALL;
            info.usage = "goal rewrite_rhs_all <equality-line-or-proof-file>";
            info.description = "Given a = b, rewrites every occurrence of b in the active goal to a.";
        case .REWRITE_LHS_AT;
            info.usage = "goal rewrite_lhs_at <equality-line-or-proof-file> <occurrence>";
            info.description = "Given a = b, rewrites one indexed occurrence of a in the active goal to b. Occurrences start at 0.";
        case .REWRITE_RHS_AT;
            info.usage = "goal rewrite_rhs_at <equality-line-or-proof-file> <occurrence>";
            info.description = "Given a = b, rewrites one indexed occurrence of b in the active goal to a. Occurrences start at 0.";
    }

    return info;
}

// note that these types are pointers to functions that have this signature.
// also note that functions are defined at compile time, so pointers pointing to constant data.
Line_Rule :: #type (inputs: []*Formula, claimed: *Formula) -> *Formula;
Proof_Modification_Rule :: #type (proof: *Proof, terms: []*Term);

Rewrite_Direction :: enum {
    LHS_TO_RHS;
    RHS_TO_LHS;
}

Rewrite_Mode :: enum {
    OCCURRENCE;
    ALL;
}

Proof :: struct {
    assumptions: [..]*Formula;
    goals: [..]*Formula;
    suspended_goals: [..]*Formula;
    active_goal_idx: int;
    lines: [..]Proof_Line;
    goal_history: [..][..]*Formula;
    // we should use an enum to rule map instead.
    rules: Table(string, Line_Rule);

    // these modify the goal
    goal_rules: Table(string, Proof_Modification_Rule);
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

// if your goal is A => B, then you can make your goal B, and get the assumption A, 
// I don't think this function does that though, could be old and needs updating.
implication_intro_rule :: (inputs: []*Formula, current_goal: *Formula) -> *Formula {
    if current_goal.kind != .IMPLIES {
        print("implication_intro: goal is not an implication A -> B\n");
        return null;
    }
    
    return current_goal.implies.r;
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

iff_intro_rule :: (inputs: []*Formula, claimed: *Formula) -> *Formula {
    if inputs.count != 2 {
        print("IFF_INTRO requires 2 inputs: P implies Q and Q implies P\n");
        return null;
    }

    if inputs[0].kind != .IMPLIES || inputs[1].kind != .IMPLIES {
        print("IFF_INTRO inputs must be implications\n");
        return null;
    }

    if claimed.kind != .IFF {
        print("IFF_INTRO claimed formula must be an iff\n");
        return null;
    }

    if formula_to_string(inputs[0].implies.l) != formula_to_string(claimed.iff_formula.l) ||
       formula_to_string(inputs[0].implies.r) != formula_to_string(claimed.iff_formula.r) {
        print("IFF_INTRO first implication must be left-to-right\n");
        return null;
    }

    if formula_to_string(inputs[1].implies.l) != formula_to_string(claimed.iff_formula.r) ||
       formula_to_string(inputs[1].implies.r) != formula_to_string(claimed.iff_formula.l) {
        print("IFF_INTRO second implication must be right-to-left\n");
        return null;
    }

    return claimed;
}

iff_left_rule :: (inputs: []*Formula, claimed: *Formula) -> *Formula {
    if inputs.count != 1 {
        print("IFF_LEFT requires 1 input\n");
        return null;
    }

    if inputs[0].kind != .IFF {
        print("IFF_LEFT input must be an iff\n");
        return null;
    }

    expected := make_implies(inputs[0].iff_formula.l, inputs[0].iff_formula.r);
    if formula_to_string(expected) != formula_to_string(claimed) {
        print("IFF_LEFT claimed formula does not match left-to-right implication\n");
        return null;
    }

    return claimed;
}

iff_right_rule :: (inputs: []*Formula, claimed: *Formula) -> *Formula {
    if inputs.count != 1 {
        print("IFF_RIGHT requires 1 input\n");
        return null;
    }

    if inputs[0].kind != .IFF {
        print("IFF_RIGHT input must be an iff\n");
        return null;
    }

    expected := make_implies(inputs[0].iff_formula.r, inputs[0].iff_formula.l);
    if formula_to_string(expected) != formula_to_string(claimed) {
        print("IFF_RIGHT claimed formula does not match right-to-left implication\n");
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

    goal_impl := claimed.forall.inner;
    if goal_impl.implies.l.kind != .AND {
        print("FINITE_INDUCTION range must be (start <= n) and (n <= end)\n");
        return null;
    }

    lower_bound := goal_impl.implies.l.and_formula.l;
    upper_bound := goal_impl.implies.l.and_formula.r;

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

    Pn := goal_impl.implies.r;
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

get_active_goal :: (proof: *Proof) -> *Formula {
    if proof.goals.count == 0 return null;

    if proof.active_goal_idx >= proof.goals.count {
        print("Active goal index out of range\n");
        return null;
    }
    return proof.goals[proof.active_goal_idx];
}

is_valid :: (proof: *Proof) -> bool {
    return proof.goals.count == 0;
}

complete_reflexive_goal :: (proof: *Proof) -> bool {
    current_goal := get_active_goal(proof);
    if !current_goal return false;

    if current_goal.kind != .EQUALITY {
        print("Active goal is not an equality\n");
        return false;
    }

    if term_to_string(current_goal.equality.l) != term_to_string(current_goal.equality.r) {
        print("Active goal is not reflexive\n");
        return false;
    }

    array_ordered_remove_by_index(*proof.goals, proof.active_goal_idx);
    if proof.active_goal_idx >= proof.goals.count && proof.active_goal_idx > 0 {
        proof.active_goal_idx -= 1;
    }

    if proof.goals.count == 0 && proof.suspended_goals.count > 0 {
        restored := proof.suspended_goals[proof.suspended_goals.count - 1];
        array_ordered_remove_by_index(*proof.suspended_goals, proof.suspended_goals.count - 1);
        array_add(*proof.goals, restored);
        proof.active_goal_idx = 0;
    }

    return true;
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
        print("]\n");
    }
    
    print("Goals (% remaining):\n", proof.goals.count);
    for goal, i: proof.goals {
        print("  [%] %", i, formula_to_string(goal));
        if i == proof.active_goal_idx {
            print("   <-- active goal");
        }
        print("\n");
    }
    if proof.goals.count == 0 {
        print("  <all goals completed>\n");
    }
    if proof.suspended_goals.count > 0 {
        print("Suspended goals:\n");
        for goal, i: proof.suspended_goals {
            print("  [%] %\n", i, formula_to_string(goal));
        }
    }
    
    print("=======================\n");
}

create_proof :: (assumptions: []*Formula, goal: *Formula) -> Proof {
    proof: Proof;
    
    array_add(*proof.goals, goal);
    for a: assumptions {
        array_add(*proof.assumptions, a);
    }
    
    // Register the ASSUMPTION rule as a closure-like function
    // Note: In Jai, we need to handle this differently since we need access to proof
    register_rule(*proof, "ASSUMPTION", (inputs: []*Formula, claimed: *Formula) -> *Formula {
        // This is a simplified version - in practice you'd need context
        return claimed;
    });
    register_rule(*proof, "assumption", (inputs: []*Formula, claimed: *Formula) -> *Formula {
        return claimed;
    });
    register_rule(*proof, "IMPLIES_ASSUMPTION", (inputs: []*Formula, claimed: *Formula) -> *Formula {
        return claimed;
    });
    register_rule(*proof, "implies_assumption", (inputs: []*Formula, claimed: *Formula) -> *Formula {
        return claimed;
    });
    register_rule(*proof, "FORALL_ASSUMPTION", (inputs: []*Formula, claimed: *Formula) -> *Formula {
        return claimed;
    });
    register_rule(*proof, "forall_assumption", (inputs: []*Formula, claimed: *Formula) -> *Formula {
        return claimed;
    });
    // TODO: we should replace these with enums so that we get proper errors, lazy for now
    register_rule(*proof, "IMPLIES", implies_rule);
    register_rule(*proof, "implies", implies_rule);
    register_rule(*proof, "IMPLIES_INTRO", implies_intro_line_rule);
    register_rule(*proof, "implies_intro", implies_intro_line_rule);
    register_rule(*proof, "IFF_INTRO", iff_intro_rule);
    register_rule(*proof, "iff_intro", iff_intro_rule);
    register_rule(*proof, "IFF_LEFT", iff_left_rule);
    register_rule(*proof, "iff_left", iff_left_rule);
    register_rule(*proof, "IFF_RIGHT", iff_right_rule);
    register_rule(*proof, "iff_right", iff_right_rule);
    register_rule(*proof, "FORALL", forall_rule);
    register_rule(*proof, "forall", forall_rule);
    register_rule(*proof, "GENERALIZED_FORALL", generalized_forall_rule);
    register_rule(*proof, "generalized_forall", generalized_forall_rule);
    register_rule(*proof, "AND", and_rule);
    register_rule(*proof, "and", and_rule);
    register_rule(*proof, "AND_LEFT", and_left_rule);
    register_rule(*proof, "and_left", and_left_rule);
    register_rule(*proof, "AND_RIGHT", and_right_rule);
    register_rule(*proof, "and_right", and_right_rule);
    register_rule(*proof, "LEM", excluded_middle_rule);
    register_rule(*proof, "lem", excluded_middle_rule);
    register_rule(*proof, "CONTRADICTION", contradiction_rule);
    register_rule(*proof, "contradiction", contradiction_rule);
    register_rule(*proof, "XOR_BOTH", xor_both_rule);
    register_rule(*proof, "xor_both", xor_both_rule);
    register_rule(*proof, "OR_ELIM", or_elim_rule);
    register_rule(*proof, "or_elim", or_elim_rule);
    register_rule(*proof, "OR_REFUTE_RIGHT", or_refute_right_rule);
    register_rule(*proof, "or_refute_right", or_refute_right_rule);
    register_rule(*proof, "XOR_REFUTE_RIGHT", xor_refute_right_rule);
    register_rule(*proof, "xor_refute_right", xor_refute_right_rule);
    register_rule(*proof, "INDUCTION", induction_rule);
    register_rule(*proof, "induction", induction_rule);
    register_rule(*proof, "FINITE_INDUCTION", finite_induction_rule);
    register_rule(*proof, "finite_induction", finite_induction_rule);
    register_rule(*proof, "FINITE_FORALL", finite_forall_rule);
    register_rule(*proof, "finite_forall", finite_forall_rule);
    
    return proof;
}

complete_goals_for_line :: (proof: *Proof, claimed: *Formula) {
    for i: 0..proof.goals.count-1 {
        if formula_to_string(proof.goals[i]) == formula_to_string(claimed) {
            array_ordered_remove_by_index(*proof.goals, i);
            if proof.active_goal_idx >= i && proof.active_goal_idx > 0 {
                proof.active_goal_idx -= 1;
            }
            if proof.goals.count == 0 && proof.suspended_goals.count > 0 {
                restored := proof.suspended_goals[proof.suspended_goals.count - 1];
                array_ordered_remove_by_index(*proof.suspended_goals, proof.suspended_goals.count - 1);
                array_add(*proof.goals, restored);
                proof.active_goal_idx = 0;
            }
            break;
        }
    }
}

add_line_to_proof :: (proof: *Proof, claimed: *Formula, rule_name: string, deps: ..int) {
    rule := table_find_pointer(*proof.rules, rule_name);
    if !rule {
        print("Unknown rule: %\n", rule_name);
        return;
    }

    rule_kind, has_rule_kind := parse_proof_rule(rule_name);
    
    dep_statements: [..]*Formula;
    for idx: deps {
        if idx < 0 || idx >= proof.lines.count {
            print("Invalid dependency index\n");
            return;
        }
        array_add(*dep_statements, proof.lines[idx].statement);
    }
    
    // Special handling for ASSUMPTION rule
    if has_rule_kind && rule_kind == .ASSUMPTION {
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

        if !found {
            array_add(*proof.assumptions, claimed);
        }
    } else if has_rule_kind && (rule_kind == .IMPLIES_ASSUMPTION || rule_kind == .FORALL_ASSUMPTION) {
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
    display_rule_name := ifx has_rule_kind then proof_rule_name(rule_kind) else rule_name;
    if deps.count > 0 {
        deps_array: [..]int;
        for d: deps array_add(*deps_array, d);
        line.justification = proof_command_string(display_rule_name, deps_array);
    } else {
        line.justification = display_rule_name;
    }
    for d: deps {
        array_add(*line.dependencies, d);
    }
    array_add(*proof.lines, line);
    
    complete_goals_for_line(proof, claimed);
}

rewrite_formula_with_equality :: (source: *Formula, equality_formula: *Formula, direction: Rewrite_Direction, mode: Rewrite_Mode, occurrence: int, found: *bool) -> *Formula {
    if !source || !equality_formula || equality_formula.kind != .EQUALITY {
        if found then found.* = false;
        return null;
    }

    pattern := equality_formula.equality.l;
    replacement := equality_formula.equality.r;
    if direction == .RHS_TO_LHS {
        pattern = equality_formula.equality.r;
        replacement = equality_formula.equality.l;
    }

    result: *Formula;
    if mode == .ALL {
        result = substitute_term_in_formula(source, pattern, replacement);
        if found then found.* = formula_to_string(result) != formula_to_string(source);
    } else {
        seen := 0;
        result = substitute_term_occurrence_in_formula(source, pattern, replacement, occurrence, *seen);
        if found then found.* = seen > occurrence;
    }

    return result;
}

add_rewrite_line_to_proof :: (proof: *Proof, source_line: int, equality_line: int, direction: Rewrite_Direction, mode: Rewrite_Mode = .OCCURRENCE, occurrence: int = 0) -> int {
    if source_line < 0 || source_line >= proof.lines.count {
        print("Invalid source line index\n");
        return -1;
    }

    if equality_line < 0 || equality_line >= proof.lines.count {
        print("Invalid equality line index\n");
        return -1;
    }

    equality_formula := proof.lines[equality_line].statement;
    if equality_formula.kind != .EQUALITY {
        print("Selected equality line is not an equality\n");
        return -1;
    }

    return add_rewrite_line_to_proof_with_equality_formula(
        proof,
        source_line,
        equality_formula,
        direction,
        mode,
        occurrence,
        "",
        equality_line
    );
}

add_rewrite_line_to_proof_with_equality_formula :: (proof: *Proof, source_line: int, equality_formula: *Formula, direction: Rewrite_Direction, mode: Rewrite_Mode = .OCCURRENCE, occurrence: int = 0, justification: string = "", equality_dependency: int = -1) -> int {
    if source_line < 0 || source_line >= proof.lines.count {
        print("Invalid source line index\n");
        return -1;
    }

    if !equality_formula || equality_formula.kind != .EQUALITY {
        print("Selected equality is not an equality\n");
        return -1;
    }

    if occurrence < 0 {
        print("Rewrite occurrence must be non-negative\n");
        return -1;
    }

    found := false;
    claimed := rewrite_formula_with_equality(proof.lines[source_line].statement, equality_formula, direction, mode, occurrence, *found);
    if !claimed || !found {
        side := ifx direction == .LHS_TO_RHS then "lhs" else "rhs";
        if mode == .ALL {
            print("No % occurrence was found to rewrite\n", side);
        } else {
            print("Rewrite occurrence % of % was not found\n", occurrence, side);
        }
        return -1;
    }

    rule := ifx direction == .LHS_TO_RHS then Proof_Rule.REWRITE_LHS else Proof_Rule.REWRITE_RHS;
    if mode == .ALL {
        rule = ifx direction == .LHS_TO_RHS then Proof_Rule.REWRITE_LHS_ALL else Proof_Rule.REWRITE_RHS_ALL;
    } else if occurrence != 0 {
        rule = ifx direction == .LHS_TO_RHS then Proof_Rule.REWRITE_LHS_AT else Proof_Rule.REWRITE_RHS_AT;
    }

    line: Proof_Line;
    line.statement = claimed;
    if justification.count > 0 {
        line.justification = justification;
    } else {
        deps_array: [..]int;
        array_add(*deps_array, source_line);
        if equality_dependency >= 0 array_add(*deps_array, equality_dependency);
        if mode == .OCCURRENCE && occurrence != 0 array_add(*deps_array, occurrence);
        line.justification = proof_command_string(proof_rule_name(rule), deps_array);
    }
    array_add(*line.dependencies, source_line);
    if equality_dependency >= 0 array_add(*line.dependencies, equality_dependency);
    array_add(*proof.lines, line);
    complete_goals_for_line(proof, claimed);

    return cast(int) proof.lines.count - 1;
}

begin_subproof :: (proof: *Proof, subgoal: *Formula) {
    current_goal := get_active_goal(proof);
    if !current_goal return;

    array_add(*proof.suspended_goals, current_goal);

    old_goals: [..]*Formula;
    for t: proof.goals {
        array_add(*old_goals, t);
    }
    array_add(*proof.goal_history, old_goals);

    proof.goals[proof.active_goal_idx] = subgoal;
}

// instantiations all modify the goal.

instantiate_forall :: (proof: *Proof, requested_variable: *Term = null) {
    if proof.goals.count == 0 {
        print("No active goals to instantiate\n");
        return;
    }
    
    current_goal := proof.goals[proof.active_goal_idx];
    if current_goal.kind != .FORALL {
        print("instantiate_forall: active goal is not a forall formula\n");
        return;
    }
    
    arbitrary_variable := ifx requested_variable then requested_variable else make_variable(current_goal.forall.v);
    
    membership_assumption := make_rel(SYM_IN, arbitrary_variable, current_goal.forall.domain);
    array_add(*proof.assumptions, membership_assumption);
    
    bound_var := make_variable(current_goal.forall.v);
    new_goal := substitute_in_formula(current_goal.forall.inner, bound_var, arbitrary_variable);
    
    old_goals: [..]*Formula;
    for t: proof.goals {
        array_add(*old_goals, t);
    }
    array_add(*proof.goal_history, old_goals);
    
    proof.goals[proof.active_goal_idx] = new_goal;
}

instantiate_implication :: (proof: *Proof) {
    if proof.goals.count == 0 {
        print("No active goals to instantiate\n");
        return;
    }
    
    current_goal := proof.goals[proof.active_goal_idx];
    if current_goal.kind != .IMPLIES {
        print("instantiate_implication: active goal is not an implication formula\n");
        return;
    }
    
    array_add(*proof.assumptions, current_goal.implies.l);
    
    old_goals: [..]*Formula;
    for t: proof.goals {
        array_add(*old_goals, t);
    }
    array_add(*proof.goal_history, old_goals);
    
    proof.goals[proof.active_goal_idx] = current_goal.implies.r;
}

instantiate_induction :: (proof: *Proof) {
    current_goal := get_active_goal(proof);
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
    
    old_goals: [..]*Formula;
    for t: proof.goals {
        array_add(*old_goals, t);
    }
    array_add(*proof.goal_history, old_goals);
    
    proof.goals[proof.active_goal_idx] = P1;
    array_add(*proof.goals, step_forall);
}

rewrite_goal_with_equality :: (proof: *Proof, equality_proof_line: int, direction: Rewrite_Direction, mode: Rewrite_Mode = .OCCURRENCE, occurrence: int = 0) -> bool {
    if proof.goals.count == 0 {
        print("No active goals to rewrite\n");
        return false;
    }
    
    if equality_proof_line < 0 || equality_proof_line >= proof.lines.count {
        print("Invalid equality line index\n");
        return false;
    }
    
    equality_formula := proof.lines[equality_proof_line].statement;
    if equality_formula.kind != .EQUALITY {
        print("Selected line is not an equality\n");
        return false;
    }

    return rewrite_goal_with_equality_formula(proof, equality_formula, direction, mode, occurrence);
}

rewrite_goal_with_equality_formula :: (proof: *Proof, equality_formula: *Formula, direction: Rewrite_Direction, mode: Rewrite_Mode = .OCCURRENCE, occurrence: int = 0) -> bool {
    if proof.goals.count == 0 {
        print("No active goals to rewrite\n");
        return false;
    }

    if !equality_formula || equality_formula.kind != .EQUALITY {
        print("Selected equality is not an equality\n");
        return false;
    }

    current_goal := proof.goals[proof.active_goal_idx];
    found := false;
    new_goal := rewrite_formula_with_equality(current_goal, equality_formula, direction, mode, occurrence, *found);
    if !new_goal || !found {
        side := ifx direction == .LHS_TO_RHS then "lhs" else "rhs";
        if mode == .ALL {
            print("No % occurrence was found to rewrite in the active goal\n", side);
        } else {
            print("Rewrite occurrence % of % was not found in the active goal\n", occurrence, side);
        }
        return false;
    }
    
    old_goals: [..]*Formula;
    for t: proof.goals {
        array_add(*old_goals, t);
    }
    array_add(*proof.goal_history, old_goals);
    
    proof.goals[proof.active_goal_idx] = new_goal;
    return true;
}

rewrite_goal_using_equality :: (proof: *Proof, equality_proof_line: int) {
    rewrite_goal_with_equality(proof, equality_proof_line, .LHS_TO_RHS, .ALL);
}

rewrite_goal_using_equality_occurrence :: (proof: *Proof, equality_proof_line: int, occurrence: int) {
    rewrite_goal_with_equality(proof, equality_proof_line, .LHS_TO_RHS, .OCCURRENCE, occurrence);
}
