type buffer
type t = buffer

(** Make a blank buffer. *)
val make : int -> t

(** Length in samples. *)
val length : t -> int

val copy : t -> t

val sub : t -> int -> int -> t

val blit : t -> int -> t -> int -> int -> unit

val clear : t -> int -> int -> unit

(** Effects *)

val amplify : float -> t -> int -> int -> unit

val add : t -> int -> t -> int -> int -> unit

val rms : t -> int -> int -> float

val resample : float -> t -> int -> int -> t

(** Conversion *)

val to_s16le : t array -> string

val of_u8 : string -> int -> int -> ?resample:float -> buffer array -> int -> int

val of_s16le : string -> int -> int -> ?resample:float -> buffer array -> int -> int
