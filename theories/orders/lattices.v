Require Import
  HoTTClasses.interfaces.abstract_algebra
  HoTTClasses.interfaces.orders
  HoTTClasses.orders.maps
  HoTTClasses.theory.lattices.

(*
We prove that the algebraic definition of a lattice corresponds to the
order theoretic one. Note that we do not make any of these instances global,
because that would cause loops.
*)
Section join_semilattice_order.
  Context `{JoinSemiLatticeOrder L}.

  Lemma join_ub_3_r x y z : z ≤ x ⊔ y ⊔ z.
  Proof.
  apply join_ub_r.
  Qed.

  Lemma join_ub_3_m x y z : y ≤ x ⊔ y ⊔ z.
  Proof.
  transitivity (x ⊔ y).
  - apply join_ub_r.
  - apply join_ub_l.
  Qed.

  Lemma join_ub_3_l x y z : x ≤ x ⊔ y ⊔ z.
  Proof.
  transitivity (x ⊔ y); apply join_ub_l.
  Qed.

  Lemma join_ub_3_assoc_l x y z : x ≤ x ⊔ (y ⊔ z).
  Proof.
  apply join_ub_l.
  Qed.

  Lemma join_ub_3_assoc_m x y z : y ≤ x ⊔ (y ⊔ z).
  Proof.
  transitivity (y ⊔ z).
  - apply join_ub_l.
  - apply join_ub_r.
  Qed.

  Lemma join_ub_3_assoc_r x y z : z ≤ x ⊔ (y ⊔ z).
  Proof.
  transitivity (y ⊔ z); apply join_ub_r.
  Qed.

  Instance join_sl_order_join_sl: JoinSemiLattice L.
  Proof.
  repeat split.
  - apply _.
  - intros x y z. apply (antisymmetry (≤)).
    + apply join_lub.
      * apply join_ub_3_l.
      * apply join_lub.
        ** apply join_ub_3_m.
        ** apply join_ub_3_r.
    + apply join_lub.
      * apply join_lub.
        ** apply join_ub_3_assoc_l.
        ** apply join_ub_3_assoc_m.
      * apply join_ub_3_assoc_r.
  - intros x y. apply (antisymmetry (≤)); apply join_lub;
    first [apply join_ub_l | apply join_ub_r].
  - intros x. red. apply (antisymmetry (≤)).
    + apply join_lub; apply reflexivity.
    + apply join_ub_l.
  Qed.

  Lemma join_le_compat_r x y z : z ≤ x → z ≤ x ⊔ y.
  Proof.
  intros E. transitivity x.
  - trivial.
  - apply join_ub_l.
  Qed.

  Lemma join_le_compat_l x y z : z ≤ y → z ≤ x ⊔ y.
  Proof.
  intros E. rewrite (commutativity (f:=join)).
  apply join_le_compat_r.
  trivial.
  Qed.

  Lemma join_l x y : y ≤ x → x ⊔ y = x.
  Proof.
  intros E. apply (antisymmetry (≤)).
  - apply join_lub;trivial. apply reflexivity.
  - apply join_ub_l.
  Qed.

  Lemma join_r x y : x ≤ y → x ⊔ y = y.
  Proof.
  intros E. rewrite (commutativity (f:=join)).
  apply join_l.
  trivial.
  Qed.

  Lemma join_sl_le_spec x y : x ≤ y ↔ x ⊔ y = y.
  Proof.
  split; intros E.
  - apply join_r. trivial.
  - rewrite <-E. apply join_ub_l.
  Qed.

  Global Instance: ∀ z, OrderPreserving (z ⊔).
  Proof.
  intros. repeat (split; try apply _). intros.
  apply join_lub.
  - apply join_ub_l.
  - apply join_le_compat_l. trivial.
  Qed.

  Global Instance: ∀ z, OrderPreserving (⊔ z).
  Proof.
  intros. apply maps.order_preserving_flip.
  Qed.

  Lemma join_le_compat x₁ x₂ y₁ y₂ : x₁ ≤ x₂ → y₁ ≤ y₂ → x₁ ⊔ y₁ ≤ x₂ ⊔ y₂.
  Proof.
  intros E1 E2. transitivity (x₁ ⊔ y₂).
  - apply (order_preserving (x₁ ⊔)). trivial.
  - apply (order_preserving (⊔ y₂));trivial.
  Qed.

  Lemma join_le x y z : x ≤ z → y ≤ z → x ⊔ y ≤ z.
  Proof.
  intros. rewrite <-(idempotency (⊔) z).
  apply join_le_compat;trivial.
  Qed.
End join_semilattice_order.

Section bounded_join_semilattice.
  Context `{JoinSemiLatticeOrder L} `{Bottom L} `{!BoundedJoinSemiLattice L}.

  Lemma above_bottom x : ⊥ ≤ x.
  Proof.
  apply join_sl_le_spec.
  rewrite left_identity.
  reflexivity.
  Qed.

  Lemma below_bottom x : x ≤ ⊥ → x = ⊥.
  Proof.
  intros E.
  apply join_sl_le_spec in E. rewrite right_identity in E.
  trivial.
  Qed.
End bounded_join_semilattice.

Section meet_semilattice_order.
  Context `{MeetSemiLatticeOrder L}.

  Lemma meet_lb_3_r x y z : x ⊓ y ⊓ z ≤ z.
  Proof.
  apply meet_lb_r.
  Qed.

  Lemma meet_lb_3_m x y z : x ⊓ y ⊓ z ≤ y.
  Proof.
  transitivity (x ⊓ y).
  - apply meet_lb_l.
  - apply meet_lb_r.
  Qed.

  Lemma meet_lb_3_l x y z : x ⊓ y ⊓ z ≤ x.
  Proof.
  transitivity (x ⊓ y); apply meet_lb_l.
  Qed.

  Lemma meet_lb_3_assoc_l x y z : x ⊓ (y ⊓ z) ≤ x.
  Proof.
  apply meet_lb_l.
  Qed.

  Lemma meet_lb_3_assoc_m x y z : x ⊓ (y ⊓ z) ≤ y.
  Proof.
  transitivity (y ⊓ z).
  - apply meet_lb_r.
  - apply meet_lb_l.
  Qed.

  Lemma meet_lb_3_assoc_r x y z : x ⊓ (y ⊓ z) ≤ z.
  Proof.
  transitivity (y ⊓ z); apply meet_lb_r.
  Qed.

  Instance meet_sl_order_meet_sl: MeetSemiLattice L.
  Proof.
  repeat split.
  - apply _.
  - intros x y z. apply (antisymmetry (≤)).
    + apply meet_glb.
      * apply meet_glb.
        ** apply meet_lb_3_assoc_l.
        ** apply meet_lb_3_assoc_m.
      * apply meet_lb_3_assoc_r.
    + apply meet_glb.
      ** apply meet_lb_3_l.
      ** apply meet_glb.
         *** apply meet_lb_3_m.
         *** apply meet_lb_3_r.
  - intros x y. apply (antisymmetry (≤)); apply meet_glb;
    first [apply meet_lb_l | try apply meet_lb_r].
  - intros x. red. apply (antisymmetry (≤)).
    + apply meet_lb_l.
    + apply meet_glb;apply reflexivity.
  Qed.

  Lemma meet_le_compat_r x y z : x ≤ z → x ⊓ y ≤ z.
  Proof.
  intros E. transitivity x.
  - apply meet_lb_l.
  - trivial.
  Qed.

  Lemma meet_le_compat_l x y z : y ≤ z → x ⊓ y ≤ z.
  Proof.
  intros E. rewrite (commutativity (f:=meet)).
  apply meet_le_compat_r.
  trivial.
  Qed.

  Lemma meet_l x y : x ≤ y → x ⊓ y = x.
  Proof.
  intros E. apply (antisymmetry (≤)).
  - apply meet_lb_l.
  - apply meet_glb; trivial. apply reflexivity.
  Qed.

  Lemma meet_r x y : y ≤ x → x ⊓ y = y.
  Proof.
  intros E. rewrite (commutativity (f:=meet)). apply meet_l.
  trivial.
  Qed.

  Lemma meet_sl_le_spec x y : x ≤ y ↔ x ⊓ y = x.
  Proof.
  split; intros E.
  - apply meet_l;trivial.
  - rewrite <-E. apply meet_lb_r.
  Qed.

  Global Instance: ∀ z, OrderPreserving (z ⊓).
  Proof.
  intros. repeat (split; try apply _). intros.
  apply meet_glb.
  - apply meet_lb_l.
  - apply  meet_le_compat_l. trivial.
  Qed.

  Global Instance: ∀ z, OrderPreserving (⊓ z).
  Proof.
  intros. apply maps.order_preserving_flip.
  Qed.

  Lemma meet_le_compat x₁ x₂ y₁ y₂ : x₁ ≤ x₂ → y₁ ≤ y₂ → x₁ ⊓ y₁ ≤ x₂ ⊓ y₂.
  Proof.
  intros E1 E2. transitivity (x₁ ⊓ y₂).
  - apply (order_preserving (x₁ ⊓)). trivial.
  - apply (order_preserving (⊓ y₂)). trivial.
  Qed.

  Lemma meet_le x y z : z ≤ x → z ≤ y → z ≤ x ⊓ y.
  Proof.
  intros. rewrite <-(idempotency (⊓) z). apply meet_le_compat;trivial.
  Qed.
End meet_semilattice_order.

Section lattice_order.
  Context `{LatticeOrder L}.

  Instance: JoinSemiLattice L := join_sl_order_join_sl.
  Instance: MeetSemiLattice L := meet_sl_order_meet_sl.

  Instance: Absorption (⊓) (⊔).
  Proof.
  intros x y. apply (antisymmetry (≤)).
  - apply meet_lb_l.
  - apply meet_le.
   + apply reflexivity.
   + apply join_ub_l.
  Qed.

  Instance: Absorption (⊔) (⊓).
  Proof.
  intros x y. apply (antisymmetry (≤)).
  - apply join_le.
    + apply reflexivity.
    + apply meet_lb_l.
  - apply join_ub_l.
  Qed.

  Instance lattice_order_lattice: Lattice L := {}.

  Lemma meet_join_distr_l_le x y z : (x ⊓ y) ⊔ (x ⊓ z) ≤ x ⊓ (y ⊔ z).
  Proof.
  apply meet_le.
  - apply join_le; apply meet_lb_l.
  - apply join_le.
    + transitivity y.
      * apply meet_lb_r.
      * apply join_ub_l.
    + transitivity z.
      * apply meet_lb_r.
      * apply join_ub_r.
  Qed.

  Lemma join_meet_distr_l_le x y z : x ⊔ (y ⊓ z) ≤ (x ⊔ y) ⊓ (x ⊔ z).
  Proof.
  apply meet_le.
  - apply join_le.
    + apply join_ub_l.
    + transitivity y.
      * apply meet_lb_l.
      * apply join_ub_r.
  - apply join_le.
    + apply join_ub_l.
    + transitivity z.
      * apply meet_lb_r.
      * apply join_ub_r.
  Qed.
End lattice_order.

Definition default_join_sl_le `{JoinSemiLattice L} : Le L :=  λ x y, x ⊔ y = y.

Section join_sl_order_alt.
  Context `{JoinSemiLattice L} `{Le L} (le_correct : ∀ x y, x ≤ y ↔ x ⊔ y = y).

  Lemma alt_Build_JoinSemiLatticeOrder : JoinSemiLatticeOrder (≤).
  Proof.
  repeat split.
  - apply _.
  - intros x.
    apply le_correct. apply binary_idempotent.
  - intros x y z E1 E2.
    apply le_correct in E1;apply le_correct in E2;apply le_correct.
    rewrite <-E2, simple_associativity, E1. reflexivity.
  - intros x y E1 E2.
    apply le_correct in E1;apply le_correct in E2.
    rewrite <-E1, (commutativity (f:=join)).
    apply symmetry;trivial.
  - intros. apply le_correct.
    rewrite simple_associativity,binary_idempotent.
    reflexivity.
  - intros;apply le_correct.
    rewrite (commutativity (f:=join)).
    rewrite <-simple_associativity.
    rewrite (idempotency _ _).
    reflexivity.
  - intros x y z E1 E2.
    apply le_correct in E1;apply le_correct in E2;apply le_correct.
    rewrite <-simple_associativity, E2. trivial.
  Qed.
End join_sl_order_alt.

Definition default_meet_sl_le `{MeetSemiLattice L} : Le L :=  λ x y, x ⊓ y = x.

Section meet_sl_order_alt.
  Context `{MeetSemiLattice L} `{Le L} (le_correct : ∀ x y, x ≤ y ↔ x ⊓ y = x).

  Lemma alt_Build_MeetSemiLatticeOrder : MeetSemiLatticeOrder (≤).
  Proof.
  repeat split.
  - apply _.
  - intros ?. apply le_correct. apply (idempotency _ _).
  - intros ? ? ? E1 E2.
    apply le_correct in E1;apply le_correct in E2;apply le_correct.
    rewrite <-E1, <-simple_associativity, E2.
    reflexivity.
  - intros ? ? E1 E2.
    apply le_correct in E1;apply le_correct in E2.
    rewrite <-E2, (commutativity (f:=meet)).
    apply symmetry,E1.
  - intros ? ?. apply le_correct.
    rewrite (commutativity (f:=meet)), simple_associativity, (idempotency _ _).
    reflexivity.
  - intros ? ?. apply le_correct.
    rewrite <-simple_associativity, (idempotency _ _).
    reflexivity.
  - intros ? ? ? E1 E2.
    apply le_correct in E1;apply le_correct in E2;apply le_correct.
    rewrite associativity, E1.
    trivial.
  Qed.
End meet_sl_order_alt.

Section join_order_preserving.
  Context `{JoinSemiLatticeOrder L} `{JoinSemiLatticeOrder K} (f : L → K)
    `{!JoinSemiLattice_Morphism f}.

  Local Existing Instance join_sl_order_join_sl.

  Lemma join_sl_mor_preserving: OrderPreserving f.
  Proof.
  repeat (split; try apply _).
  intros x y E.
  apply join_sl_le_spec in E. apply join_sl_le_spec.
  rewrite <-preserves_join.
  apply ap, E.
  Qed.

  Lemma join_sl_mor_reflecting `{!Injective f}: OrderReflecting f.
  Proof.
  repeat (split; try apply _).
  intros x y E.
  apply join_sl_le_spec in E. apply join_sl_le_spec.
  rewrite <-preserves_join in E.
  apply (injective f). assumption.
  Qed.
End join_order_preserving.

Section meet_order_preserving.
  Context `{MeetSemiLatticeOrder L} `{MeetSemiLatticeOrder K} (f : L → K)
    `{!MeetSemiLattice_Morphism f}.

  Local Existing Instance meet_sl_order_meet_sl.

  Lemma meet_sl_mor_preserving: OrderPreserving f.
  Proof.
  repeat (split; try apply _).
  intros x y E.
  apply meet_sl_le_spec in E. apply meet_sl_le_spec.
  rewrite <-preserves_meet.
  apply ap, E.
  Qed.

  Lemma meet_sl_mor_reflecting `{!Injective f}: OrderReflecting f.
  Proof.
  repeat (split; try apply _).
  intros x y E.
  apply meet_sl_le_spec in E. apply meet_sl_le_spec.
  rewrite <-preserves_meet in E.
  apply (injective f). assumption.
  Qed.
End meet_order_preserving.

Section order_preserving_join_sl_mor.
  Context `{JoinSemiLatticeOrder L} `{JoinSemiLatticeOrder K}
    `{!TotalOrder (_ : Le L)} `{!TotalOrder (_ : Le K)} `{!OrderPreserving (f : L → K)}.

  Local Existing Instance join_sl_order_join_sl.

  Lemma order_preserving_join_sl_mor: JoinSemiLattice_Morphism f.
  Proof.
  repeat (split; try apply _).
  intros x y. case (total (≤) x y); intros E.
  - change (f (join x y) = join (f x) (f y)).
    rewrite (join_r _ _ E),join_r;trivial.
    apply (order_preserving _). trivial.
  - change (f (join x y) = join (f x) (f y)).
    rewrite 2!join_l; trivial. apply (order_preserving _). trivial.
  Qed.
End order_preserving_join_sl_mor.

Section order_preserving_meet_sl_mor.
  Context `{MeetSemiLatticeOrder L} `{MeetSemiLatticeOrder K}
    `{!TotalOrder (_ : Le L)} `{!TotalOrder (_ : Le K)} `{!OrderPreserving (f : L → K)}.

  Local Existing Instance meet_sl_order_meet_sl.

  Lemma order_preserving_meet_sl_mor: SemiGroup_Morphism f.
  Proof.
  repeat (split; try apply _).
  intros x y. case (total (≤) x y); intros E.
  - change (f (meet x y) = meet (f x) (f y)).
    rewrite 2!meet_l;trivial.
    apply (order_preserving _). trivial.
  - change (f (meet x y) = meet (f x) (f y)).
    rewrite 2!meet_r; trivial.
    apply (order_preserving _). trivial.
  Qed.
End order_preserving_meet_sl_mor.
