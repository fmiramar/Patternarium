// Finite, server-free workloads. Includes output Array allocation; not a CI gate.
(
var measure;
try {
    measure = { |label, function|
        var start = Main.elapsedTime, result = function.value;
        "%: % outputs in % seconds".format(label,result,Main.elapsedTime-start).postln;
    };
    measure.value("scan", { Pscan(Pseries(0,1,10000),0,_+_).asStream.all.size });
    measure.value("window-overlap", { Pwindow(Pseries(0,1,4096),64).asStream.all.size });
    measure.value("window-wide-step", { Pwindow(Pseries(0,1,20000),1024,512).asStream.all.size });
    measure.value("deBruijn", { PdeBruijn([0,1],12).asStream.all.size });
    measure.value("gray", { PgrayCode([10,10,10]).asStream.all.size });
    measure.value("halton", { Pqmc(3,length: 10000).asStream.all.size });
    measure.value("renewal", { Prenewal(Pseq([0.1],10000)).asStream.all.size });
    measure.value("hawkes", { Pseed(Pseq([42]),Phawkes(length: 5000)).asStream.all.size });
    measure.value("constraint", { Pconstraint((0..5),{ |h,x| h.includes(x).not },6,20).asStream.all.size });
    measure.value("graph", { PgraphWalk((a: [\b],b: [\c],c: [\a]),\a,10000).asStream.all.size });
    measure.value("vomm", { Pseed(Pseq([42]),Pvomm([0,1,0,2,0,1,3,0],3,10000)).asStream.all.size });
    measure.value("petri", { Ppetri((x: 1),(a: (consume: (x: 1),produce: (y: 1)),b: (consume: (y: 1),produce: (x: 1))),10000).asStream.all.size });
    measure.value("kuramoto", { Pkuramoto([1,1.1,0.9,1.2],1,[0,1,2,3],0.01,1000).asStream.all.size });
    measure.value("branching", { Pbranching(0,2,maxDepth: 10,maxNodes: 3000).asStream.all.size });
    measure.value("sandpile", { Pseed(Pseq([42]),Psandpile([8,8],length: 1000)).asStream.all.size });
    0.exit;
} { |error| error.reportError; 1.exit };
)
