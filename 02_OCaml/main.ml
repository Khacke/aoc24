exception NoInputFile of string

let get_file_name = 
    let argc = Array.length Sys.argv in

    if argc != 2 then
        raise (NoInputFile "No input file provided `./main <filename>`")
    else
        Sys.argv.(1);;

let read_binary_file filename =
    let ic = open_in_bin filename in
    let len = in_channel_length ic in
    let content = really_input_string ic len in
    close_in ic;
    content

let split_content content = 
    String.split_on_char '\n' content

let split_line line = 
    String.split_on_char ' ' line
    
let safe_int_of_string s =
    try Some (int_of_string s) with
    | Failure _ -> None 

let parse_lines_to_nums lines = 
    List.map ( fun line -> 
        line
        |> split_line
        |> List.filter_map safe_int_of_string 
    ) lines

let is_increasing lst =
    let steps = [1; 2; 3] in
    let rec aux prev = function
        | [] -> true
        | x :: xs ->
            if List.exists (fun step -> x = prev + step) steps then
                aux x xs
            else
                false
    in
    match lst with
    | [] -> false
    | _ :: xs -> aux (List.hd lst) xs 

let is_decreasing lst = 
    let steps = [1; 2; 3] in
    let rec aux prev = function
        | [] -> true
        | x :: xs ->
            if List.exists (fun step -> x = prev - step) steps then
                aux x xs
            else
                false
    in
    match lst with
    | [] -> false
    | _ :: xs -> aux (List.hd lst) xs

let is_line_safe line = 
    is_increasing line || is_decreasing line

let handle_lines lines = 
    List.map is_line_safe lines 

let count_safe res = 
    List.fold_left (fun acc b -> if b then acc + 1 else acc) 0 res

let () =
    get_file_name
    |> read_binary_file
    |> split_content
    |> parse_lines_to_nums
    |> handle_lines
    |> count_safe
    |> Printf.printf "Safe: %d\n" 

