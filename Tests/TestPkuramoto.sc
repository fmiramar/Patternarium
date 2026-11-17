// SPDX-License-Identifier: GPL-3.0-or-later
TestPkuramoto : UnitTest {
    test_uncoupledAndSynchronized {
        var phases = Pkuramoto([1,2],0,[0,0],0.1,3,output: \phases).asStream.all;
        phases.do { |p,i| this.assertArrayFloatEquals(p,[1,2] * ((i+1)*0.1),within: 1e-12) };
        this.assert(Pkuramoto([1,1],3,[0.2,0.2],0.1,10,output: \order).asStream.all.every { |x| (x-1).abs < 1e-12 });
    }
    test_wrapCountsAndFiltering {
        var event = Pkuramoto([2pi*2.5, -2pi*1.5],0,[0,0],1,1).asStream.next;
        this.assertEquals(event[\wraps],[2,-2]);
        this.assertArrayFloatEquals(event[\phases],[pi,pi],within: 1e-10);
        this.assertEquals(Pkuramoto([0],0,[0],0.1,3,output: \wraps).asStream.next,nil);
        this.assertEquals(Pkuramoto([2pi],0,[0],0.25,8,output: \wraps).asStream.all.size,2);
    }
    test_rk4Reference {
        // Independent classical RK4 step, documented in algorithm-notes.md.
        var expected = [0.1735274047754872, 1.0764725952245129];
        this.assertArrayFloatEquals(Pkuramoto([1,2],1.2,[0.1,1],0.05,1,output: \phases).asStream.next,expected,within: 1e-12);
    }
    test_matrixMatchesScalarAndOrderBounds {
        var a = Pkuramoto([1,2],1.2,[0.1,1],0.05,8).asStream.all;
        var b = Pkuramoto([1,2],[[1.2,1.2],[1.2,1.2]],[0.1,1],0.05,8).asStream.all;
        a.do { |e,i| this.assertArrayFloatEquals(e[\phases],b[i][\phases],within: 1e-12) };
        this.assert(a.every { |e| e[\order] >= 0 and: { e[\order] <= 1 } });
    }
    test_seededOwnershipAndInval {
        var p = Pseed(Pseq([42]),Pkuramoto([1,2],length: 4));
        var s = Pkuramoto([1],0,[0],0.1,2).asStream, first = s.next;
        var end = Routine { |in| Pkuramoto([0],0,[0],length: 1).embedInStream(in).yield };
        this.assertEquals(p.asStream.all,p.asStream.all);
        first[\phases][0] = 99;
        this.assertFloatEquals(s.next[\phases][0],0.2);
        end.next; this.assertEquals(end.next(9),9);
    }
    test_twoOscillatorExactSolution {
        var delta = 2 * ((0.5.tan) * (-2).exp).atan;
        var expected = [0.5-(delta/2),0.5+(delta/2)];
        var result = Pkuramoto([0,0],2,[0,1],0.025,40,output: \phases).asStream.all.last;
        this.assertArrayFloatEquals(result,expected,within: 1e-7);
    }
    test_stationaryWrapModeAndSilentBound {
        this.assertEquals(Pkuramoto([0],0,[0],output: \wraps).asStream.next,nil);
        this.assertException({ Pkuramoto([1e-9],0,[0],length: inf,output: \wraps).asStream.next },Error);
    }
    test_storeArgs {
        var p = Pkuramoto([1]);
        this.assertEquals(p.storeArgs,[[1],1,nil,0.01,inf,\rk4,\state]);
    }
    test_invalidAndZero {
        this.assertEquals(Pkuramoto([1],length: 0).asStream.next,nil);
        this.assertException({ Pkuramoto([]).asStream.next },Error);
        this.assertException({ Pkuramoto([1],step: 0).asStream.next },Error);
        this.assertException({ Pkuramoto([1,2],coupling: [[1]]).asStream.next },Error);
        this.assertException({ Pkuramoto([1],phases: [inf]).asStream.next },Error);
    }
}
