// SPDX-License-Identifier: GPL-3.0-or-later
// Evaluate blocks separately. Musical blocks use the Guide instruments.

// PpointProcess

(
Prenewal(Pseq([0.25, 0.5, 0.125]), start: 2, output: \event).asStream.all;
)

// Prenewal

(
Prenewal(Pseq([0.25, 0.5, 1]), output: \time).asStream.all;
)

(
(
Pbind(\instrument, \mallet, \degree, Pseq([0, 2, 4, 7], 4),
    \dur, Prenewal(Pexprand(0.1, 0.5), length: 16)).play;
)
)

// Phawkes

(
Pseed(Pseq([42]), Phawkes(length: 8)).asStream.all;
)

(
(
Pbind(\instrument, \mallet, \degree, 0,
    \dur, Pseed(Pseq([42]), Phawkes(2, 0.6, 2, length: 32, output: \delta))).play;
)
)

(
Pseed(Pseq([42]), Phawkes(0.4, 0.8, 1.2, length: 24)).asStream.all;
)

(
Pseed(Pseq([42]), Phawkes(2, 1.2, 2, length: 24, output: \delta)).asStream.all;
)

(
Pseed(Pseq([42]), Phawkes([1, 0.1], decay: 2,
    interactionMatrix: [[0, 0.2], [1.2, 0]], length: 24)).asStream.all;
)

(
(
var matrix = [[0.1, 0.4], [0.7, 0.1]];
matrix.postln;
Pbind(\instrument, \saw,
    \arrival, Pseed(Pseq([42]), Phawkes([1, 0.3], decay: 2, interactionMatrix: matrix, length: 24)),
    \degree, Pfunc { |e| [0, 7][e[\arrival][\dimension]] },
    \dur, Pfunc { |e| e[\arrival][\delta] }
).play;
)
)

(
Pseed(Pseq([42]), Phawkes(1, 0.8, 1.5, length: 16)).collect { |e|
    [e[\delta], e[\intensity]]
}.asStream.all;
)

(
Pseed(Pseq([42]), Phawkes(0.1, 1.8, 2, length: 32, output: \time)).asStream.all;
)

(
Pseed(Pseq([42]), Phawkes([1, 0, 0], decay: 2,
    interactionMatrix: [[0, 0, 0], [0.8, 0, 0], [0, 0.8, 0]], length: 24
)).collect { |e| (time: e[\time], channel: e[\dimension]) }.asStream.all;
)

// Patternarium-Processes

(
Pseed(Pseq([42]), Prenewal(Pfunc {
    var u = 1.0.rand;
    while { u <= 0 } { u = 1.0.rand };
    u.log.neg / 4
}, length: 16)).asStream.all;
)

(
Pseed(Pseq([42]), Prenewal(Pfunc {
    Array.fill(3, {
        var u = 1.0.rand;
        while { u <= 0 } { u = 1.0.rand };
        u.log.neg / 12
    }).sum
}, length: 16)).asStream.all;
)

(
Pseed(Pseq([42]), Prenewal(Pfunc {
    var u = 1.0.rand;
    while { u <= 0 } { u = 1.0.rand };
    0.25 * u.log.neg.pow(1 / 1.5)
}, length: 16)).asStream.all;
)

(
Pseed(Pseq([42]), Prenewal(Pfunc {
    var u = 1.0.rand;
    while { u <= 0 } { u = 1.0.rand };
    0.1 + (u.log.neg / 8)
}, length: 16)).asStream.all;
)

(
Pseed(Pseq([42]), Prenewal(Pscan(Pseq([0], 16), (time: 0), { |state|
    var rate = 4 + (0.5 * (state[\time] * 0.2).sin), u = 1.0.rand, delta;
    while { u <= 0 } { u = 1.0.rand };
    delta = u.log.neg / rate;
    (time: state[\time] + delta, delta: delta)
}).collect { |state| state[\delta] })).asStream.all;
)

(
Pseed(Pseq([42]), Phawkes(1, 0.7, 1.2, length: 16)).asStream.all;
)

// Added sound companions. Load the Guide instruments first.

(
// Sound companion: PpointProcess / Value stream
var values = {
Prenewal(Pseq([0.25, 0.5, 0.125]), start: 2, output: \event).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: if(x.isKindOf(Dictionary)) { (x[\dimension] ? x[\channel] ? 0)*7 } { 0 }, dur: if(x.isKindOf(Dictionary)) { (x[\delta] ? 0.25)*0.5 } { if(x.isArray) { x[0]*0.5 } { x*0.5 } }, amp: 0.09)
}.play;
)

(
// Sound companion: Prenewal / Value stream
var values = {
Prenewal(Pseq([0.25, 0.5, 1]), output: \time).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
values = values.differentiate;
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: if(x.isKindOf(Dictionary)) { (x[\dimension] ? x[\channel] ? 0)*7 } { 0 }, dur: if(x.isKindOf(Dictionary)) { (x[\delta] ? 0.25)*0.5 } { if(x.isArray) { x[0]*0.5 } { x*0.5 } }, amp: 0.09)
}.play;
)

(
// Sound companion: Phawkes / Value stream
var values = {
Pseed(Pseq([42]), Phawkes(length: 8)).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: if(x.isKindOf(Dictionary)) { (x[\dimension] ? x[\channel] ? 0)*7 } { 0 }, dur: if(x.isKindOf(Dictionary)) { (x[\delta] ? 0.25)*0.5 } { if(x.isArray) { x[0]*0.5 } { x*0.5 } }, amp: 0.09)
}.play;
)

(
// Sound companion: Phawkes / Aftershock-like clustering
var values = {
Pseed(Pseq([42]), Phawkes(0.4, 0.8, 1.2, length: 24)).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: if(x.isKindOf(Dictionary)) { (x[\dimension] ? x[\channel] ? 0)*7 } { 0 }, dur: if(x.isKindOf(Dictionary)) { (x[\delta] ? 0.25)*0.5 } { if(x.isArray) { x[0]*0.5 } { x*0.5 } }, amp: 0.09)
}.play;
)

(
// Sound companion: Phawkes / Echo-like rhythmic proliferation
var values = {
Pseed(Pseq([42]), Phawkes(2, 1.2, 2, length: 24, output: \delta)).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: if(x.isKindOf(Dictionary)) { (x[\dimension] ? x[\channel] ? 0)*7 } { 0 }, dur: if(x.isKindOf(Dictionary)) { (x[\delta] ? 0.25)*0.5 } { if(x.isArray) { x[0]*0.5 } { x*0.5 } }, amp: 0.09)
}.play;
)

(
// Sound companion: Phawkes / Two-voice call and response
var values = {
Pseed(Pseq([42]), Phawkes([1, 0.1], decay: 2,
    interactionMatrix: [[0, 0.2], [1.2, 0]], length: 24)).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: if(x.isKindOf(Dictionary)) { (x[\dimension] ? x[\channel] ? 0)*7 } { 0 }, dur: if(x.isKindOf(Dictionary)) { (x[\delta] ? 0.25)*0.5 } { if(x.isArray) { x[0]*0.5 } { x*0.5 } }, amp: 0.09)
}.play;
)

(
// Sound companion: Phawkes / Local acceleration after events
var values = {
Pseed(Pseq([42]), Phawkes(1, 0.8, 1.5, length: 16)).collect { |e|
    [e[\delta], e[\intensity]]
}.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: if(x.isKindOf(Dictionary)) { (x[\dimension] ? x[\channel] ? 0)*7 } { 0 }, dur: if(x.isKindOf(Dictionary)) { (x[\delta] ? 0.25)*0.5 } { if(x.isArray) { x[0]*0.5 } { x*0.5 } }, amp: 0.09)
}.play;
)

(
// Sound companion: Phawkes / Bursts and sparse regions
var values = {
Pseed(Pseq([42]), Phawkes(0.1, 1.8, 2, length: 32, output: \time)).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
values = values.differentiate;
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: if(x.isKindOf(Dictionary)) { (x[\dimension] ? x[\channel] ? 0)*7 } { 0 }, dur: if(x.isKindOf(Dictionary)) { (x[\delta] ? 0.25)*0.5 } { if(x.isArray) { x[0]*0.5 } { x*0.5 } }, amp: 0.09)
}.play;
)

(
// Sound companion: Phawkes / Cross-channel triggering
var values = {
Pseed(Pseq([42]), Phawkes([1, 0, 0], decay: 2,
    interactionMatrix: [[0, 0, 0], [0.8, 0, 0], [0, 0.8, 0]], length: 24
)).collect { |e| (time: e[\time], channel: e[\dimension]) }.asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: if(x.isKindOf(Dictionary)) { (x[\dimension] ? x[\channel] ? 0)*7 } { 0 }, dur: if(x.isKindOf(Dictionary)) { (x[\delta] ? 0.25)*0.5 } { if(x.isArray) { x[0]*0.5 } { x*0.5 } }, amp: 0.09)
}.play;
)

(
// Sound companion: Patternarium-Processes / Exponential Poisson renewal timing
var values = {
Pseed(Pseq([42]), Prenewal(Pfunc {
    var u = 1.0.rand;
    while { u <= 0 } { u = 1.0.rand };
    u.log.neg / 4
}, length: 16)).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: if(x.isKindOf(Dictionary)) { (x[\dimension] ? x[\channel] ? 0)*7 } { 0 }, dur: if(x.isKindOf(Dictionary)) { (x[\delta] ? 0.25)*0.5 } { if(x.isArray) { x[0]*0.5 } { x*0.5 } }, amp: 0.09)
}.play;
)

(
// Sound companion: Patternarium-Processes / Gamma renewal timing
var values = {
Pseed(Pseq([42]), Prenewal(Pfunc {
    Array.fill(3, {
        var u = 1.0.rand;
        while { u <= 0 } { u = 1.0.rand };
        u.log.neg / 12
    }).sum
}, length: 16)).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: if(x.isKindOf(Dictionary)) { (x[\dimension] ? x[\channel] ? 0)*7 } { 0 }, dur: if(x.isKindOf(Dictionary)) { (x[\delta] ? 0.25)*0.5 } { if(x.isArray) { x[0]*0.5 } { x*0.5 } }, amp: 0.09)
}.play;
)

(
// Sound companion: Patternarium-Processes / Weibull renewal timing
var values = {
Pseed(Pseq([42]), Prenewal(Pfunc {
    var u = 1.0.rand;
    while { u <= 0 } { u = 1.0.rand };
    0.25 * u.log.neg.pow(1 / 1.5)
}, length: 16)).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: if(x.isKindOf(Dictionary)) { (x[\dimension] ? x[\channel] ? 0)*7 } { 0 }, dur: if(x.isKindOf(Dictionary)) { (x[\delta] ? 0.25)*0.5 } { if(x.isArray) { x[0]*0.5 } { x*0.5 } }, amp: 0.09)
}.play;
)

(
// Sound companion: Patternarium-Processes / Refractory-like timing
var values = {
Pseed(Pseq([42]), Prenewal(Pfunc {
    var u = 1.0.rand;
    while { u <= 0 } { u = 1.0.rand };
    0.1 + (u.log.neg / 8)
}, length: 16)).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: if(x.isKindOf(Dictionary)) { (x[\dimension] ? x[\channel] ? 0)*7 } { 0 }, dur: if(x.isKindOf(Dictionary)) { (x[\delta] ? 0.25)*0.5 } { if(x.isArray) { x[0]*0.5 } { x*0.5 } }, amp: 0.09)
}.play;
)

(
// Sound companion: Patternarium-Processes / Approximate time-varying rate
var values = {
Pseed(Pseq([42]), Prenewal(Pscan(Pseq([0], 16), (time: 0), { |state|
    var rate = 4 + (0.5 * (state[\time] * 0.2).sin), u = 1.0.rand, delta;
    while { u <= 0 } { u = 1.0.rand };
    delta = u.log.neg / rate;
    (time: state[\time] + delta, delta: delta)
}).collect { |state| state[\delta] })).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: if(x.isKindOf(Dictionary)) { (x[\dimension] ? x[\channel] ? 0)*7 } { 0 }, dur: if(x.isKindOf(Dictionary)) { (x[\delta] ? 0.25)*0.5 } { if(x.isArray) { x[0]*0.5 } { x*0.5 } }, amp: 0.09)
}.play;
)

(
// Sound companion: Patternarium-Processes / Self-correcting and self-exciting timing
var values = {
Pseed(Pseq([42]), Phawkes(1, 0.7, 1.2, length: 16)).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: if(x.isKindOf(Dictionary)) { (x[\dimension] ? x[\channel] ? 0)*7 } { 0 }, dur: if(x.isKindOf(Dictionary)) { (x[\delta] ? 0.25)*0.5 } { if(x.isArray) { x[0]*0.5 } { x*0.5 } }, amp: 0.09)
}.play;
)
