(* The MIT License (MIT)

   Copyright (c) 2014 Nicolas Ojeda Bar <n.oje.bar@gmail.com>

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in
   all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE. *)

type num = Uint32.t

type t = (num * num) list

let empty =
  []

let all =
  [(Uint32.one, Uint32.max_int)]

let single n =
  [(n, n)]

let single_int n =
  single (Uint32.of_int n)

let interval n m =
  if Uint32.compare n m <= 0 then
    [(n, m)]
  else
    [(m, n)]

let from n =
  [(n, Uint32.max_int)]

let add n set =
  (n, n) :: set

(* let compare_elt x y = *)
(*   if N.compare N.zero x = 0 then *)
(*     if N.compare N.zero y = 0 then *)
(*       0 *)
(*     else *)
(*       1 *)
(*   else if N.compare N.zero y = 0 then *)
(*     -1 *)
(*   else *)
(*     N.compare x y *)

let add_interval n m set =
  if Uint32.compare n m <= 0 then
    (n, m) :: set
  else
    (m, n) :: set

let union s1 s2 =
  List.fold_right (fun r s2 -> r :: s2) s1 s2

let of_list l = (* FIXME find ranges of contiguous messages *)
  let l = List.sort compare l in
  let rec loop start finish =
    function
      [] ->
        [(start, finish)]
    | n :: rest ->
        if Uint32.(compare (add finish one) n = 0) then
          loop start n rest
        else
          (start, finish) :: loop n n rest
  in
  match l with
    [] -> []
  | x :: rest -> loop x x rest

let rec iter2 f s1 s2 =
  match s1, s2 with
    [], [] -> ()
  | (l1, r1) :: s1, (l2, r2) :: s2 ->
      let rec loop l1 l2 =
        if Uint32.compare l1 r1 > 0 then
          if Uint32.compare l2 r2 > 0 then
            iter2 f s1 s2
          else
            iter2 f s1 ((l2, r2) :: s2)
        else if Uint32.compare l2 r2 > 0 then
          iter2 f ((l1, r1) :: s1) s2
        else begin
          f l1 l2;
          loop (Uint32.succ l1) (Uint32.succ l2)
        end
      in
      loop l1 l2
  | _ ->
      invalid_arg "ImapSet.iter2"

(* let rec iter f = function *)
(*   | [] -> () *)
(*   | (l, r) :: set -> *)
(*       if N.compare N.zero r = 0 then failwith "ImapSet.iter"; *)
(*       let rec loop l = *)
(*         if N.compare l r > 0 then *)
(*           iter f set *)
(*         else *)
(*           begin *)
(*             f l; *)
(*             loop (N.succ l) *)
(*           end *)
(*       in *)
(*       loop l *)

(* let rec iter2 f s1 s2 = *)
(*   match s1, s2 with *)
(*   | [], [] -> () *)
(*   | (l1, r1) :: s1, (l2, r2) :: s2 -> *)
(*       if N.compare r1 N.zero = 0 || N.compare r2 N.zero = 0 then *)
(*         failwith "ImapSet.iter2"; *)
(*       let rec loop l1 l2 = *)
(*         if N.compare l1 r1 > 0 then *)
(*           if N.compare l2 r2 > 0 then *)
(*             iter2 f s1 s2 *)
(*           else *)
(*             iter2 f s1 ((l2, r2) :: s2) *)
(*         else *)
(*         if N.compare l2 r2 > 0 then *)
(*           iter2 f ((l1, r1) :: s1) s2 *)
(*         else begin *)
(*           f l1 l2; *)
(*           loop (N.succ l1) (N.succ l2) *)
(*         end *)
(*       in *)
(*       loop l1 l2 *)
(*   | _ -> *)
(*       failwith "ImapSet.iter2" *)

(* let rec fold f s x = *)
(*   let rec loop = *)
(*     function *)
(*       [] -> x *)
(*     | (l, r) :: s -> *)
(*         if N.compare N.zero l = 0 then failwith "ImapSet.fold"; *)
(*         let rec loop l x = *)
(*           if N.compare l r > 0 then *)
(*             fold f s x *)
(*           else *)
(*             loop (N.succ l) (f l x) *)
(*         in *)
(*         loop l x *)
(*   in *)
(*   loop s *)

(* let rec fold_intervals f s x = *)
(*   match s with *)
(*   | [] -> x *)
(*   | r :: s -> *)
(*       fold_intervals f s (f r x) *)

(* let min_elt n m = *)
(*   if compare_elt n m >= 0 then m else n *)

(* let max_elt n m = *)
(*   if compare_elt n m >= 0 then n else m *)

(* let pred_elt n = *)
(*   if Int.compare n Int.zero = 0 then Int.zero *)
(*   else Int.pred n *)

(* let succ_elt n = *)
(*   if Int.compare n Int.zero = 0 then Int.zero *)
(*   else Int.succ n *)

(* let rec merge (n, m) = function *)
(*   |  [] -> [n, m] *)
(*   |  (l, r) :: set -> *)
(*     if compare_elt m (pred_elt l) < 0 then *)
(*       (n, m) :: merge (l, r) set *)
(*     else if compare_elt n (succ_elt r) > 0 then *)
(*       (l, r) :: merge (n, m) set *)
(*     else (\* m >= l-1 && n <= r+1 *\) *)
(*       merge (min_elt n l, max_elt r m) set *)

(* let optimise set = *)
(*   let set = List.sort (fun (n, _) (l, _) -> compare n l) set in *)
(*   match set with *)
(*   | [] -> [] *)
(*   | (n, m) :: set -> *)
(*     merge (n, m) set *)
