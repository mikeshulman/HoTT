(* -*- mode: coq; mode: visual-line -*-  *)

Require Import Basics.
Require Import WildCat.Core.
Require Import WildCat.Equiv.

(** ** Wild functor categories *)

Definition Fun1 (A B : Type) `{Is0Coh1Cat A} `{Is0Coh1Cat B}
  := { F : A -> B & Is0Coh1Functor F }.

Definition NatTrans {A B : Type} `{Is0Coh1Cat A} `{Is0Coh2Cat B} (F G : A -> B)
           {ff : Is0Coh1Functor F} {fg : Is0Coh1Functor G}
  := { alpha : F $=> G & Is1Natural F G alpha }.

(** Note that even if [A] and [B] are fully coherent oo-categories, the objects of our "functor category" are not fully coherent.  Thus we cannot in general expect this "functor category" to itself be fully coherent.  However, it is at least a 0-coherent 1-category, as long as [B] is a 1-coherent 1-category. *)

Global Instance is0coh1cat_fun (A B : Type) `{Is0Coh1Cat A} `{Is1Coh1Cat B} : Is0Coh1Cat (Fun1 A B).
Proof.
  srapply Build_Is0Coh1Cat.
  - intros [F ?] [G ?].
    exact (NatTrans F G).
  - intros [F ?]; cbn.
    exists (fun a => Id (F a)); apply Build_Is1Natural; intros a b f; cbn.
    refine (cat_idl (fmap F f) $@ (cat_idr (fmap F f))^$).
  - intros [F ?] [G ?] [K ?] [gamma ?] [alpha ?]; cbn in *.
    exists (fun a => gamma a $o alpha a).
    apply Build_Is1Natural; intros a b f; cbn.
    refine (cat_assoc _ _ _ $@ _).
    refine ((gamma b $@L isnat alpha f) $@ _).
    refine (cat_assoc_opp _ _ _ $@ _).
    refine ((isnat gamma f) $@R alpha a $@ _).
    exact (cat_assoc _ _ _).
Defined.

(** In fact, in this case it is automatically also a 0-coherent 2-category and a 1-coherent 1-category, with a totally incoherent notion of 2-cell between 1-coherent natural transformations. *)

Global Instance is0coh2cat_fun (A B : Type) `{Is0Coh1Cat A} `{Is1Coh1Cat B} : Is0Coh2Cat (Fun1 A B).
Proof.
  srapply Build_Is0Coh2Cat.
  - intros [F ?] [G ?]; serapply Build_Is0Coh1Cat.
    + intros [alpha ?] [gamma ?].
      exact (forall a, alpha a $== gamma a).
    + intros [alpha ?] a; cbn.
      reflexivity.
    + intros [alpha ?] [gamma ?] [phi ?] nu mu a.
      exact (mu a $@ nu a).
  - intros [F ?] [G ?]; serapply Build_Is0Coh1Gpd.
    intros [alpha ?] [gamma ?] mu a.
    exact ((mu a)^$).
  - intros [F ?] [G ?] [K ?].
    serapply Build_Is0Coh1Functor.
    intros [[alpha ?] [gamma ?]] [[phi ?] [mu ?]] [f g] a.
    exact (f a $o@ g a).
Defined.

Global Instance is1coh1cat_fun (A B : Type) `{Is0Coh1Cat A} `{Is1Coh1Cat B} : Is1Coh1Cat (Fun1 A B).
Proof.
  srapply Build_Is1Coh1Cat'.
  1,2:intros [F ?] [G ?] [K ?] [L ?] [alpha ?] [gamma ?] [phi ?] a; cbn.
  3,4:intros [F ?] [G ?] [alpha ?] a; cbn.
  5:intros [F ?] a; cbn.
  - serapply cat_assoc.
  - serapply cat_assoc_opp.
  - serapply cat_idl.
  - serapply cat_idr.
  - serapply cat_idlr.
Defined.

(** It also inherits a notion of equivalence, namely a natural transformation that is a pointwise equivalence.  Note that this is not a "fully coherent" notion of equivalence, since the functors and transformations are not themselves fully coherent. *)

Definition NatEquiv {A B : Type} `{Is0Coh1Cat A} `{HasEquivs B} (F G : A -> B) {ff : Is0Coh1Functor F} {fg : Is0Coh1Functor G}
  := { alpha : forall a, F a $<~> G a & Is1Natural F G (fun a => alpha a) }.

Global Instance hasequivs_fun (A B : Type) `{Is1Coh1Cat A} `{Is1Coh1Cat B}
  {eB : HasEquivs B} : HasEquivs (Fun1 A B).
Proof.
  srapply Build_HasEquivs.
  1:{ intros [F ?] [G ?]. exact (NatEquiv F G). }
  1:{ intros [F ?] [G ?] [alpha ?]; cbn in *.
      exact (forall a, CatIsEquiv (alpha a)). }
  all:intros [F ?] [G ?] [alpha alnat]; cbn in *.
  - exists (fun a => alpha a); assumption.
  - intros a; exact _.
  - intros ?; srefine (_;_).
    + intros a; exact (Build_CatEquiv (alpha a)).
    + cbn. refine (is1natural_homotopic alpha _).
      intros a; apply cate_buildequiv_fun.
  - cbn; intros; apply cate_buildequiv_fun.
  - intros ?; exists (fun a => (alpha a)^-1$).
    apply Build_Is1Natural; intros a b f.
    refine ((cat_idr _)^$ $@ _).
    refine ((_ $@L (cate_isretr (alpha a))^$) $@ _).
    refine (cat_assoc _ _ _ $@ _).
    refine ((_ $@L (cat_assoc_opp _ _ _)) $@ _).
    refine ((_ $@L ((isnat (fun a => alpha a) f)^$ $@R _)) $@ _).
    refine ((_ $@L (cat_assoc _ _ _)) $@ _).
    refine (cat_assoc_opp _ _ _ $@ _).
    refine ((cate_issect (alpha b) $@R _) $@ _).
    exact (cat_idl _).
  - intros; apply cate_issect.
  - intros; apply cate_isretr.
  - intros [gamma ?] r s a; cbn in *.
    refine (catie_adjointify (alpha a) (gamma a) (r a) (s a)).
Defined.