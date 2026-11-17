// SPDX-License-Identifier: GPL-3.0-or-later
Pvomm : Pattern {
    var <corpus, <maxOrder, <length, <start, <learning, <excludeSeen;
    *new { |corpus, maxOrder = 8, length = inf, start, learning = false, excludeSeen = true|
        PTRValidation.staticInteger(maxOrder,\Pvomm,\maxOrder,0);
        PTRValidation.staticInteger(length,\Pvomm,\length,0,true);
        ^super.newCopyArgs(corpus,maxOrder,length,start,learning,excludeSeen)
    }
    storeArgs { ^[corpus,maxOrder,length,start,learning,excludeSeen] }
    embedInStream { |inval|
        var order = PTRValidation.integer(PTRValidation.once(maxOrder,inval),\Pvomm,\maxOrder,0);
        var count = PTRValidation.integer(PTRValidation.once(length,inval),\Pvomm,\length,0,true);
        var learn = PTRValidation.boolean(PTRValidation.once(learning,inval),\Pvomm,\learning);
        var exclusion = PTRValidation.boolean(PTRValidation.once(excludeSeen,inval),\Pvomm,\excludeSeen);
        var model = PTRVommModel(corpus,order), history = start.value(inval), symbol, index = 0;
        history = if(history.isNil) { [] } { if(history.isKindOf(SequenceableCollection)) { history.asArray.copy } { [history] } };
        if(history.includes(nil)) { Error("Pvomm: start context cannot contain nil.").throw };
        history = history.drop((history.size-order).max(0));
        while { index < count } {
            symbol = model.sample(history,exclusion);
            if(learn) { model.observe(history,symbol) };
            history = model.nextHistory(history,symbol);
            inval = symbol.yield;
            if(index == 2147483646) { Error("Pvomm: output index range exceeded.").throw };
            index = index + 1;
        };
        ^inval
    }
}
