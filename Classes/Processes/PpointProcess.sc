// SPDX-License-Identifier: GPL-3.0-or-later
PpointProcess : Pattern {
    var <start, <length, <output;
    *new { Error("PpointProcess: abstract base; instantiate Prenewal or Phawkes.").throw }
    prParameters { |inval|
        var time = PTRValidation.finite(PTRValidation.once(start, inval), this.class, \start);
        var count = PTRValidation.integer(PTRValidation.once(length, inval), this.class, \length, 0, true);
        var mode = PTRValidation.once(output, inval);
        if([\delta,\time,\event].includes(mode).not) { Error("%: output received %; expected delta, time or event.".format(this.class, mode)).throw };
        ^[time, count, mode]
    }
    prOutput { |time, delta, mode, fields|
        ^switch(mode, \time, { time }, \delta, { delta }, { (time: time, delta: delta).putAll(fields ? ()) })
    }
}
