// SPDX-License-Identifier: GPL-3.0-or-later
TestPsandpile : UnitTest {
    test_oneDimensionalAndConservation {
        var events = Psandpile([3],initial: [0,1,0],drive: {1},threshold: 2,length: 8).asStream.all, mass = 1;
        events.do { |e|
            this.assert(e[\state].every { |x| x >= 0 and: { x < 2 } });
            this.assertEquals(e[\state].sum+e[\lostGrains],mass+1);
            mass = e[\state].sum;
        };
        this.assertEquals(events[0][\state],[1,0,1]);
        this.assertEquals(events[0][\avalancheSize],1);
    }
    test_centerToppling {
        var event = Psandpile([3,3],[[0,0,0],[0,3,0],[0,0,0]],{[1,1]},length: 1).asStream.next;
        this.assertEquals(event[\state],[[0,1,0],[1,0,1],[0,1,0]]);
        this.assertEquals(event[\avalancheSize],1);
        this.assertEquals(event[\activeSites],1);
        this.assertEquals(event[\lostGrains],0);
        this.assertEquals(event[\toppledSites],[[1,1]]);
    }
    test_boundaryAndBulkDissipation {
        var edge = Psandpile([1,1],[[3]],{0},length: 1).asStream.next;
        var bulk = Psandpile([1], [3], {0},threshold: 4,length: 1).asStream.next;
        this.assertEquals(edge[\lostGrains],4);
        this.assertEquals(bulk[\lostGrains],4);
        this.assertEquals(edge[\state],[[0]]);
    }
    test_closedAndGuard {
        this.assertException({ Psandpile([1],[1],{0},2,\closed,1).asStream.next },Error);
        this.assertException({ Psandpile([1,1],[[3]],{0},length: 1,maxTopplings: 0).asStream.next },Error);
        this.assertEquals(Psandpile([2],[0,0],{0},2,\closed,1).asStream.next[\lostGrains],0);
    }
    test_drivePatternOwnershipAndSeed {
        var initial = [0,0], p = Psandpile([2],initial,Pseq([0,1,0]),2), s = p.asStream, first = s.next;
        first[\state][0] = 99;
        this.assertEquals(s.next[\state],[1,1]);
        this.assertEquals(initial,[0,0]);
        this.assertEquals(p.asStream.next[\state],[1,0]);
        p = Pseed(Pseq([42]),Psandpile([3,3],length: 30));
        this.assertEquals(p.asStream.all,p.asStream.all);
    }
    test_outputModesInvalAndStoreArgs {
        var p = Psandpile([1],[0],{0},2,length: 2,output: \size);
        var s = Routine { |in| Psandpile([2],drive: { |state,index,in| in },threshold: 2,length: 1).embedInStream(in).yield };
        this.assertEquals(p.asStream.all,[0,1]);
        this.assertEquals(s.next(1)[\drive],[1]);
        this.assertEquals(s.next(9),9);
        this.assertEquals(p.storeArgs,[p.size,p.initial,p.drive,2,\open,2,\size,1000000]);
        this.assertEquals(Psandpile(length: 0).asStream.next,nil);
    }
    test_abelianDriveOrderAndStableOutputs {
        var a = Psandpile([3,3],drive: Pseq([0,4,8],20)).asStream.all;
        var b = Psandpile([3,3],drive: Pseq([8,4,0],20)).asStream.all;
        this.assertEquals(a.last[\state],b.last[\state]);
        this.assertEquals(a.collect { |e| e[\lostGrains] }.sum,b.collect { |e| e[\lostGrains] }.sum);
        this.assert(a.every { |e| e[\state].flat.every { |x| x >= 0 and: { x < 4 } } });
        this.assertException({ Psandpile([2,2],[[3,2],[3,3]],{0},boundary: \closed,length: 1,maxTopplings: 20).asStream.next },Error);
    }
    test_twoDimensionalOutputAndDriveCopies {
        var initial = [[0]], p = Psandpile([1,1],initial,{ |grid| grid[0][0] = 999; [0,0] },length: 2), stream = p.asStream;
        var first = stream.next;
        this.assertEquals(first[\state],[[1]]);
        first[\state][0][0] = 99;
        this.assertEquals(stream.next[\state],[[2]]);
        this.assertEquals(initial,[[0]]);
    }
    test_invalid {
        this.assertException({ Psandpile([0]).asStream.next },Error);
        this.assertException({ Psandpile([2,2],[[0,0]],{0}).asStream.next },Error);
        this.assertException({ Psandpile([2],drive: {-1}).asStream.next },Error);
        this.assertException({ Psandpile([2,2],threshold: 3).asStream.next },Error);
    }
}
