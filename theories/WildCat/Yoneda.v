Require Export Basics.
Require Export WildCat.Core.
Require Export WildCat.Equiv.
Require Export WildCat.Type.
Require Export WildCat.Opposite.
Require Export WildCat.FunctorCat.

(** ** The covariant Yoneda lemma *)

(** This is easier than the contravariant version because it doesn't involve any "op"s. *)

Definition opyon {A : Type} `{Is0Coh1Cat A} (a : A) : A -> Type
  := fun b => (a $-> b).

Global Instance is0coh1functor_opyon {A : Type} `{Is0Coh1Cat A} (a : A)
  : Is0Coh1Functor (opyon a).
Proof.
  apply Build_Is0Coh1Functor.
  unfold opyon; intros b c f g; cbn in *.
  exact (f $o g).
Defined.

Definition opyoneda {A : Type} `{Is0Coh1Cat A} (a : A)
           (F : A -> Type) {ff : Is0Coh1Functor F}
  : F a -> (opyon a $=> F).
Proof.
  intros x b f.
  exact (fmap F f x).
Defined.

Definition un_opyoneda {A : Type} `{Is0Coh1Cat A}
  (a : A) (F : A -> Type) {ff : Is0Coh1Functor F}
  : (opyon a $=> F) -> F a
  := fun alpha => alpha a (Id a).

Global Instance is1natural_opyoneda {A : Type} `{Is0Coh2Cat A}
  (a : A) (F : A -> Type) {ff : Is0Coh1Functor F} {ff1 : Is1Coh1Functor F} (x : F a)
  : Is1Natural (opyon a) F (opyoneda a F x).
Proof.
  apply Build_Is1Natural.
  unfold opyon, opyoneda; intros b c f g; cbn in *.
  exact (fmap_comp F g f x).
Defined.

Definition opyoneda_issect {A : Type} `{Is0Coh2Cat A} (a : A)
           (F : A -> Type) {ff : Is0Coh1Functor F} {ff1 : Is1Coh1Functor F}
           (x : F a)
  : un_opyoneda a F (opyoneda a F x) = x
  := fmap_id F a x.

(** We assume for the converse that the coherences in [A] are equalities (this is a weak funext-type assumption).  Note that we do not in general recover the witness of 1-naturality.  Indeed, if [A] is fully coherent, then a transformation of the form [yoneda a F x] is always also fully coherently natural, so an incoherent witness of 1-naturality could not be recovered in this way.  *)
Definition opyoneda_isretr {A : Type} `{Is1Coh1Cat_Strong A} (a : A)
           (F : A -> Type) {ff : Is0Coh1Functor F} {ff1 : Is1Coh1Functor F}
           (alpha : opyon a $=> F) {alnat : Is1Natural (opyon a) F alpha}
           (b : A)
  : opyoneda a F (un_opyoneda a F alpha) b $== alpha b.
Proof.
  unfold opyoneda, un_opyoneda, opyon; intros f.
  refine ((isnat alpha f (Id a))^ @ _).
  cbn.
  apply ap.
  exact (cat_idr_strong a _ f).
Defined.

(** Specialization to "full-faithfulness" of the Yoneda embedding.  (In quotes because, again, incoherence means we can't recover the witness of naturality.)  *)
Definition opyon_cancel {A : Type} `{Is0Coh1Cat A} (a b : A)
  : (opyon a $=> opyon b) -> (b $-> a)
  := un_opyoneda a (opyon b).

Definition opyon1 {A : Type} `{Is0Coh1Cat A} (a : A) : Fun1 A Type
  := (opyon a ; is0coh1functor_opyon a).

(** We can also deduce "full-faithfulness" on equivalences. *)
Definition opyon_equiv {A : Type} `{Is1Coh1Cat_Strong A}
           {eA : HasEquivs A} (a b : A)
  : (opyon1 a $<~> opyon1 b) -> (b $<~> a).
Proof.
  intros f.
  refine (cate_adjointify (f.1 a (Id a)) (f^-1$.1 b (Id b)) _ _) ;
    apply GpdHom_path; pose proof (f.2); pose proof (f^-1$.2); cbn in *.
  - refine ((isnat (fun a => (f.1 a)^-1) (f.1 a (Id a)) (Id b))^ @ _); cbn.
    refine (_ @ cate_issect (f.1 a) (Id a)); cbn.
    apply ap.
    serapply cat_idr_strong.
  - refine ((isnat f.1 (f^-1$.1 b (Id b)) (Id a))^ @ _); cbn.
    refine (_ @ cate_isretr (f.1 b) (Id b)); cbn.
    apply ap.
    serapply cat_idr_strong.
Defined.

(** ** The contravariant Yoneda lemma *)

(** We can deduce this from the covariant version with some boilerplate. *)

Definition yon {A : Type} `{Is0Coh1Cat A} (a : A) : A^op -> Type
  := @opyon (A^op) _ a.

Global Instance is0coh1functor_yon {A : Type} `{Is0Coh1Cat A} (a : A)
  : Is0Coh1Functor (yon a)
  := @is0coh1functor_opyon A _ a.

Definition yoneda {A : Type} `{Is0Coh1Cat A} (a : A)
           (F : A^op -> Type) {ff : Is0Coh1Functor F}
  : F a -> (yon a $=> F)
  := @opyoneda (A^op) _ a F _.

Definition un_yoneda {A : Type} `{Is0Coh1Cat A} (a : A)
           (F : A^op -> Type) {ff : Is0Coh1Functor F}
  : (yon a $=> F) -> F a
  := @un_opyoneda (A^op) _ a F _.

Global Instance is1natural_yoneda {A : Type} `{Is0Coh2Cat A} (a : A)
       (F : A^op -> Type) {ff : Is0Coh1Functor F} {ff1 : Is1Coh1Functor F} (x : F a)
  : Is1Natural (yon a) F (yoneda a F x)
  := @is1natural_opyoneda (A^op) _ _ a F _ _ x.

Definition yoneda_issect {A : Type} `{Is0Coh2Cat A} (a : A) (F : A^op -> Type) {ff : Is0Coh1Functor F} {ff1 : Is1Coh1Functor F} (x : F a)
  : un_yoneda a F (yoneda a F x) = x
  := @opyoneda_issect (A^op) _ _ a F _ _ x.


Definition yoneda_isretr {A : Type}
           `{Is1Coh1Cat_Strong A} {ac2 : Is0Coh2Cat A} (a : A)
           (F : A^op -> Type) {ff : Is0Coh1Functor F} {ff1 : Is1Coh1Functor F}
           (alpha : yon a $=> F) {alnat : Is1Natural (yon a) F alpha}
           (b : A)
  : yoneda a F (un_yoneda a F alpha) b $== alpha b
  := @opyoneda_isretr A^op _ _ _ a F _ _ alpha alnat b.

Definition yon_cancel {A : Type} `{Is0Coh1Cat A} (a b : A)
  : (yon a $=> yon b) -> (a $-> b)
  := un_yoneda a (yon b).

Definition yon1 {A : Type} `{Is0Coh1Cat A} (a : A) : Fun1 A^op Type
  := opyon1 a.

(* TODO: update *)
(*
Definition yon_equiv {A : Type} `{Is1Coh1Cat_Strong A}
  {eA : HasEquivs A} (a b : A)
  : (yon1 a $<~> yon1 b) -> (a $<~> b)
  := (@opyon_equiv A^op _ _ _ _ a b).
*)