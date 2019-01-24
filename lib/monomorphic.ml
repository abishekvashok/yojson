let rec pp fmt =
  function
  | `Null -> Format.pp_print_string fmt "`Null"
  | `Bool x ->
      (Format.fprintf fmt "`Bool (@[<hov>";
       (Format.fprintf fmt "%B") x;
       Format.fprintf fmt "@])")
#ifdef INT
  | `Int x ->
      (Format.fprintf fmt "`Int (@[<hov>";
       (Format.fprintf fmt "%d") x;
       Format.fprintf fmt "@])")
#endif
#ifdef INTLIT
  | `Intlit x ->
      (Format.fprintf fmt "`Intlit (@[<hov>";
       (Format.fprintf fmt "%S") x;
       Format.fprintf fmt "@])")
#endif
#ifdef FLOAT
  | `Float x ->
      (Format.fprintf fmt "`Float (@[<hov>";
       (Format.fprintf fmt "%F") x;
       Format.fprintf fmt "@])")
#endif
#ifdef FLOATLIT
  | `Floatlit x ->
      (Format.fprintf fmt "`Floatlit (@[<hov>";
       (Format.fprintf fmt "%S") x;
       Format.fprintf fmt "@])")
#endif
#ifdef STRING
  | `String x ->
      (Format.fprintf fmt "`String (@[<hov>";
       (Format.fprintf fmt "%S") x;
       Format.fprintf fmt "@])")
#endif
#ifdef STRINGLIT
  | `Stringlit x ->
      (Format.fprintf fmt "`Stringlit (@[<hov>";
       (Format.fprintf fmt "%S") x;
       Format.fprintf fmt "@])")
#endif
  | `Assoc x ->
      (Format.fprintf fmt "`Assoc (@[<hov>";
       ((fun x ->
           Format.fprintf fmt "@[<2>[";
           ignore
             (List.fold_left
                (fun sep ->
                   fun x ->
                     if sep then Format.fprintf fmt ";@ ";
                     ((fun (a0, a1) ->
                         Format.fprintf fmt "(@[";
                         ((Format.fprintf fmt "%S") a0;
                          Format.fprintf fmt ",@ ";
                          (pp fmt) a1);
                         Format.fprintf fmt "@])")) x;
                     true) false x);
           Format.fprintf fmt "@,]@]")) x;
       Format.fprintf fmt "@])")
  | `List x ->
      (Format.fprintf fmt "`List (@[<hov>";
       ((fun x ->
           Format.fprintf fmt "@[<2>[";
           ignore
             (List.fold_left
                (fun sep ->
                   fun x ->
                     if sep then Format.fprintf fmt ";@ ";
                     (pp fmt) x;
                     true) false x);
           Format.fprintf fmt "@,]@]")) x;
       Format.fprintf fmt "@])")
#ifdef TUPLE
  | `Tuple x ->
      (Format.fprintf fmt "`Tuple (@[<hov>";
       ((fun x ->
           Format.fprintf fmt "@[<2>[";
           ignore
             (List.fold_left
                (fun sep ->
                   fun x ->
                     if sep then Format.fprintf fmt ";@ ";
                     (pp fmt) x;
                     true) false x);
           Format.fprintf fmt "@,]@]")) x;
       Format.fprintf fmt "@])")
#endif
#ifdef VARIANT
  | `Variant x ->
      (Format.fprintf fmt "`Variant (@[<hov>";
       ((fun (a0, a1) ->
           Format.fprintf fmt "(@[";
           ((Format.fprintf fmt "%S") a0;
            Format.fprintf fmt ",@ ";
            ((function
              | None -> Format.pp_print_string fmt "None"
              | Some x ->
                  (Format.pp_print_string fmt "(Some ";
                   (pp fmt) x;
                   Format.pp_print_string fmt ")"))) a1);
           Format.fprintf fmt "@])")) x;
       Format.fprintf fmt "@])")
#endif

let show x =
  Format.asprintf "%a" pp x

let rec equal a b =
  match a, b with
  | `Null, `Null -> true
  | `Bool a, `Bool b -> a = b
#ifdef INT
  | `Int a, `Int b -> a = b
#endif
#ifdef INTLIT
    | `Intlit a, `Intlit b -> a = b
#endif
#ifdef FLOAT
    | `Float a, `Float b -> a = b
#endif
#ifdef FLOATLIT
    | `Floatlit a, `Floatlit b -> a = b
#endif
#ifdef STRING
    | `String a, `String b -> a = b
#endif
#ifdef STRINGLIT
    | `Stringlit a, `Stringlit b -> a = b
#endif
    | `Assoc xs, `Assoc ys ->
      (* determine whether a k exists in assoc that has value v *)
      let rec mem_value k v = function
        | [] -> false
        | (k', v')::xs ->
            match k = k' with
            | false -> mem_value k v xs
            | true ->
              match equal v v' with
              | true -> true
              | false -> mem_value k v xs
      in

      (match List.length xs = List.length ys with
      | false -> false
      | true ->
        List.fold_left (fun acc (k, v) ->
          match acc with
          | false -> false
          | true -> mem_value k v ys) true xs)
#ifdef TUPLE
    | `Tuple xs, `Tuple ys
#endif
    | `List xs, `List ys ->
      (match List.length xs = List.length ys with
      | false -> false
      | true ->
        List.fold_left2 (fun acc x y ->
          match acc with
          | false -> false
          | true -> equal x y) true xs ys)
#ifdef VARIANT
    | `Variant (name, value), `Variant (name', value') ->
      (match name = name' with
      | false -> false
      | true ->
        match value, value' with
        | None, None -> true
        | Some x, Some y -> equal x y
        | _ -> false)
#endif
    | _ -> false
