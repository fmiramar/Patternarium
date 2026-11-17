// Run inside a Routine so UnitTest does not schedule asynchronous work.
(
Routine {
    var names = [\Pscan, \Pwindow, \Ptransduce, \Pmorphism, \PTRValidation, \PdeBruijn, \PgrayCode, \Pqmc, \ProtationWord, \PnumSeq, \PTRSequenceAlgorithms, \PpointProcess, \Prenewal, \Phawkes, \PTRPointProcess, \Pconstraint, \PgraphWalk, \PTRGraph, \Pvomm, \PTRVommModel, \Ppetri, \Pbranching, \Pkuramoto, \Psandpile];
    var tests = [\TestPscan, \TestPwindow, \TestPtransduce, \TestPmorphism, \TestPdeBruijn, \TestPgrayCode, \TestPqmc, \TestProtationWord, \TestPnumSeq, \TestPpointProcess, \TestPrenewal, \TestPhawkes, \TestPconstraint, \TestPgraphWalk, \TestPatternariumIntegration, \TestPvomm, \TestPpetri, \TestPbranching, \TestPkuramoto, \TestPsandpile];
    try {
        (names ++ tests).do { |name|
            if(name.asClass.isNil) { Error("Patternarium: missing class " ++ name).throw };
        };
        UnitTest.reset;
        tests.do { |name| name.asClass.run(false, false) };
        UnitTest.report;
        if(UnitTest.passes.isEmpty) { Error("Patternarium: no assertions executed.").throw };
        if(UnitTest.failures.notEmpty) { 1.exit } { 0.exit };
    } { |error|
        error.reportError;
        1.exit;
    };
}.play(AppClock);
)
