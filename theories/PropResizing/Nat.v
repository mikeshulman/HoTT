(* -*- mode: coq; mode: visual-line -*-  *)
(** * Defining the natural numbers from univalence and propresizing. *)

Require Import HoTT.Basics HoTT.Types UnivalenceImpliesFunext HProp.
Require Import PropResizing.PropResizing PropResizing.Truncations.
Local Open Scope path_scope.

(* Be careful about [Import]ing this file!  Usually you want
to use the standard [Nat] instead. *)

(** Using propositional resizing and univalence, we can construct the
natural numbers rather than defining them as an inductive type.  In
concrete practice there is no reason we would want to do this, but
semantically it means that an elementary (oo,1)-topos (unlike an
elementary 1-topos) automatically has a natural numbers object. *)

Section AssumeStuff.
  Context {UA:Univalence} {PR:PropResizing}.

  (** The basic idea is that since the universe is closed under coproducts, it is already "infinite", so we can find the "smallest infininte set" N inside it.  To get rid of the automorphisms in the universe coming from univalence and make N a set, instead of the universe of types we consider graphs (we could use posets or many other things too; in fact the graphs we are interested in will be posets). *)
  Definition Graph := { V : Type & { E : V -> V -> Type & forall x y, IsHProp (E x y) } }.
  Definition vert : Graph -> Type := pr1.
  Definition edge (A : Graph) : vert A -> vert A -> Type := pr1 (pr2 A).
  Instance ishprop_edge (A : Graph) (x y : vert A) : IsHProp (edge A x y)
    := pr2 (pr2 A) x y.

  Definition equiv_path_graph (A B : Graph)
    : { f : vert A <~> vert B &
            forall x y, edge A x y <-> edge B (f x) (f y) }
        <~> (A = B).
  Proof.
    srefine (equiv_path_sigma _ A B oE _).
    srefine (equiv_functor_sigma' (equiv_path_universe (vert A) (vert B)) _).
    intros f; cbn.
    rewrite transport_sigma.
    srefine (equiv_path_sigma_hprop _ _ oE _). cbn.
    srefine (equiv_path_forall _ _ oE _).
    srefine (equiv_functor_forall' (f^-1) _).
    intros x.
    srefine (equiv_path_forall _ _ oE _).
    srefine (equiv_functor_forall' (f^-1) _).
    intros y. cbn.
    rewrite transport_arrow.
    rewrite transport_arrow_toconst.
    rewrite !transport_path_universe_V.
    rewrite !eisretr.
    srefine (equiv_path_universe _ _ oE _).
    srefine (equiv_equiv_iff_hprop _ _).
  Qed.

  (** N will be the set of graphs generated by the empty graph as
  "zero", and "adding a new top element" as "successor". *)
  Definition graph_zero : Graph
    := ( Empty ; ( fun x y => Empty_rec x ; fun x y => Empty_rec x)).

  Definition graph_succ (A : Graph) : Graph.
  Proof.
    exists (vert A + Unit); srefine (_;_).
    - intros [x|x] [y|y].
      + exact (edge A x y).
      + exact Unit.
      + exact Empty.
      + exact Unit.
    - cbn; intros [x|x] [y|y]; exact _.
  Defined.

  (** The following lemmas about graphs will be used later on to prove
  the Peano axioms about N. *)

  Definition graph_succ_top {A : Graph} (x : vert (graph_succ A))
    : edge (graph_succ A) x (inr tt).
  Proof.
    destruct x as [x|x]; exact tt.
  Qed.

  Definition graph_succ_top_unique
             {A : Graph} (y : vert (graph_succ A))
             (yt : forall x, edge (graph_succ A) x y)
    : y = inr tt.
  Proof.
    destruct y as [y|[]].
    - destruct (yt (inr tt)).
    - reflexivity.
  Qed.

  Definition graph_succ_not_top {A : Graph} (x : vert A)
    : ~(edge (graph_succ A) (inr tt) (inl x))
    := idmap.

  Definition graph_succ_not_top_unique {A : Graph} (x : vert (graph_succ A))
             (xt : ~(edge (graph_succ A) (inr tt) x))
    : is_inl x.
  Proof.
    destruct x as [x|x].
    - exact tt.
    - destruct (xt tt).
  Qed.

  Section Graph_Succ_Equiv.
    Context {A B : Graph} (f : vert (graph_succ A) <~> vert (graph_succ B))
            (e : forall x y, edge (graph_succ A) x y <-> edge (graph_succ B) (f x) (f y)).

    Definition graph_succ_equiv_inr : f (inr tt) = inr tt.
    Proof.
      apply (graph_succ_top_unique (f (inr tt))).
      intros x.
      rewrite <- (eisretr f x).
      apply (fst (e (f^-1 x) (inr tt))).
      apply graph_succ_top.
    Qed.

    Local Definition Ha : forall x, is_inl (f (inl x)).
    Proof.
      intros x.
      apply graph_succ_not_top_unique.
      rewrite <- (eisretr f (inr tt)).
      intros ed.
      apply (snd (e (f^-1 (inr tt)) (inl x))) in ed.
      pose (finr := graph_succ_equiv_inr).
      apply moveL_equiv_V in finr.
      rewrite <- finr in ed.
      exact (graph_succ_not_top x ed).
    Qed.

    Local Definition Hb : forall x, is_inr (f (inr x)).
    Proof.
      destruct x.
      srefine (transport is_inr graph_succ_equiv_inr^ tt).
    Qed.

    Definition graph_unsucc_equiv_vert : vert A <~> vert B
      := equiv_unfunctor_sum_l f Ha Hb.

    Definition graph_unsucc_equiv_edge (x y : vert A)
      : edge A x y <-> edge B (graph_unsucc_equiv_vert x) (graph_unsucc_equiv_vert y).
    Proof.
      pose (h := e (inl x) (inl y)).
      rewrite <- (unfunctor_sum_l_beta f Ha x) in h.
      rewrite <- (unfunctor_sum_l_beta f Ha y) in h.
      exact h.
    Qed.

  End Graph_Succ_Equiv.

  Definition graph_succ_path_equiv (A B : Graph)
    : (A = B) <~> (graph_succ A = graph_succ B).
  Proof.
    refine ((equiv_path_graph _ _) oE _).
    refine (_ oE (equiv_path_graph _ _)^-1).
    srefine (equiv_adjointify _ _ _ _).
    - intros [f e].
      exists (f +E 1).
      intros x y.
      destruct x as [x|x]; destruct y as [y|y]; cbn.
      + apply e.
      + split; apply idmap.
      + split; apply idmap.
      + split; apply idmap.
    - intros [f e].
      exists (graph_unsucc_equiv_vert f e).
      exact (graph_unsucc_equiv_edge f e).
    - intros [f e].
      apply path_sigma_hprop; cbn.
      apply path_equiv, path_arrow; intros [x|[]]; cbn.
      + apply unfunctor_sum_l_beta.
      + symmetry; apply graph_succ_equiv_inr, e.
    - intros [f e].
      apply path_sigma_hprop; cbn.
      apply path_equiv, path_arrow; intros x; reflexivity.
  Defined.

  Definition graph_unsucc_path (A B : Graph)
    : (graph_succ A = graph_succ B) -> A = B
    := (graph_succ_path_equiv A B)^-1.

  (** Here is the impredicative definition of N, as the smallest
  subtype of [Graph] containing [graph_zero] and closed under
  [graph_succ]. *)
  Definition in_N (n : Graph) : Type
    := forall (P : Graph -> Type),
           (forall A, IsHProp (P A))
           -> P graph_zero
           -> (forall A, P A -> P (graph_succ A))
           -> P n.

  Instance ishprop_in_N (n : Graph) : IsHProp (in_N n).
  Proof.
    apply trunc_forall.
  Qed.

  Definition N : Type
    := { n : Graph & in_N n }.

  Definition path_N (n m : N) : n.1 = m.1 -> n = m
    := path_sigma_hprop n m.

  Definition zero : N.
  Proof.
    exists graph_zero.
    intros P PH P0 Ps; exact P0.
  Defined.

  Definition succ : N -> N.
  Proof.
    intros [n nrec].
    exists (graph_succ n).
    intros P PH P0 Ps. apply Ps.
    exact (nrec P PH P0 Ps).
  Defined.

  (** First Peano axiom: successor is injective *)
  Definition succ_inj (n m : N) (p : succ n = succ m) : n = m.
  Proof.
    apply path_N.
    apply ((graph_succ_path_equiv n.1 m.1)^-1).
    exact (p..1).
  Qed.

  (** A slightly more general version of the theorem that N is a set,
  which will be useful later. *)
  Instance ishprop_path_N (n : N) (A : Graph) : IsHProp (n.1 = A).
  Proof.
    destruct n as [n nrec]; cbn.
    apply hprop_inhabited_contr; intros [].
    apply nrec; try exact _.
    - apply contr_inhabited_hprop; try exact 1.
      apply hprop_allpath.
      equiv_intro (equiv_path_graph graph_zero graph_zero) fe.
      destruct fe as [f e].
      equiv_intro (equiv_path_graph graph_zero graph_zero) fe'.
      destruct fe' as [f' e'].
      apply equiv_ap; try exact _.
      apply path_sigma_hprop, path_equiv, path_arrow.
      intros [].
    - intros B BC.
      refine (contr_equiv (B = B) (graph_succ_path_equiv B B)).
  Qed.

  Instance ishset_N : IsHSet N.
  Proof.
    intros n m.
    change (IsHProp (n = m)).
    refine (trunc_equiv (n.1 = m.1) (equiv_path_sigma_hprop n m)).
  Qed.

  Definition graph_zero_neq_succ {A : Graph}
    : graph_zero <> graph_succ A.
  Proof.
    intros p.
    destruct ((equiv_path_graph graph_zero (graph_succ A))^-1 p) as [f e].
    exact (f^-1 (inr tt)).
  Qed.

  (** Second Peano axiom: zero is not a successor *)
  Definition zero_neq_succ (n : N) : zero <> succ n.
  Proof.
    intros p; apply pr1_path in p; refine (graph_zero_neq_succ p).
  Qed.

  (** This tweak is sometimes necessary to avoid universe inconsistency.
  It's how the impredicativity of propositional resizing enters. *)
  Definition resize_nrec (n : Graph) (nrec : in_N n)
    : in_N n.
  Proof.
    intros P' PH' P0' Ps'.
    srefine ((equiv_resize_hprop (P' n))^-1
             (nrec (fun A => resize_hprop (P' A)) _ _ _));
      try exact _; cbn.
    - exact (equiv_resize_hprop (P' graph_zero) P0').
    - intros A P'A.
      exact (equiv_resize_hprop (P' (graph_succ A))
                                (Ps' A ((equiv_resize_hprop (P' A))^-1 P'A))).
  Qed.

  Definition N_zero_or_succ (n : N)
    : merely ((n = zero) + { m : N & n = succ m }).
  Proof.
    apply (functor_merely
           (functor_sum (path_N _ _)
                       (functor_sigma (Q := fun m:N => n = succ m) idmap (fun m => path_N _ (succ m))))).
    destruct n as [n nrec]; cbn.
    srefine (resize_nrec n nrec
             (fun n => merely ((n = graph_zero) +
                       {m : N & n = graph_succ m.1})) _ _ _); cbn.
    - apply trm, inl; reflexivity.
    - intros A; apply functor_merely; intros [A0|[m As]]; apply inr.
      + exists zero.
        rewrite A0.
        reflexivity.
      + exists (succ m).
        rewrite As.
        reflexivity.
  Qed.

  Definition pred_in_N (n : Graph) (snrec : in_N (graph_succ n))
    : in_N n.
  Proof.
    refine (merely_rec _ (N_zero_or_succ (graph_succ n ; snrec))).
    intros [H0|[m Hs]].
    - apply pr1_path in H0; cbn in H0.
      destruct (graph_zero_neq_succ H0^).
    - apply pr1_path in Hs.
      apply graph_unsucc_path in Hs.
      apply (transport in_N Hs^).
      exact m.2.
  Qed.

  (** Final Peano axiom: induction *)
  Definition N_propind (P : N -> Type) `{forall n, IsHProp (P n)}
             (P0 : P zero) (Ps : forall n, P n -> P (succ n))
    : forall n, P n.
  Proof.
    intros [n nrec].
    pose (Q := fun m:Graph => forall (mrec : in_N m), P (m;mrec)).
    refine (resize_nrec n nrec Q _ _ _ nrec).
    - intros A; apply trunc_forall.
    - intros zrec.
      refine (transport P _ P0).
      apply ap.
      apply path_ishprop.
    - intros A QA Asrec.
      pose (m := (A ; pred_in_N A Asrec) : N).
      refine (transport P _ (Ps m (QA (pred_in_N A Asrec)))).
      apply path_N; reflexivity.
  Qed.

  (** A first application *)
  Definition N_neq_succ (n : N) : n <> succ n.
  Proof.
    revert n; apply N_propind; try exact _.
    - apply zero_neq_succ.
    - intros n H e.
      apply H.
      exact (succ_inj n (succ n) e).
  Qed.

  (** Now we want to use induction to define recursion.  The basic
  idea is the same as always: define partial attempts and show by
  induction that they are uniquely defined.  But we have to be careful
  to phrase it in a way that works without assuming any truncation
  restritions on the codomain.

  First we need inequality on N, which we define in terms of addition.
  Normally addition is defined *using* recursion, but here we can
  "cheat" because we know how to add graphs, and then prove that it
  satisfies the recursive equations for addition. *)
  Definition graph_add (A B : Graph) : Graph.
  Proof.
    exists (vert A + vert B).
    exists (fun ab ab' =>
              match ab, ab' with
              | inl a, inl a' => edge A a a'
              | inl a, inr b => Unit
              | inr b, inl a => Empty
              | inr b, inr b' => edge B b b'
              end).
    intros [a|b] [a'|b']; exact _.
  Defined.

  Definition graph_add_zero_r (A : Graph) : graph_add A graph_zero = A.
  Proof.
    apply equiv_path_graph.
    exists (sum_empty_r (vert A)).
    intros [x|[]] [y|[]]; reflexivity.
  Qed.

  Definition graph_add_zero_l (A : Graph) : graph_add graph_zero A = A.
  Proof.
    apply equiv_path_graph.
    exists (sum_empty_l (vert A)).
    intros [[]|x] [[]|y]; reflexivity.
  Qed.

  Definition graph_add_succ (A B : Graph)
    : graph_add A (graph_succ B) = graph_succ (graph_add A B).
  Proof.
    apply equiv_path_graph.
    exists (equiv_inverse (equiv_sum_assoc (vert A) (vert B) Unit)).
    intros [x|[x|[]]] [y|[y|[]]]; reflexivity.
  Qed.

  Definition graph_add_assoc (A B C : Graph)
    : graph_add (graph_add A B) C = graph_add A (graph_add B C).
  Proof.
    apply equiv_path_graph.
    exists (equiv_sum_assoc _ _ _).
    intros [[x|x]|x] [[y|y]|y]; reflexivity.
  Qed.

  Definition graph_one : Graph.
  Proof.
    refine (Unit;(fun _ _ => Unit;_)); exact _.
  Defined.

  Definition graph_add_one_succ (A : Graph)
    : graph_add A graph_one = graph_succ A.
  Proof.
    apply equiv_path_graph.
    exists equiv_idmap.
    intros [x|[]] [y|[]]; reflexivity.
  Qed.

  Definition graph_succ_zero : graph_succ graph_zero = graph_one.
  Proof.
    rewrite <- graph_add_one_succ.
    apply graph_add_zero_l.
  Qed.

  Definition one : N.
  Proof.
    exists graph_one.
    intros P PH P0 Ps.
    rewrite <- graph_succ_zero.
    apply Ps, P0.
  Defined.

  Definition N_add (n m : N) : N.
  Proof.
    exists (graph_add n.1 m.1).
    intros P PH P0 Ps.
    apply m.2.
    - intros; apply PH.
    - apply (transport P (graph_add_zero_r n.1)^).
      exact (n.2 P PH P0 Ps).
    - intros A PA.
      apply (transport P (graph_add_succ n.1 A)^).
      apply Ps, PA.
  Defined.

  Notation "n + m" := (N_add n m).

  Definition N_add_zero_l (n : N) : zero + n = n.
  Proof.
    apply path_N, graph_add_zero_l.
  Qed.

  Definition N_add_zero_r (n : N) : n + zero = n.
  Proof.
    apply path_N, graph_add_zero_r.
  Qed.

  Definition N_add_succ (n m : N) : n + succ m = succ (n + m).
  Proof.
    apply path_N, graph_add_succ.
  Qed.

  Definition N_add_assoc (n m k : N) : (n + m) + k = n + (m + k).
  Proof.
    apply path_N, graph_add_assoc.
  Qed.

  Definition N_add_cancel_r (n m k : N) (H : n + k = m + k)
    : n = m.
  Proof.
    revert k H.
    refine (N_propind _ _ _).
    - intros H; rewrite !N_add_zero_r in H; exact H.
    - intros k H1 H2.
      rewrite !N_add_succ in H2.
      apply H1.
      exact (succ_inj _ _ H2).
  Qed.

  Definition N_add_cancel_zero_r (n k : N) (H : k + n = n)
    : k = zero.
  Proof.
    refine (N_add_cancel_r k zero n _).
    rewrite H; symmetry.
    apply path_N, graph_add_zero_l.
  Qed.

  Definition N_add_one_r (n : N) : n + one = succ n.
  Proof.
    apply path_N; cbn.
    apply graph_add_one_succ.
  Qed.

  Definition N_add_one_l (n : N) : one + n = succ n.
  Proof.
    revert n; refine (N_propind (fun m => one + m = succ m) _ _).
    - rewrite N_add_zero_r.
      apply path_N.
      symmetry; apply graph_succ_zero.
    - intros n H.
      rewrite N_add_succ.
      apply ap, H.
  Qed.

  Definition N_add_succ_l (n m : N) : succ n + m = succ (n + m).
  Proof.
    rewrite <- (N_add_one_r n).
    rewrite N_add_assoc.
    rewrite N_add_one_l.
    apply N_add_succ.
  Qed.

  (** Now we define inequality in terms of addition. *)
  Definition N_le (n m : N) : Type
    := merely { k : N & k + n = m }.

  Notation "n <= m" := (N_le n m).

  Definition N_zero_le (n : N) : zero <= n.
  Proof.
    apply trm; exists n.
    apply N_add_zero_r.
  Qed.

  Definition N_le_zero (n : N) (H : n <= zero) : n = zero.
  Proof.
    unfold N_le in H.
    revert H; apply merely_rec; intros [k H].
    apply pr1_path in H.
    apply ((equiv_path_graph _ _)^-1), pr1 in H.
    assert (f := (fun x => H (inr x)) : (vert n.1) -> Empty).
    apply path_N, equiv_path_graph.
    srefine ((BuildEquiv _ _ f _);_); cbn.
    intros x y; destruct (f x).
  Qed.

  Instance contr_le_zero : Contr {n:N & n <= zero}.
  Proof.
    exists (existT (fun n => n <= zero) zero (N_zero_le zero)).
    intros [n H].
    apply path_sigma_hprop.
    exact (N_le_zero n H)^.
  Qed.

  Instance reflexive_N_le : Reflexive N_le.
  Proof.
    intros n.
    apply trm; exists zero.
    apply N_add_zero_l.
  Qed.

  Definition N_lt (n m : N) : Type
    := merely { k : N & (succ k) + n = m }.

  Notation "n < m" := (N_lt n m).

  Definition N_lt_zero (n : N) : ~(n < zero).
  Proof.
    unfold N_lt; intros H; revert H.
    apply merely_rec; intros [k H].
    apply pr1_path, (equiv_path_graph _ _)^-1, pr1 in H.
    exact (H (inl (inr tt))).
  Qed.

  Definition N_lt_irref (n : N) : ~(n < n).
  Proof.
    revert n; apply N_propind; try exact _.
    - apply N_lt_zero.
    - intros n H K.
      unfold N_lt in H, K.
      revert K; apply merely_rec; intros [k K].
      apply H, trm.
      exists k.
      rewrite N_add_succ in K.
      apply succ_inj; assumption.
  Qed.

  Definition N_le_eq_or_lt (n m : N) (H : n <= m)
    : (n = m) + (n < m).
  Proof.
    assert (HP : IsHProp ((n = m) + (n < m))).
    { apply ishprop_sum; try exact _.
      intros [].
      apply merely_rec; intros [l K].
      apply N_add_cancel_zero_r in K.
      symmetry in K; apply zero_neq_succ in K; assumption. }
    unfold N_le in H.
    revert H; apply merely_rec; intros [k K].
    generalize (N_zero_or_succ k); apply merely_rec; intros [k0|[l L]].
    - rewrite k0 in K.
      rewrite (N_add_zero_l n) in K.
      exact (inl K).
    - rewrite L in K.
      apply inr, trm.
      exact (l;K).
  Qed.

  Definition N_succ_nlt (n : N) : ~(succ n < n).
  Proof.
    revert n; apply N_propind; try exact _.
    - apply N_lt_zero.
    - intros n H L.
      apply H; clear H.
      unfold N_lt in *.
      revert L; apply functor_merely; intros [k H].
      exists k.
      rewrite N_add_succ in H.
      exact (succ_inj _ _ H).
  Qed.

  Definition N_lt_succ (n : N) : n < succ n.
  Proof.
    unfold N_lt.
    apply trm; exists zero.
    rewrite N_add_succ_l.
    apply ap, N_add_zero_l.
  Qed.

  Definition N_succ_lt (n m : N) (H : n < m) : succ n < succ m.
  Proof.
    revert H; apply functor_merely; intros [k H].
    exists k.
    rewrite N_add_succ.
    apply ap; assumption.
  Qed.

  Definition N_lt_le (n m : N) (H : n < m) : n <= m.
  Proof.
    revert H; apply functor_merely; intros [k K].
    exact (succ k; K).
  Qed.

  Definition N_lt_iff_succ_le (n m : N) :
    (n < m) <-> (succ n <= m).
  Proof.
    split; apply functor_merely; intros [k H]; exists k.
    - rewrite N_add_succ, <- N_add_succ_l.
      assumption.
    - rewrite N_add_succ_l, <- N_add_succ.
      assumption.
  Qed.

  Definition N_lt_succ_iff_le (n m : N) : (n < succ m) <-> (n <= m).
  Proof.
    split; apply functor_merely; intros [k H]; exists k.
    - rewrite N_add_succ_l in H.
      exact (succ_inj _ _ H).
    - rewrite N_add_succ_l; apply ap, H.
  Qed.

  Definition equiv_N_segment (n : N)
    : { m : N & m <= n } <~> {m : N & m < n} + Unit.
  Proof.
    srefine (equiv_adjointify _ _ _ _).
    - intros [m H].
      destruct (N_le_eq_or_lt m n H) as [H0|Hs].
      + exact (inr tt).
      + exact (inl (m;Hs)).
    - intros [[m H]|[]].
      + exact (m; N_lt_le m n H).
      + exists n; reflexivity.
    - abstract (intros [[m H]|[]]; cbn;
      [ generalize (N_le_eq_or_lt m n (N_lt_le m n H));
        intros [H0|Hs]; cbn;
        [ apply Empty_rec;
          rewrite H0 in H; exact (N_lt_irref n H)
        | apply ap, ap, path_ishprop ]
      | generalize (N_le_eq_or_lt n n (reflexive_N_le n));
        intros [H0|Hs];
        [ reflexivity
        | apply Empty_rec;
          exact (N_lt_irref n Hs) ]]).
    - abstract (intros [m H]; cbn;
      generalize (N_le_eq_or_lt m n H);
      intros [H0|Hs]; cbn;
      [ apply path_sigma_hprop;
        symmetry; assumption
      | apply ap, path_ishprop ]).
  Defined.

  Definition equiv_N_segment_succ (n : N)
    : { m : N & m <= succ n } <~> {m : N & m <= n} + Unit.
  Proof.
    refine (_ oE equiv_N_segment (succ n)).
    apply equiv_functor_sum_r.
    apply equiv_functor_sigma_id.
    intros m; apply equiv_iff_hprop_uncurried, N_lt_succ_iff_le.
  Defined.

  (** A fancy name for [1] so that we can [rewrite] with it later. *)
  Definition equiv_N_segment_succ_inv_inl (n : N) (mh : {m:N & m <= n})
    : ((equiv_N_segment_succ n)^-1 (inl mh)).1 = mh.1.
  Proof.
    reflexivity.
  Qed.

  Definition equiv_N_segment_lt_succ (n : N)
    : { m : N & m < succ n } <~> {m : N & m <= n}.
  Proof.
    apply equiv_functor_sigma_id.
    intros; apply equiv_iff_hprop; apply N_lt_succ_iff_le.
  Defined.

  Definition zero_seg (n : N) : { m : N & m <= n }
    := (zero ; N_zero_le n).

  Definition succ_seg (n : N)
    : { m : N & m < n } -> { m : N & m <= n }
    := fun mh =>
         let (m,H) := mh in
         (succ m; fst (N_lt_iff_succ_le m n) H).

  Definition refl_seg (n : N) : {m : N & m <= n}.
  Proof.
    exists n.
    reflexivity.
  Defined.

  (** Now we're finally ready to prove recursion. *)
  Section NRec.
    (** Here is the type we will recurse into.  Importantly, it
    doesn't have to be a set! *)
    Context (X : Type) (x0 : X) (xs : X -> X).

    (** The type of partially defined recursive functions "up to [n]". *)
    Local Definition partial_Nrec (n : N) : Type
      := { f : { m : N & m <= n} -> X &
           (f (zero_seg n) = x0) *
           forall (mh : {m:N & m < n}),
             f (succ_seg n mh) = xs (f ((equiv_N_segment n)^-1 (inl mh))) }.

    (** The crucial point that makes it work for arbitrary [X] is to
    prove in one big induction that these types are always
    contractible.  Here is the base case. *)
    Local Instance contr_partial_Nrec_zero : Contr (partial_Nrec zero).
    Proof.
      unfold partial_Nrec.
      srefine (trunc_equiv' {f0 : {f : {m : N & m <= zero} -> X &
    (f (zero_seg zero) = x0)} &
    (forall mh : {m : N & m < zero},
     f0.1 (succ_seg zero mh) =
     xs (f0.1 ((equiv_N_segment zero)^-1 (inl mh))))} _).
      - exact _.
      - refine (_ oE equiv_inverse (equiv_sigma_assoc _ _)).
        apply equiv_functor_sigma_id; intros f.
        cbn; apply equiv_sigma_prod0.
      - refine (@trunc_sigma _ _ _ _ _).
        + srefine (BuildContr _ _ _).
          * exists (fun _ => x0); reflexivity.
          * intros [g H].
            srefine (path_sigma _ _ _ _ _); cbn.
            { apply path_forall; intros m.
              exact (H^ @ ap g (path_ishprop _ _)). }
            { rewrite transport_paths_Fl.
              rewrite ap_apply_l.
              rewrite ap10_path_forall.
              rewrite inv_pp, inv_V, concat_p1.
              transitivity ((ap g 1)^ @ H).
              - apply whiskerR, ap, ap.
                apply path_ishprop.
              - apply concat_1p. }
        + intros [f H].
          exists (fun mh => Empty_rec (N_lt_zero mh.1 mh.2)).
          intros g.
          apply path_forall; intros m.
          destruct (N_lt_zero m.1 m.2).
    Qed.

    Local Definition equiv_N_segment_succ_maps (n : N)
      : ({ m : N & m <= n} -> X) * X <~> ({ m : N & m <= succ n} -> X).
    Proof.
      refine (_ oE @equiv_sum_ind _ {m:N&m<=n} Unit (fun _ => X) oE _).
      - apply equiv_precompose'.
        apply equiv_N_segment_succ.
      - apply equiv_functor_prod_l.
        apply equiv_unit_rec.
    Defined.

    Local Definition equiv_seg_succ (n m : N) (H : m < succ n)
               (f : { m : N & m <= n} -> X) (xsn : X)
      : equiv_N_segment_succ_maps n (f,xsn) (m ; N_lt_le m _ H) = f (existT (fun m=>m<=n) m (fst (N_lt_succ_iff_le m _) H)).
    Proof.
      cbn.
      generalize (N_le_eq_or_lt m (succ n) (N_lt_le m (succ n) H)).
      intros [E|L].
      - apply Empty_rec.
        rewrite E in H.
        exact (N_lt_irref _ H).
      - cbn.
        apply ap, path_sigma_hprop; reflexivity.
    Qed.

    (** And here, essentially, is the inductive step. *)
    Local Definition partial_Nrec_succ (n : N)
      : partial_Nrec n <~> partial_Nrec (succ n).
    Proof.
      unfold partial_Nrec.
      srefine (equiv_functor_sigma' (equiv_N_segment_succ_maps n) _ oE _).
      { intros [f xsn].
        srefine ((f (zero_seg n) = x0) *
           ((forall (mh : {m:N & m < n}),
             f (succ_seg n mh) = xs (f ((equiv_N_segment n)^-1 (inl mh)))) *
           (xsn = xs (f (refl_seg n))))). }
      { intros [f xsn].
        apply equiv_functor_prod'.
        { apply equiv_concat_l.
          cbn.
          generalize (N_le_eq_or_lt zero (succ n) (N_zero_le (succ n))).
          intros [H0|Hs].
          + destruct (zero_neq_succ n (H0)).
          + cbn. apply ap.
            apply path_sigma_hprop; reflexivity. }
        { srefine ((equiv_functor_forall_pf
                      (Q := fun mh =>
                              (equiv_N_segment_succ_maps n)
                                (f, xsn) (succ_seg (succ n) mh)
                              = xs ((equiv_N_segment_succ_maps n)
                                      (f, xsn)
                                      ((equiv_N_segment (succ n))^-1
                                         (inl mh))))
                   (equiv_N_segment_lt_succ n)) oE _).
          srefine ((equiv_functor_forall_pf (equiv_N_segment n)) oE _).
          srefine (equiv_sum_ind _ oE _).
          apply equiv_functor_prod'.
          - apply equiv_functor_forall_id; intros [m H].
            apply equiv_concat_lr.
            + transitivity ((equiv_N_segment_succ_maps n)
                              (f,xsn)
                              (succ m; N_lt_le _ _ (N_succ_lt m n H))).
              * apply ap. apply path_sigma_hprop. reflexivity.
              * rewrite equiv_seg_succ.
                apply ap, path_sigma_hprop; reflexivity.
            + apply ap. cbn.
              match goal with
              | [ |- context[match ?L with | inl _ => inr tt | inr Hs => inl (?k; Hs) end] ] => generalize L
              end.
              intros [L|L].
              * apply Empty_rec; rewrite L in H.
                exact (N_succ_nlt n H).
              * cbn. apply ap, path_sigma_hprop; reflexivity.
          - refine ((equiv_contr_forall _)^-1 oE _).
            apply equiv_concat_lr.
            + cbn.
              match goal with
              | [ |- context[match ?L with | inl _ => inr tt | inr Hs => inl (?k; Hs) end] ] => generalize L
              end.
              intros [L|L].
              * reflexivity.
              * destruct (N_lt_irref _ L).
            + apply ap. cbn.
              match goal with
              | [ |- context[match ?L with | inl _ => inr tt | inr Hs => inl (?k; Hs) end] ] => generalize L
              end.
              intros [L|L].
              * case (N_neq_succ n L).
              * cbn.
                apply ap, path_sigma_hprop. reflexivity. } }
      { refine (equiv_sigma_prod _ oE _).
        apply equiv_functor_sigma_id. intros f.
        refine (equiv_functor_sigma_id (fun b:X => equiv_sigma_prod0 _ _) oE _).
        refine (equiv_sigma_symm _ oE _).
        refine (_ oE (equiv_sigma_prod0 _ _)^-1).
        apply equiv_functor_sigma_id; intros f0.
        refine (equiv_functor_sigma_id (fun b:X => equiv_sigma_prod0 _ _) oE _).
        refine (equiv_sigma_symm _ oE _).
        exact ((equiv_sigma_contr _)^-1%equiv). }
    Defined.

    Local Instance contr_partial_Nrec (n : N) : Contr (partial_Nrec n).
    Proof.
      revert n; apply N_propind; try exact _.
      intros n H.
      refine (trunc_equiv' _ (partial_Nrec_succ n)).
    Qed.

    (** This will be useful later. *)
    Local Definition partial_Nrec_restr (n : N)
      : partial_Nrec (succ n) -> partial_Nrec n.
    Proof.
      intros f.
      destruct f as [f [f0 fs]].
      exists (fun mh => f ((equiv_N_segment_succ n)^-1 (inl mh))).
      split.
      - refine (_ @ f0).
        apply ap, path_sigma_hprop. reflexivity.
      - intros mh.
        refine (_ @ fs (((equiv_N_segment_lt_succ n)^-1)
                          ((equiv_N_segment n)^-1 (inl mh))) @ _).
        + apply ap.
          apply path_sigma_hprop; reflexivity.
        + apply ap, ap.
          apply path_sigma_hprop; reflexivity.
    Defined.

    (** Finally, we want to put all this together to show that the
    type of fully defined recursive functions is contractible, so that
    N has the universal property of a natural numbers object.  If we
    attack it directly, this can lead to quite annoying path algebra.
    Instead, we will show that it is a retract of the product of all
    the types of partial attempts, which is contractible since each of
    them is.  *)
    Local Definition partials := forall n, partial_Nrec n.
    Local Instance contr_partials : Contr partials := _.

    (** From a family of partial attempts, we get a totally defined
    recursive function. *)
    Section Partials.
      Context (pf : partials).

      Local Definition N_rec' : N -> X
        := fun n => (pf n).1 (refl_seg n).

      Definition N_rec_beta_zero' : N_rec' zero = x0.
      Proof.
        refine (_ @ fst (pf zero).2).
        unfold N_rec'.
        apply ap, path_sigma_hprop; reflexivity.
      Defined.

      Definition N_rec_beta_succ' (n : N)
        : N_rec' (succ n) = xs (N_rec' n).
      Proof.
        unfold N_rec'.
        refine (_ @ snd (pf (succ n)).2
                  (n ; N_lt_succ n) @ _).
        - apply ap, path_sigma_hprop; reflexivity.
        - apply ap.
          transitivity ((partial_Nrec_restr n (pf (succ n))).1 (refl_seg n)).
          + refine (ap (pf (succ n)).1 _).
            apply path_sigma_hprop; reflexivity.
          + apply ap10.
            apply ap, path_contr.
      Defined.

    End Partials.

    (** Applying this to the "canonical" partial attempts, we get "the recursor". *)
    Definition N_rec : N -> X := N_rec' (center partials).
    Definition N_rec_beta_zero : N_rec zero = x0
      := N_rec_beta_zero' (center partials).
    Definition N_rec_beta_succ (n : N)
      : N_rec (succ n) = xs (N_rec n)
      := N_rec_beta_succ' (center partials) n.

    (** Here is the type of totally defined recursive functions that
    we want to prove to be contractible. *)
    Definition NRec : Type
      := { f : N -> X &
           (f zero = x0) *
           forall m:N, f (succ m) = xs (f m) }.

    Local Definition nrec_partials : NRec -> partials.
    Proof.
      intros f n.
      exists (fun mh => f.1 mh.1).
      split.
      - exact (fst f.2).
      - intros mh.
        exact (snd f.2 mh.1).
    Defined.

    (** This is a weird lemma.  We could prove it by [path_contr], but
    we give an explicit proof instead using [path_sigma], so that
    later on we know what happens when [pr1_path] is applied to it. *)
    Local Definition nrec_partials_succ (n : N) (f : NRec)
      : partial_Nrec_restr n (nrec_partials f (succ n)) = nrec_partials f n.
    Proof.
      srefine (path_sigma' _ 1 _).
      abstract (rewrite transport_1;
      apply path_prod;
      [ cbn;
        rewrite ap_compose;
        rewrite ap_pr1_path_sigma_hprop;
        apply concat_1p
      | cbn;
        apply path_forall; intros mh;
        rewrite ap_compose;
        rewrite ap_pr1_path_sigma_hprop;
        rewrite ap_1, concat_1p;
        refine (_ @ concat_p1 _); apply whiskerL;
        refine (_ @ ap_1 _ xs); apply ap;
        rewrite ap_compose;
        rewrite ap_pr1_path_sigma_hprop;
        reflexivity ]).
    Defined.

    Local Definition partials_nrec : partials -> NRec.
    Proof.
      intros pf.
      exists (N_rec' pf).
      exact (N_rec_beta_zero' pf, N_rec_beta_succ' pf).
    Defined.

    Local Definition nrec_partials_sect (f : NRec)
      : partials_nrec (nrec_partials f) = f.
    Proof.
      destruct f as [f [f0 fs]].
      unfold partials_nrec, nrec_partials. cbn.
      unfold N_rec', N_rec_beta_zero'; cbn.
      apply ap, path_prod.
      - cbn.
        rewrite ap_compose.
        rewrite ap_pr1_path_sigma_hprop.
        apply concat_1p.
      - cbn.
        unfold N_rec_beta_succ'.
        apply path_forall; intros n.
        cbn.
        rewrite ap_compose.
        rewrite ap_pr1_path_sigma_hprop.
        rewrite ap_1, concat_1p.
        rewrite (ap_compose pr1 f).
        rewrite ap_pr1_path_sigma_hprop.
        rewrite ap_1, concat_1p.
        refine (_ @ (concat_p1 _)); apply whiskerL.
        (** Here is where we use [nrec_partials_succ]: the [path_contr] equal to it, which allows us to identify [ap pr1] of the latter.  (Note that [ap pr1] of a [path_contr] can be nontrivial even when the endpoints happen to coincide judgmentally, for instance (x;p) and (x;1) in {y:X & y = x}, so there really is something to prove here.) *)
        transitivity (ap xs (ap10 (ap pr1 (nrec_partials_succ n (f;(f0,fs)))) (refl_seg n))).
        + apply ap.
          assert (p : path_contr _ _ =  nrec_partials_succ n (f; (f0, fs))).
          { apply path_contr. }
          exact (ap (fun h => ap10 (ap pr1 h) (refl_seg n)) p).
        + unfold nrec_partials_succ.
          unfold path_sigma'.
          rewrite ap_pr1_path_sigma.
          reflexivity.
    Qed.

    (** And we're done! *)
    Global Instance contr_NRec : Contr NRec.
    Proof.
      refine (trunc_equiv partials partials_nrec).
      refine (isequiv_adjointify _ nrec_partials nrec_partials_sect _).
      intros x; apply path_contr.
    Defined.

  End NRec.

End AssumeStuff.
