// SPDX-License-Identifier: GPL-3.0-or-later
TestPatternariumIntegration : UnitTest {
    test_recurrenceIntervalsAndArrivals {
        var distribution = Pscan(Pseq([0.1,0.2,0.1]),0,_+_);
        this.assertArrayFloatEquals(Prenewal(distribution,output: \time).asStream.all,[0.1,0.4,0.8]);
    }
    test_constraintGraphAndRenewalInOneEventStream {
        var graph = Dictionary[0 -> [2], 2 -> [4], 4 -> [0]];
        var p = Pbind(\degree,PgraphWalk(graph,0,3),\dur,Prenewal(Pconstraint([0.25,0.5],{true},3,output: \values)));
        var events = p.asStream.nextN(3,());
        this.assertEquals(events.collect { |e| e[\degree] },[0,2,4]);
        this.assertEquals(events.collect { |e| e[\dur] },[0.25,0.25,0.25]);
    }
    test_experimentalComposition {
        var p = Pbind(\net,Ppetri((fuel: 4),(note: (consume: (fuel: 1))),4),
            \degree,Pseed(Pseq([42]),Pvomm([0,2,4],length: 4)),\dur,0.125);
        var events = p.asStream.nextN(4,());
        this.assertEquals(events.collect { |e| e[\net][\marking][\fuel] },[3,2,1,0]);
        this.assert(events.every { |e| [0,2,4].includes(e[\degree]) });
        this.assertEquals(Pscan(Psandpile([1],drive: 0,threshold: 2,length: 4,output: \size),0,_+_).asStream.all,[0,1,1,2]);
    }
    test_pointProcessWindow {
        var p = Pseed(Pseq([42]),Pwindow(Phawkes(length: 8,output: \time),2));
        var windows = p.asStream.all;
        this.assertEquals(windows.size,7);
        this.assert(windows.every { |w| w[1] > w[0] });
    }
}
