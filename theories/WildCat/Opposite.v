(* -*- mode: coq; mode: visual-line -*-  *)

(* Don't import the old WildCat *)
Require Import Basics.Overture.
Require Import Basics.PathGroupoids.
Require Import Basics.Notations.
Require Import Basics.Contractible.
Require Import Basics.Equivalences.

Require Import WildCat.Core.

(** ** Opposite categories *)

Definition op (A : Type) : Type := A.
Notation "A ^op" := (op A).

(** This stops typeclass search from trying to unfold op. *)
Typeclasses Opaque op.

Global Instance is0coh1cat_op A `{Is0Coh1Cat A} : Is0Coh1Cat (A ^op)
  := Build_Is0Coh1Cat A (fun a b => b $-> a) Id (fun a b c g f => f $o g).

Global Instance is0cat2cat_op A `{Is0Coh2Cat A} : Is0Coh2Cat A^op.
Proof.
  srapply Build_Is0Coh2Cat; unfold op in *; cbn in *.
  1: intros a b f g; exact (f $== g).
  all: cbn.
  - intros a b; apply Id_Htpy.
  - intros a b f g; apply Opp_Htpy.
  - intros a b f g h; apply Concat_Htpy.
  - intros a b c f g h p; exact (p $@R h).
  - intros a b c f g p h; exact (h $@L p).
Defined.

Global Instance is1coh1cat_op A `{Is1Coh1Cat A} : Is1Coh1Cat A^op.
Proof.
  srapply Build_Is1Coh1Cat'; unfold op in *; cbn in *.
  - intros a b c d f g h; exact (cat_assoc_opp h g f).
  - intros a b c d f g h; exact (cat_assoc h g f).
  - intros a b f; exact (cat_idr f).
  - intros a b f; exact (cat_idl f).
  - intros a; exact (cat_idlr a).
Defined.

Global Instance is1coh1cat_strong_op A `{Is1Coh1Cat_Strong A}
  : Is1Coh1Cat_Strong (A ^op).
Proof.
  srapply Build_Is1Coh1Cat_Strong'; unfold op in *; cbn in *.
  - intros a b c d f g h; exact (cat_assoc_opp_strong h g f).
  - intros a b c d f g h; exact (cat_assoc_strong h g f).
  - intros a b f; exact (cat_idr_strong f).
  - intros a b f; exact (cat_idl_strong f).
  - intros a; exact (cat_idlr_strong a).
Defined.

(* Opposites are definitionally involutive. You can test this by uncommenting the stuff below. *)
(*
Definition test1 A {ac : Is0Coh1Cat A} : A = (A^op)^op := 1.
Definition test2 A {ac : Is0Coh1Cat A} : ac = is0coh1cat_op (A^op) := 1.
Definition test3 A {ac : Is0Coh1Cat A} {ac2 : Is0Coh2Cat A} : ac2 = is0coh2cat_op (A^op) := 1.
Definition test4 A {ac : Is0Coh1Cat A} {ac2 : Is0Coh2Cat A} {ac11 : Is1Coh1Cat A} : ac11 = is1coh1cat_op (A^op) := 1.
*)

(* Opposite functors and natural transformations *)

Global Instance is0coh1fun_op  A `{Is0Coh1Cat A} B `{Is0Coh1Cat B} (F : A -> B) {ff : Is0Coh1Functor F} : Is0Coh1Functor (F : A ^op -> B ^op).
Proof.
  apply Build_Is0Coh1Functor.
  unfold op.
  cbn.
  intros a b.
  apply fmap.
  exact ff.
Defined.

Global Instance is0coh2fun_op A B `{Is0Coh2Cat A} `{Is0Coh2Cat B}
       (F : A -> B) {ff : Is0Coh1Functor F} {pf : Is0Coh2Functor F} : Is0Coh2Functor (F : A^op -> B^op).
Proof.
  apply Build_Is0Coh2Functor.
  unfold op in *.
  cbn in *.
  intros a b.
  apply fmap2.
  exact pf.
Defined.

Global Instance is1coh1fun_op A B `{Is0Coh1Cat A} `{Is0Coh1Cat B} `{Is0Coh2Cat B} (F : A -> B) {ff : Is0Coh1Functor F} {pf : Is1Coh1Functor F} : Is1Coh1Functor (F : A^op -> B^op).
Proof.
  apply Build_Is1Coh1Functor; unfold op in *; cbn in *.
  - apply fmap_id.
    exact pf.
  - intros a b c.
    intros f g.
    apply fmap_comp.
    exact pf.
Defined.

Definition transformation_op {A} {B} `{Is0Coh1Cat B} (F : A -> B) (G : A -> B) (alpha : F $--> G) : (@Transformation (A^op) (B^op) (is0coh1cat_op B) (G : (A^op) -> (B^op)) (F : (A^op) -> (B^op))).
Proof.
  unfold op in *.
  cbn in *.
  intro a.
  apply (alpha a).
Defined.

Global Instance is1nat_op A B `{Is0Coh1Cat A} `{Is0Coh2Cat B}
       (F : A -> B) {ff1 : Is0Coh1Functor F} (G : A -> B) {fg1 : Is0Coh1Functor G} (alpha : F $--> G) {pf : Is1Natural F G alpha} : Is1Natural (G : A^op -> B^op) (F : A^op -> B^op) (transformation_op F G alpha).
Proof.
  apply Build_Is1Natural'.
  - unfold op in *.
    unfold transformation_op.
    cbn.
    intros a b f.
    apply isnat_opp.
  - unfold op.
    unfold transformation_op.
    cbn.
    intros a b f.
    apply isnat.
    exact pf.
Defined.

(* Shorter proof of above using Build_Is1Natural. But maybe the longer proof using Build_Is1Natural' is better?

Proof.
  apply Build_Is1Natural.
  unfold op in *.
  cbn in *.
  intros a b.
  unfold transformation_op in *.
  intros f.
  apply isnat_opp.
Defined.
*)
