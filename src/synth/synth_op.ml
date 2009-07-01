(*****************************************************************************

  Liquidsoap, a programmable audio stream generator.
  Copyright 2003-2009 Savonet team

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details, fully stated in the COPYING
  file at the root of the liquidsoap distribution.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

 *****************************************************************************)

open Source

class synth (synth:Synth.synth) (source:source) chan volume =
object (self)
  inherit operator [source] as super

  initializer
    synth#set_volume volume

  method stype = source#stype

  method remaining = source#remaining

  method is_ready =
    source#is_ready

  method abort_track = source#abort_track

  method private get_frame buf =
    let offset = AFrame.position buf in
    let evs = (MFrame.tracks buf).(chan) in
    let evs = !evs in
    source#get buf;
    let b = AFrame.get_float_pcm buf in
    let position = AFrame.position buf in
    let sps = float (Fmt.samples_per_second ()) in
    let rec process evs off =
      match evs with
        | (t,e)::tl ->
            let t = Fmt.samples_of_ticks t in
              synth#synth sps b off (t - off);
              (
                match e with
                  | Midi.Note_on (n, v) -> synth#note_on n v
                  | Midi.Note_off (n, v) -> synth#note_off n v
                  | _ -> ()
              );
              process tl t
        | [] ->
            synth#synth sps b off (position - off)
    in
      process evs offset
end

let register obj name descr =
  Lang.add_operator ("synth." ^ name)
    [
      "channel", Lang.int_t, Some (Lang.int 0), Some "MIDI channel to handle.";
      "volume", Lang.float_t, Some (Lang.float 0.3), Some "Volume.";
      "", Lang.source_t, None, None
    ]
    ~category:Lang.SoundSynthesis
    ~descr
    (fun p _ ->
       let f v = List.assoc v p in
       let chan = Lang.to_int (f "channel") in
       let volume = Lang.to_float (f "volume") in
       let src = Lang.to_source (f "") in
         new synth (obj ()) src chan volume)

let () = register (fun () -> (new Synth.sine :> Synth.synth)) "sine" "Sine synthesiser."
let () = register (fun () -> (new Synth.square :> Synth.synth)) "square" "Square synthesiser."
let () = register (fun () -> (new Synth.saw :> Synth.synth)) "saw" "Saw synthesiser."