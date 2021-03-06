(* Dan Grossman, Coursera PL, HW2 Provided Code *)

(* if you use this function to compare two strings (returns true if the same
   string), then you avoid several of the functions in problem 1 having
   polymorphic types that may be confusing *)
fun same_string(s1 : string, s2 : string) =
    s1 = s2
		       


fun all_except_option (str, strs) =
    case strs of
	[] => NONE
     | x::xs => case same_string(str, x) of
		true => SOME xs
	      | false => case all_except_option(str, xs) of
			     NONE => NONE
			   | SOME y => SOME(x::y)


					   
fun get_substitutions1 (sub, s) =
    case sub of
	[] => []
      | x::xs => case all_except_option(s, x) of
		     NONE => get_substitutions1(xs, s)
		   | SOME y => y @ get_substitutions1(xs,s)

fun get_substitutions2 (sub, s) =
    let fun aux (sub, acc) =
	    case sub of
		[] => acc
	      | x::xs => case all_except_option(s, x) of
			     NONE => aux(xs, acc)
			   | SOME y => aux(xs, acc @ y)
    in
	aux(sub, [])
    end


type name = {first: string, middle: string, last: string}

fun similar_names (sub, name) =
    let val {first = f, middle = m, last = l} = name
	fun aux (sub, acc) =
	    case sub of
		[] => acc
	      | x::xs => aux(xs, acc @ [{first = x, middle = m, last = l}])
    in
	aux(get_substitutions2(sub, f), [name])
    end

	
(* you may assume that Num is always used with values 2, 3, ..., 10
   though it will not really come up *)
datatype suit = Clubs | Diamonds | Hearts | Spades
datatype rank = Jack | Queen | King | Ace | Num of int 
type card = suit * rank

datatype color = Red | Black
datatype move = Discard of card | Draw 

exception IllegalMove

fun card_color card =
    case card of
        (Clubs,_)    => Black
      | (Diamonds,_) => Red
      | (Hearts,_)   => Red
      | (Spades,_)   => Black


fun card_value card =
    case card of
	(_,Jack) => 10
      | (_,Queen) => 10
      | (_,King) => 10
      | (_,Ace) => 11 
      | (_,Num n) => n
		   

fun remove_card (cs, c, e) =
    case cs of
	[] => raise e
      | x::xs => case x = c of
		     true => xs
		   | false => case remove_card(xs, c, e) of
				  [] => [x]
				| y::ys => x::y::ys


fun all_same_color (cards) = 
    case cards of
	[] => true
      | x::[] => true
      | x::y::xs => case card_color(x) = card_color(y) of
			   false => false
			 | true => all_same_color(y::xs)


fun sum_cards (cards) =
    let fun aux (cards, acc) =
	    case cards of
		[] => acc
	      | x::xs => aux(xs, acc + card_value(x)) 
    in
	aux(cards, 0)
    end
	

fun score (held, goal) =
    let val sum = sum_cards(held)
	fun game (held) =
	    case sum > goal of
		 true => (sum - goal) * 3
               | false => goal - sum 
    in
	case all_same_color(held) of
	    true => game(held) div 2
	  | false => game(held) 	    
    end



fun officiate (cards, move, goal) =
    let fun game (cards, move, held) =
	case move of
	    [] => held
	  | x::xs => case x of
			 Discard card => game(cards, xs, remove_card(held, card, IllegalMove))
		       | Draw => case cards of
				     [] => held
				   | y::_ => case sum_cards(y::held) > goal of
                                                 true => y::held
                                               | false => game(remove_card(cards, y, IllegalMove), xs, y::held)   
    in
	score(game(cards, move, []), goal)
    end



		
