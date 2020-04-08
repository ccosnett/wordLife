
Clear[statePlot, lifePlot, asdfasdf, satSolverOutput, x, S, updateLife, R1, R2, R3, R4, S, bool, antiBool, or, and, join, CNF, CNFToclausalForm2, clausalForm2ToCNF,array3Processor,formula,varlist];
Get[NotebookDirectory[]<>"clause_sets_R1_R2_R3_and_R4_.m"];

(*HELPER FUNCTIONS*)


updateLife[stateXt_] := Module[
   {x, xNW, xN, xNE, xW, xE, xSW, xS, xSE, xPrime, pad,dim}
   ,
    dim=Dimensions[stateXt];
   pad = ArrayPad[#, 1] &;
   x[i_, j_] := pad[stateXt][[i, j]];
   xNW[i_, j_] := x[i + 1, j - 1];
   xN[i_, j_] := x[i + 1, j];
   xNE[i_, j_] := x[i + 1, j + 1];
   xW[i_, j_] := x[i, j - 1];
   xE[i_, j_] := x[i, j + 1];
   xSW[i_, j_] := x[i - 1, j - 1];
   xS[i_, j_] := x[i - 1, j];
   xSE[i_, j_] := x[i - 1, j + 1];
   xPrime[i_, j_] := Boole[ 2 < xNW[i, j] + xN[i, j] + xNE[i, j] + xW[i, j] + 1/2 x[i, j] + xE[i, j] + xSW[i, j] + xS[i, j] + xSE[i, j] < 4 ]
   ; Table[xPrime[i, j] , {i, 2, dim[[1]]+1 }, {j, 2, dim[[2]]+1}]
    ];
statePlot = Magnify[ArrayPlot[#, Frame -> False, Mesh -> True] , .3] &;
lifePlot[seed_, steps_: 6] :=statePlot /@ NestList[updateLife[#] &, seed, steps];
bool=#/.{True->1,False->0}&;
antiBool=#/.{1->True,0->False}&;
or=Or@@Flatten[#]&;
and=And@@Flatten[#]&;
join=Join[##]//Flatten&;
CNF = BooleanConvert[#, "CNF"] &;
CNFToclausalForm2[clausesInCNF_] := (clausesInCNF) /. {Or -> List, And -> List };
clausalForm2ToCNF[clausesInClausalForm2_] := And@@(Or@@#&/@(clausesInClausalForm2));
array3Processor[array3_] := And @@ (Or @@ # & /@ Flatten[array3 , 3]);






(*MAIN PROGRAM*)

(*ARRAY SIZE DETERMINATION AND BOUNDARY CONDITIONS*)

n=endGeneration;
{i, j} = Dimensions[endState];

Evaluate[Array[x[##,n]&, {i, j}]] = antiBool[endState];

x[_, 0, g_/;(g!=n)] = False;
x[0, _,  g_/;(g!=n)] = False;
x[_, j+1,  g_/;(g!=n)] = False;
x[i+1, _,  g_/;(g!=n)] = False;


(*PRINTING DESIRED END STATE*)
MessageDialog[Evaluate[Array[x[##,n]&, {i, j}]]//bool//statePlot];




(*TAKING THE UNION OF R1,R2,R3 and R4*)

S[i_,j_,g_]:=Union[
      R1[i,j,g]
    , R2[i,j,g]
    , R3[i,j,g]
    , R4[i,j,g]
];


(*LOOPING CLAUSE SETS*)



formula = array3Processor@Array[S, {i, j, n-1} ];


(*GATHERING ALL VARIABLES USED INTO A LIST*)
varlist =
  Join[
      Flatten[Array[x, {i, j, n-1}]]
      ];



(*SAT SOLVER*)

satSolverOutput = SatisfiabilityInstances[formula, varlist];


(*PROCESSING OUTPUT OF SOLVER*)

initialState=If[Length[satSolverOutput] == 0, "unsatisfiable",
 out1 = Array[x[##,1]&, {i, j}] /. Thread[varlist -> RandomChoice[satSolverOutput]];
 bool@out1
 ];

(*FORMATTING OUTPUT*)

lifePlot[initialState , 10]
