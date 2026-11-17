// SPDX-License-Identifier: GPL-3.0-or-later
TestPhawkes : UnitTest {
    setUp { thisThread.randSeed = 42 }
    test_noExcitationMatchesSharedExponentialSampler {
        var h = Pseed(Pseq([42]), Phawkes(2, 0, length: 12, output: \delta)).asStream.all;
        var r = Pseed(Pseq([42]), Prenewal(Pfunc { PTRPointProcess.exponential(2) }, length: 12)).asStream.all;
        this.assertArrayFloatEquals(h, r, within: 1e-12);
    }
    test_directHistoryReferenceTrace {
        // Independent full-history intensity calculation using sclang seed-42 uniforms.
        var expected = [0.9229762933637841, 0.34355619603234155, 0.11858457242333964, 0.14519996226989695, 0.01735103112871883, 0.23315367404259368, 0.009576741024406088, 0.1093857206567781, 0.6430174026098279, 0.11991237073941408, 0.028498722614055172, 0.014855731326092414, 0.02403420090617825, 0.0031477111575055616, 0.018341535800022957, 0.41392554896004086, 0.1600351238418951, 0.15172583872989343, 0.140941128372718, 0.4546459915587322, 0.020292761534811632, 0.2382273159479782, 0.8303919196416576, 0.2406744387580506, 0.37110068218824654, 0.137226031267617, 0.0006098978719961679, 0.052953961937655336, 0.09428094352371641, 0.04212636838822448, 0.05681966823342588, 0.45157704269246857];
        var actual = Pseed(Pseq([42]), Phawkes(length: 32, output: \delta)).asStream.all;
        this.assertArrayFloatEquals(actual, expected, within: 1e-10);
    }
    test_monotonicAndSeeded {
        var p = Pseed(Pseq([123]), Phawkes(length: 100)), values = p.asStream.all;
        this.assertEquals(values, p.asStream.all);
        this.assert(values.every { |e| e[\delta] > 0 and: { e[\dimension] == 0 and: { e[\intensity] >= 1 } } });
        values.doAdjacentPairs { |a,b| this.assert(b[\time] > a[\time]) };
    }
    test_multivariateAndMatrixOrientation {
        var matrix = [[0,0],[0.4,0]], p = Pseed(Pseq([9]), Phawkes([1,0], decay: [1,2], interactionMatrix: matrix, length: 100));
        var values = p.asStream.all;
        this.assertEquals(values, p.asStream.all);
        this.assert(values.any { |e| e[\dimension] == 1 });
        this.assert(values.every { |e| [0,1].includes(e[\dimension]) });
        this.assertEquals(matrix, [[0,0],[0.4,0]]);
    }
    test_stability {
        this.assertException({ Phawkes(excitation: 1).asStream.next }, Error);
        this.assertException({ Phawkes(interactionMatrix: [[0,2],[1,0]]).asStream.next }, Error);
        this.assertNoException({ Phawkes(interactionMatrix: [[0,10],[0,0]], length: 0).asStream.next });
        this.assertNoException({ Phawkes(excitation: 2, allowUnstable: true, length: 1).asStream.next });
    }
    test_capsAndInvalid {
        this.assertException({ Phawkes(baseRate: 10, maxIntensity: 5).asStream.next }, Error);
        this.assertException({ Phawkes(excitation: 2, allowUnstable: true, maxIntensity: 2).asStream.next }, Error);
        this.assertException({ Phawkes(decay: 0).asStream.next }, Error);
        this.assertException({ Phawkes(baseRate: -1).asStream.next }, Error);
        this.assertException({ Phawkes(interactionMatrix: [[1,2]]).asStream.next }, Error);
        this.assertException({ Phawkes(excitation: -1).asStream.next }, Error);
    }
    test_zeroRateAndZeroLength {
        this.assertEquals(Phawkes(baseRate: 0).asStream.next, nil);
        this.assertEquals(Phawkes(length: 0).asStream.next, nil);
    }
    test_outputModesAndInval {
        var times = Pseed(Pseq([42]), Phawkes(start: 10, length: 3, output: \time)).asStream.all;
        var deltas = Pseed(Pseq([42]), Phawkes(length: 3, output: \delta)).asStream.all;
        var s = Routine { |in| Phawkes(length: 1).embedInStream(in).yield };
        this.assertArrayFloatEquals(times, deltas.integrate + 10);
        s.next; this.assertEquals(s.next(9), 9);
    }
    test_multivariateAnalyticStabilityBounds {
        var stable = [[0.5,2],[0.01,0.5]], unstable = [[0.8,1],[0.1,0.8]];
        this.assert(PTRPointProcess.stabilityBound(stable,[1,1]) < 1);
        this.assert(PTRPointProcess.stabilityBound(unstable,[1,1]) >= 1);
        this.assertNoException({ Phawkes(interactionMatrix: stable,length: 0).asStream.next });
        this.assertException({ Phawkes(interactionMatrix: unstable,length: 0).asStream.next }, Error);
    }
    test_storeArgs {
        var p = Phawkes.new;
        this.assertEquals(p.storeArgs, [1,0.5,1,1,nil,0,inf,\event,false,100000]);
    }
}
