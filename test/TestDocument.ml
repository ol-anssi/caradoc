(*****************************************************************************)
(*  Caradoc: a PDF parser and validator                                      *)
(*  Copyright (C) 2015 ANSSI                                                 *)
(*                                                                           *)
(*  This program is free software; you can redistribute it and/or modify     *)
(*  it under the terms of the GNU General Public License version 2 as        *)
(*  published by the Free Software Foundation.                               *)
(*                                                                           *)
(*  This program is distributed in the hope that it will be useful,          *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            *)
(*  GNU General Public License for more details.                             *)
(*                                                                           *)
(*  You should have received a copy of the GNU General Public License along  *)
(*  with this program; if not, write to the Free Software Foundation, Inc.,  *)
(*  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.              *)
(*****************************************************************************)


open OUnit
open Document
open Key
open Errors
open Boundedint
open Pdfobject.PDFObject
open Graph


let make_doc_objs objs =
  let doc = Document.create () in
  List.iter (fun (key, o) ->
      Document.add doc key o
    ) objs;
  doc

let make_doc_trailer objs trailer =
  let doc = make_doc_objs objs in
  Document.add_trailer doc trailer;
  doc

let make_doc id =
  match id with
  | 1 ->
    make_doc_objs [
      Key.make_0 ~:1, Array [Reference (Key.make_0 ~:3) ; Reference (Key.make_0 ~:4)] ;
      Key.make_0 ~:2, Array [Reference (Key.make_0 ~:6) ; Reference (Key.make_0 ~:5)] ;
      Key.make_0 ~:3, Array [Reference (Key.make_0 ~:5)] ;
      Key.make_0 ~:4, Array [Null] ;
      Key.make_0 ~:5, Array [Reference (Key.make_0 ~:3)] ;
      Key.make_0 ~:6, Array [Reference (Key.make_0 ~:2) ; Reference (Key.make_0 ~:5)] ;
    ]
  | 2 ->
    make_doc_trailer [
      Key.make_0 ~:1, Array [Reference (Key.make_0 ~:2)] ;
      Key.make_0 ~:2, Array [Reference (Key.make_0 ~:1)] ;
    ] (TestDict.add_all [
        "Root", Reference (Key.make_0 ~:1) ;
        "Info", Reference (Key.make_0 ~:2) ;
        "Size", Int ~:3 ;
      ])
  | 3 ->
    make_doc_trailer [
      Key.make_0 ~:1, Array [Reference (Key.make_gen ~:3 ~:1)] ;
      Key.make_0 ~:2, Int ~:123 ;
      Key.make_gen ~:3 ~:1, Int ~:456 ;
    ] (TestDict.add_all [
        "Root", Reference (Key.make_0 ~:1) ;
        "Info", Reference (Key.make_0 ~:2) ;
        "Size", Int ~:4 ;
        "ID", Null ;
      ])
  | 13 ->
    make_doc_trailer [
      Key.make_0 ~:1, Array [Reference (Key.make_0 ~:3)] ;
      Key.make_0 ~:2, Int ~:123 ;
      Key.make_0 ~:3, Int ~:456 ;
    ] (TestDict.add_all [
        "Root", Reference (Key.make_0 ~:1) ;
        "Info", Reference (Key.make_0 ~:2) ;
        "Size", Int ~:4 ;
      ])
  | 23 ->
    make_doc_trailer [
      Key.make_0 ~:1, Array [Int ~:456] ;
      Key.make_0 ~:2, Int ~:123 ;
      Key.make_gen ~:3 ~:1, Int ~:456 ;
    ] (TestDict.add_all [
        "Root", Reference (Key.make_0 ~:1) ;
        "Info", Int ~:123 ;
        "Size", Int ~:4 ;
        "ID", Null ;
      ])
  | 4 ->
    make_doc_trailer [
      Key.make_0 ~:1, Array [Reference (Key.make_0 ~:3)] ;
      Key.make_0 ~:2, Int ~:123 ;
      Key.make_0 ~:3, Array [Int ~:456 ; Dictionary (TestDict.add_all ["Key", String "Value" ; "None", Null])] ;
    ] (TestDict.add_all [
        "Root", Reference (Key.make_0 ~:1) ;
        "Size", Int ~:4 ;
      ])
  | 14 ->
    make_doc_trailer [
      Key.make_0 ~:1, Array [Reference (Key.make_0 ~:2)] ;
      Key.make_0 ~:2, Array [Int ~:456 ; Dictionary (TestDict.add_all ["Key", String "Value"])] ;
    ] (TestDict.add_all [
        "Root", Reference (Key.make_0 ~:1) ;
        "Size", Int ~:3 ;
      ])
  | 5 ->
    make_doc_trailer [
      Key.make_0 ~:1, Array [
        Reference (Key.make_0 ~:2) ;
        Reference (Key.make_0 ~:3) ;
        Reference (Key.make_0 ~:4) ;
        Reference (Key.make_0 ~:5) ;
        Reference (Key.make_0 ~:6) ;
        Reference (Key.make_0 ~:7) ;
        Reference (Key.make_0 ~:8) ;
        Reference (Key.make_0 ~:9) ;
        Reference (Key.make_0 ~:10) ;
        Reference (Key.make_0 ~:11) ;
        Reference (Key.make_0 ~:12) ;
      ] ;
      Key.make_0 ~:2, Null ;
      Key.make_0 ~:3, Bool false ;
      Key.make_0 ~:4, Int ~:123 ;
      Key.make_0 ~:5, Real "456.789" ;
      Key.make_0 ~:6, String "test" ;
      Key.make_0 ~:7, Name "foo" ;
      Key.make_0 ~:8, Array [Reference (Key.make_0 ~:4)] ;
      Key.make_0 ~:9, Array [Reference (Key.make_0 ~:9)] ;
      Key.make_0 ~:10, Dictionary (TestDict.add_all ["Key", String "Value" ; "Foo", Reference (Key.make_0 ~:6)]) ;
      Key.make_0 ~:11, Reference (Key.make_0 ~:11) ;
      Key.make_0 ~:12, Stream (TestDict.add_all ["Length", Reference (Key.make_0 ~:4)], "", Raw) ;
    ] (TestDict.add_all [
      ])
  | 15 ->
    make_doc_trailer [
      Key.make_0 ~:1, Array [
        Null ;
        Bool false ;
        Int ~:123 ;
        Real "456.789" ;
        String "test" ;
        Name "foo" ;
        Reference (Key.make_0 ~:8) ;
        Reference (Key.make_0 ~:9) ;
        Reference (Key.make_0 ~:10) ;
        Reference (Key.make_0 ~:11) ;
        Reference (Key.make_0 ~:12) ;
      ] ;
      Key.make_0 ~:2, Null ;
      Key.make_0 ~:3, Bool false ;
      Key.make_0 ~:4, Int ~:123 ;
      Key.make_0 ~:5, Real "456.789" ;
      Key.make_0 ~:6, String "test" ;
      Key.make_0 ~:7, Name "foo" ;
      Key.make_0 ~:8, Array [Int ~:123] ;
      Key.make_0 ~:9, Array [Reference (Key.make_0 ~:9)] ;
      Key.make_0 ~:10, Dictionary (TestDict.add_all ["Key", String "Value" ; "Foo", String "test"]) ;
      Key.make_0 ~:11, Reference (Key.make_0 ~:11) ;
      Key.make_0 ~:12, Stream (TestDict.add_all ["Length", Int ~:123], "", Raw) ;
    ] (TestDict.add_all [
      ])
  | 6 ->
    make_doc_trailer [
      Key.make_0 ~:1, Array [Reference (Key.make_0 ~:2) ; Reference (Key.make_0 ~:4)] ;
      Key.make_0 ~:2, Int ~:123 ;
      Key.make_gen ~:3 ~:1, Dictionary (TestDict.add_all ["Foo", Reference (Key.make_0 ~:4)]) ;
      Key.make_0 ~:4, Array [Int ~:456 ; Array [Reference (Key.make_0 ~:2)]] ;
    ] (TestDict.add_all [
      ])
  | -1 ->
    make_doc_objs [
      Key.make_0 ~:1, Array [Reference (Key.make_0 ~:2)] ;
      Key.make_0 ~:2, Array [Reference (Key.make_0 ~:3)] ;
    ]
  | -2 ->
    make_doc_trailer [
      Key.make_0 ~:1, Array [Reference (Key.make_0 ~:2)] ;
      Key.make_0 ~:2, Array [Reference (Key.make_0 ~:3)] ;
    ] (TestDict.add_all [
      ])
  | _ ->
    Document.create ()


let tests =
  "Document" >:::
  [
    "ref_closure" >:::
    [
      "(1)" >:: (fun _ -> assert_equal
                    (Document.ref_closure (make_doc 0) (Array [Int ~:123 ; Bool true ; Null]) Key.Trailer)
                    (TestSetkey.add_all [])) ;
      "(2)" >:: (fun _ -> assert_equal
                    (Document.ref_closure (make_doc 1) (Reference (Key.make_0 ~:1)) Key.Trailer)
                    (TestSetkey.add_all [Key.make_0 ~:1 ; Key.make_0 ~:3 ; Key.make_0 ~:4 ; Key.make_0 ~:5])) ;
      "(3)" >:: (fun _ -> assert_equal
                    (Document.ref_closure (make_doc 1) (Reference (Key.make_0 ~:3)) Key.Trailer)
                    (TestSetkey.add_all [Key.make_0 ~:3 ; Key.make_0 ~:5])) ;

      "(4)" >:: (fun _ -> assert_raises
                    (Errors.PDFError ("Reference to unknown object : 3", Errors.make_ctxt_key (Key.make_0 ~:2)))
                    (fun () -> Document.ref_closure (make_doc (-1)) (Reference (Key.make_0 ~:1)) Key.Trailer)) ;
      "(5)" >:: (fun _ -> assert_raises
                    (Errors.PDFError ("Reference to unknown object : 1", Errors.make_ctxt_key Key.Trailer))
                    (fun () -> Document.ref_closure (make_doc 0) (Reference (Key.make_0 ~:1)) Key.Trailer)) ;
    ] ;

    "graph" >:::
    [
      "(1)" >:: (fun _ -> assert_equal true (Graph.equals
                                               (Document.graph (make_doc 6))
                                               (TestGraph.make_graph 1))) ;
      (* TODO *)
    ] ;

    "sanitize_trailer" >:::
    [
      "(1)" >:: (fun _ -> assert_equal
                    (Document.sanitize_trailer (TestMapkey.add_all []) (TestDict.add_all ["Foo", String "Bar"]))
                    (TestDict.add_all ["Size", Int ~:1])) ;
      "(2)" >:: (fun _ -> assert_equal
                    (Document.sanitize_trailer (TestMapkey.add_all []) (TestDict.add_all ["Root", Int ~:123 ; "Info", String "test" ; "ID", Bool true]))
                    (TestDict.add_all ["Size", Int ~:1 ; "Root", Int ~:123 ; "Info", String "test" ; "ID", Bool true])) ;
      "(3)" >:: (fun _ -> assert_equal
                    (Document.sanitize_trailer
                       (TestMapkey.add_all [Key.make_0 ~:2, Key.make_0 ~:1 ; Key.make_0 ~:3, Key.make_0 ~:2])
                       (TestDict.add_all ["Root", Reference (Key.make_0 ~:2) ; "Info", Reference (Key.make_0 ~:3) ; "ID", Array [String "ABCD" ; String "EFGH"]]))
                    (TestDict.add_all ["Size", Int ~:3 ; "Root", Reference (Key.make_0 ~:1) ; "Info", Reference (Key.make_0 ~:2) ; "ID", Array [String "ABCD" ; String "EFGH"]])) ;

      "(4)" >:: (fun _ -> assert_raises
                    (Errors.PDFError ("Reference to unknown object : 1", Errors.make_ctxt_key Key.Trailer))
                    (fun () -> Document.sanitize_trailer (TestMapkey.add_all []) (TestDict.add_all ["Root", Reference (Key.make_0 ~:1)]))) ;
    ] ;

    "simplify_refs" >:::
    [
      "(1)" >:: (fun _ -> assert_equal
                    (Document.simplify_refs (make_doc 3))
                    (make_doc 23)) ;
      "(2)" >:: (fun _ -> assert_equal
                    (Document.simplify_refs (make_doc 5))
                    (make_doc 15)) ;

      "(3)" >:: (fun _ -> assert_raises
                    (Errors.UnexpectedError "No trailer found in document")
                    (fun () -> Document.simplify_refs (make_doc 1))) ;
      "(4)" >:: (fun _ -> assert_raises
                    (Errors.PDFError ("Reference to unknown object : 3", Errors.make_ctxt_key (Key.make_0 ~:2)))
                    (fun () -> Document.simplify_refs (make_doc (-2)))) ;
    ] ;

    "sanitize_nums" >:::
    [
      "(1)" >:: (fun _ -> assert_equal
                    (Document.sanitize_nums (make_doc 2))
                    (make_doc 2)) ;
      "(2)" >:: (fun _ -> assert_equal
                    (Document.sanitize_nums (make_doc 3))
                    (make_doc 13)) ;
      "(3)" >:: (fun _ -> assert_equal
                    (Document.sanitize_nums (make_doc 4))
                    (make_doc 14)) ;

      "(4)" >:: (fun _ -> assert_raises
                    (Errors.UnexpectedError "No trailer found in document")
                    (fun () -> Document.sanitize_nums (make_doc 0))) ;
    ] ;
  ] ;
