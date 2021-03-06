(*
   Rlc: GAMEEXE.INI lexer
   Copyright (C) 2006 Haeleth
   Revised 2009-2011 by Richard 23

   This program is free software; you can redistribute it and/or modify it under
   the terms of the GNU General Public License as published by the Free Software
   Foundation; either version 2 of the License, or (at your option) any later
   version.

   This program is distributed in the hope that it will be useful, but WITHOUT
   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
   FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
   details.

   You should have received a copy of the GNU General Public License along with
   this program; if not, write to the Free Software Foundation, Inc., 59 Temple
   Place - Suite 330, Boston, MA  02111-1307, USA.
*)

{
  open IniParser
  open Lexing
  open ExtString

  let make_id =
    function
      | "SHAKE" | "SHAKEZOOM" as shk -> SHAKE shk
      | "DSTRACK" -> DSTRACK
      | "CDTRACK" -> CDTRACK
      | "NAMAE" -> NAMAE
      | id -> IDENT id
}

let nm = '-'? ['0'-'9']+
let id = ['A'-'Z' '_' '0'-'9' '[' ']']+
let comment = ';' [^ '\n']*
let space   = [' ' '\t']+
let string  = '\"' [^ '\"']* '\"'

rule lex =
  parse
    | eof    { EOF }
    | comment
    | space  { lex lexbuf }
    | '\r'? '\n' { incr Ini.curr_line; lex lexbuf }
    | "="    { Eq }
    | ","    { Cm }
    | ":"    { Co }
    | "("    { Lp }
    | ")"    { Rp }
    | "-"    { Hy }
    | "."    { Dot }
    | "#"    { Hash }
    | "U"    { UN true }
    | "N"    { UN false }
    |     nm { INT (Int32.of_string (lexeme lexbuf)) }
    | "." nm { DOTINT (int_of_string (String.lchop (lexeme lexbuf))) }
    |     id { make_id (lexeme lexbuf) }
    | "." id { DOTIDENT (String.lchop (lexeme lexbuf)) }
    | string { STRING (String.slice (lexeme lexbuf) ~first:1 ~last:~-1) }
    | _ as c { Printf.kprintf Optpp.sysError ("unexpected character `%c' " 
                ^^ "in GAMEEXE.INI at line %d char %d") c !Ini.curr_line 
                (Lexing.lexeme_start lexbuf) }
