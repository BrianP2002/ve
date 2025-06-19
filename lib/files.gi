Pr := function(string)
    local len;
    len := Length(string);
    if len <= free then
        Print(string);
        free := free - len;
    else
        Print("\n", string);
        free := ncols - len;
    fi;
end;

printalgelmstring := function(elm)
    local j, k, coeff;
    if not IsRecord(elm) then
        elm := rec(words := [elm], coeff := [One(A.field)]);
    fi;
    if Length(elm.words) = 0 then
        Pr("0");
    fi;
    for j in [1 .. Length(elm.words)] do
        coeff := (char = 0) and elm.coeff[j] or Int(elm.coeff[j]);
        if j > 1 and coeff > 0 then Pr("+"); fi;
        if coeff <> 0 and coeff <> 1 then
            Pr(String(coeff));
            if elm.words[j] <> id then Pr("*"); fi;
        fi;
        if coeff = 1 and elm.words[j] = id then
            Pr("1");
        fi;
        for k in [1 .. LengthWord(elm.words[j])] do
            if k > 1 then Pr("*"); fi;
            Pr(names[Position(Agenerators, Subword(elm.words[j], k, k))]);
        od;
    od;
end;

#############################################################################
##
#F  PrintVEInput( <A>, <M>, <names> )  . . .  input for the Vector Enumerator
##
##  takes a finitely presented algebra <A> and submodule generators <M>
##  (a list of vectors over <A>), and a list <names> of names the generators
##  have in the presentation for {\VE},
##  and prints the presentation to be input into the vector enumeration
##  program.
##
InstallGlobalFunction( PrintVEInput, function( A, M, names )
    local i, j, k,            # loop variables
          char,               # characteristic of the algebra
          ncols,              # line length
          free,               # space in actual line
          Pr,                 # print function taking care of line length
          printalgelmstring,  # local function printing algebra elements
          rels,               # relators of the algebra
          grouptyperels,      # group type relators
          otherrels,          # non-group type relators
          id,
          one,
          invertible,
          involutions,
          dim,
          entry,
          Agenerators;
    
    ncols := GAPInfo.UserScreenSize[1] - 2;
    free := ncols;
    char := Characteristic(A.field);
    Print(char, ".\n");

    Agenerators := List(A.generators, x -> x.words[1]);
    rels := A.relators;
    grouptyperels := [];
    otherrels := [];
    id := One(A.generators[1].words[1]);
    one := One(A.field);
    for entry in rels do
        if Length(entry.words) = 2 and entry.words[1] = id and ((entry.coef[1] = one and entry.coef[2] = - one) or (entry.coef[1] = -one and entry.coef[2] = one)) then
            Add(grouptyperels, entry);
        else
            Add(otherrels, entry);
        fi;
    od;
    
    for i in names do Pr(i); Pr(" "); od;
    Pr(".\n"); free := ncols;

    invertible := Intersection(
        List(grouptyperels, x -> Subword(x, 1, 1)),
        List(grouptyperels, x -> Subword(x, LengthWord(x), LengthWord(x)))
    );

    if Length(invertible) = 0 then
        Pr("*..\n");
    else
        for i in Difference(Agenerators, invertible) do
            Pr(names[Position(Agenerators, i)]); Pr(" ");
        od;
        Pr(".\n");
        involutions := Filtered(invertible, x -> x^2 in grouptyperels);
        if Length(involutions) = 0 then
            Pr("*.\n");
        else
            for i in Difference(invertible, involutions) do
                Pr(names[Position(Agenerators, i)]); Pr(" ");
            od;
            Pr(".\n");
        fi;
    fi;
    free := ncols;

    for i in [1 .. Length(grouptyperels)] do
        if ForAny([1 .. LengthWord(grouptyperels[i])], x -> not Subword(grouptyperels[i], x, x) in invertible) then
            AddSet(otherrels, AlgebraElement(A, [one, -one], [grouptyperels[i], id]));
            Unbind(grouptyperels, i);
        fi;
    od;

    if IsRecord(M) then M := M.generators; fi;
    dim := Length(M[1]);
    Pr("{"); Pr(String(dim)); Pr("}");

    for i in [1 .. Length(M)] do
        Pr("(");
        for j in [1 .. dim] do
            printalgelmstring(M[i][j]);
            if j < dim then Pr(","); fi;
        od;
        Pr(")");
        if i < Length(M) then Pr(",\n"); free := ncols; fi;
    od;
    Pr(".\n"); free := ncols;

    for i in grouptyperels do
        if IsBound(i) then printalgelmstring(i); Pr(", "); fi;
    od;
    Pr(":\n"); free := ncols;
    for i in otherrels do
        printalgelmstring(i); Pr(" = 0, ");
    od;
    Print(".\n");
end;

     
end );

#############################################################################
##
#F  CallVE( <commandstr>, <infile>, <outfile>, <options> )
##
InstallGlobalFunction( CallVE, function( commandstr, infile, outfile, options )
    Exec(Concatenation(VE.Path, commandstr, " -p ", infile, " -o ", outfile, " -i -P -v0 -L'#I  ' -Y VE.out ", options));
end );

#############################################################################
##
#F  VEOutput( <A>, <M>, <names>, <outfile> [, "mtx"] )
##
InstallGlobalFunction( VEOutput, function( arg )
    local result;

    VE.out := false;
    Read(Concatenation(outfile, ".g"));
    Exec("rm ", outfile, ".g");

    if VE.out = false then
        Error("output file was not readable");
    fi;
    result := VE.out;
    Unbind(VE, "out");
    #TODO: deal with the meataxe output later
    return result;
end );

InstallGlobalFunction( FpAlgebraOps.OperationQuotientModule, function( A, M, opr  )
    local file, i, alpha, lalpha, names, filepres, outfile, commandstr,
          output, result;

    if not IsFpAlgebra(A) or not IsList(M) then
        Error("<A> must be f.p. algebra, <M> list of submodule generators");
    fi;

    if Characteristic(A.field) = 0 then
        if A.field = Integers then
            commandstr := "zme";
        elif A.field = Rationals then
            commandstr := "qme";
        else
            Error("characteristic 0: 'Integers' and 'Rationals' only");
        fi;
        if opr = "mtx" then
            Error("MeatAxe output only for nonzero characteristic");
        fi;
    elif Characteristic(A.field) > 255 then
        Error("'me' allows finite characteristic up to 255 only");
    else
        commandstr := "me";
    fi;

    alpha := "abcdefghijklmnopqrstuvwxyz";
    lalpha := Length(alpha);
    i := 1;
    while lalpha^i < Length(A.generators) do i := i + 1; od;
    i := Sum([1..i-1], x -> lalpha^x);
    names := List([1..Length(A.generators)], x -> String(x + i));

    file := Filename(DirectoryTemporary(), "veinput");
    filepres := Concatenation(file, ".pres");
    PrintTo(filepres, PrintVEInput(A, M, names));

    outfile := Filename(DirectoryTemporary(), "veout");

    if opr <> "mtx" then
        CallVE(commandstr, file, outfile, Concatenation(VE.options, " -G"));
        output := VEOutput(A, M, names, outfile);
    else
        CallVE(commandstr, file, outfile, Concatenation(VE.options, " -m -H"));
        output := VEOutput(A, M, names, outfile, "mtx");
    fi;

    if output.gens[1] = [] or Dimensions(output.gens[1])[1] = 0 then
        output.operation.genimages := List(output.gens, x -> NullMat(0, 0, A.field));
        result := NullAlgebra(A.field);
    else
        result := UnitalAlgebra(A.field, output.gens);
    fi;

    result.operation := output.operation;
    result.operation.genpreimages := A.generators{
        List(result.generators, x -> Position(output.operation.genimages, x))
    };

    Exec("rm ", filepres);
    return result;
end );