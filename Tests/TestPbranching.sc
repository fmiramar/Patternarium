// SPDX-License-Identifier: GPL-3.0-or-later
TestPbranching : UnitTest {
    test_breadthAndDepth {
        var value = { |parent,child| parent[\value] ++ child.asString };
        this.assertEquals(Pbranching("",2,value,2,20,\breadth,\value).asStream.all,["","0","1","00","01","10","11"]);
        this.assertEquals(Pbranching("",2,value,2,20,\depth,\value).asStream.all,["","0","00","01","1","10","11"]);
    }
    test_parentMetadata {
        var values = Pbranching(1,2,maxDepth: 2).asStream.all;
        this.assertEquals(values.collect { |n| n[\index] },(0..6));
        this.assertEquals(values[3][\parentIndex],1);
        this.assertEquals(values[4][\childIndex],1);
        this.assertEquals(values[6][\depth],2);
    }
    test_extinctionDepthAndBounds {
        this.assertEquals(Pbranching(1,0).asStream.all.size,1);
        this.assertEquals(Pbranching(1,2,maxDepth: 0).asStream.all.size,1);
        this.assertException({ Pbranching(1,2,maxNodes: 2).asStream.all },Error);
        this.assertException({ Pbranching(1,-1).asStream.all },Error);
    }
    test_patternOffspringAndIsolation {
        var p = Pbranching(1,Pseq([2,0]),maxDepth: 4);
        this.assertEquals(p.asStream.all.size,3);
        this.assertEquals(p.asStream.all,p.asStream.all);
    }
    test_latestInvalAndOwnership {
        var p = Pbranching(1,{ |node,in| in },maxDepth: 1), s = p.asStream, first = s.next;
        first[\depth] = 99;
        this.assertEquals(s.next(1)[\depth],1);
        this.assertEquals(s.next,nil);
        this.assertEquals(p.asStream.next[\depth],0);
    }
    test_seededOffspringAndEventValues {
        var p = Pseed(Pseq([42]),Pbranching(1,Pwhite(0,2),maxDepth: 5,maxNodes: 100));
        var seed = (n: 1), events = Pbranching(seed,1,{ |parent| (n: parent[\value][\n]+1) },2,output: \value).asStream.all;
        this.assertEquals(p.asStream.all,p.asStream.all);
        this.assertEquals(events,[(n: 1),(n: 2),(n: 3)]);
        this.assertEquals(seed,(n: 1));
    }
    test_terminationAndStoreArgs {
        var p = Pbranching(1,0), s = Routine { |in| p.embedInStream(in).yield };
        s.next; this.assertEquals(s.next(9),9);
        this.assertEquals(p.storeArgs,[1,0,nil,8,10000,\breadth,\node]);
    }
}
