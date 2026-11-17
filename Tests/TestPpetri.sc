// SPDX-License-Identifier: GPL-3.0-or-later
TestPpetri : UnitTest {
    setUp { thisThread.randSeed = 42 }
    test_tokensAndAtomicFiring {
        var p = Ppetri((ready: 1),(start: (consume: (ready: 1),produce: (playing: 1),value: \note,delta: 0.25)));
        var values = p.asStream.all;
        this.assertEquals(values.size,1);
        this.assertEquals(values[0][\marking],(ready: 0,playing: 1));
        this.assertEquals(values[0][\transition],\start);
        this.assertEquals(values[0][\value],\note);
        this.assertEquals(values[0][\delta],0.25);
    }
    test_synchronizationAndDeadlock {
        var t = (join: (consume: (a: 1,b: 1),produce: (done: 1)));
        this.assertEquals(Ppetri((a: 1,b: 0),t).asStream.next,nil);
        this.assertException({ Ppetri((a: 1,b: 0),t,deadlock: \error).asStream.next },Error);
        this.assertEquals(Ppetri((a: 1,b: 1),t).asStream.next[\marking][\done],1);
    }
    test_priorityAndWeights {
        var t = (a: (priority: 1,weight: 1),b: (priority: 2,weight: 1));
        this.assertEquals(Ppetri((),t,3,\priority).asStream.all.collect { |e| e[\transition] },[\b,\b,\b]);
        this.assertEquals(Ppetri((),(a: (weight: 0),b: (weight: 1)),3).asStream.all.collect { |e| e[\transition] },[\b,\b,\b]);
    }
    test_ownershipAndReproducibility {
        var marking = (a: 2), transitions = (fire: (consume: (a: 1))), p = Ppetri(marking,transitions);
        var s = p.asStream, first = s.next;
        first[\marking][\a] = 99;
        this.assertEquals(s.next[\marking][\a],0);
        this.assertEquals(marking[\a],2);
        this.assertEquals(p.asStream.next[\marking][\a],1);
        p = Pseed(Pseq([42]),Ppetri((),(a: (),b: (weight: 2)),20));
        this.assertEquals(p.asStream.all,p.asStream.all);
    }
    test_zeroInvalAndStoreArgs {
        var p = Ppetri((),(a: ()),1), s = Routine { |in| p.embedInStream(in).yield };
        s.next; this.assertEquals(s.next(9),9);
        this.assertEquals(Ppetri((),(a: ()),0).asStream.next,nil);
        this.assertEquals(p.storeArgs,[p.marking,p.transitions,1,\weighted,\stop,\event]);
    }
    test_conservationAndUniformPolicy {
        var t = (a: (consume: (x: 1),produce: (y: 1)),b: (consume: (y: 1),produce: (x: 1)));
        var events = Ppetri((x: 3,y: 1),t,100,\uniform).asStream.all;
        this.assert(events.every { |e| e[\marking].values.sum == 4 and: { e[\marking].values.every { |v| v >= 0 } } });
        this.assertEquals(Ppetri((),(a: (weight: 0)),1,\uniform).asStream.next[\transition],\a);
    }
    test_invalid {
        this.assertException({ Ppetri((a: -1),(a: ())).asStream.next },Error);
        this.assertException({ Ppetri((),(a: (consume: (x: 1.5)))).asStream.next },Error);
        this.assertException({ Ppetri((),(a: (weight: -1))).asStream.next },Error);
        this.assertException({ Ppetri((a: 2147483647),(a: (produce: (a: 1)))).asStream.next },Error);
    }
}
