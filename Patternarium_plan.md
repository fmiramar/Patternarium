# Patternarium Quark

## Agentic implementation specification

## 1. Objective

Create a production-quality SuperCollider Quark containing new language-side Patterns for stateful stream computation, symbolic rewriting, mathematical sequences, temporal point processes, graph traversal, constrained generation, and selected models from computer science and natural sciences.

The Quark must be useful as a compositional library rather than as a catalogue of unrelated curiosities. Implement a small set of general mechanisms first, then build specialized Patterns on top of them wherever this does not damage clarity, performance, or semantics.

The complete project is called **Patternarium**.

The name should be used consistently for the repository, Quark metadata, Help guides, release notes, CI labels, and documentation. Do not retain “AlgorithmicPatterns” as a user-facing alias. Internal helper classes use the `PTR` prefix solely to reduce SuperCollider global-class-name collisions.

The implementation is entirely in `sclang`. Do not create UGens, server plugins, C++ code, GUI dependencies, or external-language dependencies. SynthDefs are permitted **only as documentation/example instruments**; they are not library dependencies and must not be installed as global runtime infrastructure by the Quark.

## 2. Agent model allocation and reasoning effort

The implementation may be carried out with either ChatGPT/OpenAI coding agents or Gemini coding agents. **Do not run both providers for every routine task.** Select one primary model for the task, complete the work, run the deterministic tests, and use the second provider only when the table explicitly recommends an independent review or when the primary model becomes stuck.

Model recommendations in this document are current as of **November 2026**. Prefer concrete model names over vague aliases such as `auto`, `pro`, or `flash`, because aliases may change underneath the project.

### 2.1 Available model tiers assumed by this plan

For ChatGPT / OpenAI agentic coding:

- **GPT-6 Astra** — reserve for difficult architecture, algorithmic correctness, subtle debugging, API design, and final review. Use `high` reasoning by default here; do not use `xhigh`/`max` unless a genuinely hard issue remains unresolved after tests and a `high` pass.
- **GPT-6.1 Sol** — default implementation model. Use `medium` for straightforward coding/documentation and `high` for stateful stream semantics or nontrivial algorithms.
- **GPT-6 Luna** — optional for mechanical cleanup only. Do not use it to design public Pattern semantics.

For Gemini agentic coding:

- **Gemini 3.8 Flash (`gemini-3.8-flash`)** — default implementation model. It is the preferred Gemini model for long-horizon software engineering. Use `medium` for normal implementation/documentation and `high` for difficult multi-step code or mathematics.
- **Gemini 3.1 Pro Preview (`gemini-3.1-pro-preview`)** — reserve for the hardest architecture, mathematical validation, and independent review. Use `high`. Because it is a preview model, do not make the project depend on behavior unique to this endpoint.

Gemini 3.8 Flash supports `low`, `medium`, and `high` thinking levels. Gemini 3.1 Pro Preview also supports `low`, `medium`, and `high`. The plan intentionally avoids asking for maximum reasoning on routine tasks.

**Model-selection source note:** these names and reasoning controls were checked against the official OpenAI model/Work documentation and Google Gemini model/thinking documentation in November 2026. Because model catalogs change, re-check these official pages before a long implementation run:

- OpenAI models: https://developers.openai.com/api/docs/models
- OpenAI Work/Codex model guidance: https://help.openai.com/en/articles/20001516-managing-usage-with-gpt-6-astra-in-work-and-codex
- Gemini models: https://ai.google.dev/gemini-api/docs/models
- Gemini thinking levels: https://ai.google.dev/gemini-api/docs/thinking
- Gemini CLI model selection: https://geminicli.com/docs/cli/model/

When using Gemini CLI, prefer selecting the concrete model explicitly when possible rather than relying on an `auto` alias.

### 2.2 Per-task model and effort recommendations

In the table below, the ChatGPT and Gemini columns are **alternatives**, not instructions to run both. “Cross-review” means that, after the primary implementation and tests pass, the other provider should inspect the specific high-risk area without rewriting working code gratuitously.

| Task | ChatGPT recommendation | Gemini recommendation | Cross-review? | Why |
|---|---|---|---|---|
| Repository/API/class-name audit | GPT-6 Astra — `high` | Gemini 3.1 Pro Preview — `high` | Yes | Requires broad comparison, API judgment, and avoiding semantic duplication. |
| Quark skeleton, metadata, folders, basic CI | GPT-6.1 Sol — `medium` | Gemini 3.8 Flash — `medium` | No | Mostly conventional repository work. |
| Test harness and stream-contract utilities | GPT-6.1 Sol — `high` | Gemini 3.8 Flash — `high` | Optional | Test semantics are foundational but implementation is contained. |
| `Pscan` | GPT-6.1 Sol — `high` | Gemini 3.8 Flash — `high` | Yes | Stateful recurrence and `inval`/termination semantics must be exact. |
| `Pwindow` | GPT-6.1 Sol — `medium` | Gemini 3.8 Flash — `medium` | No | Straightforward bounded lazy buffering. |
| `Ptransduce` | GPT-6.1 Sol — `high` | Gemini 3.8 Flash — `high` | Yes | Output cardinality and state transition protocol can become ambiguous. |
| `Pmorphism` | GPT-6 Astra — `high` | Gemini 3.1 Pro Preview — `high` | Yes | Lazy rewriting, context sensitivity, symbol age, and growth bounds are architecturally difficult. |
| `PdeBruijn` | GPT-6.1 Sol — `medium` | Gemini 3.8 Flash — `medium` | No | Standard combinatorial algorithm with strong finite test vectors. |
| `PgrayCode` | GPT-6.1 Sol — `high` | Gemini 3.8 Flash — `high` | Optional | Mixed-radix cyclic adjacency needs careful invariants. |
| `Pqmc` | GPT-6 Astra — `high` | Gemini 3.1 Pro Preview — `high` | Yes | Mathematical correctness, direction numbers/scrambling, provenance, and multidimensional tests are high risk. |
| `ProtationWord` | GPT-6.1 Sol — `high` | Gemini 3.8 Flash — `high` | Optional | Irrational rotation, partitions, finite precision, and symbolic coding need careful tests. |
| `PnumSeq` framework | GPT-6.1 Sol — `medium` | Gemini 3.8 Flash — `medium` | No | Registry/interface work is straightforward once recurrence infrastructure exists. |
| Each `PnumSeq` algorithm | GPT-6.1 Sol — `medium` | Gemini 3.8 Flash — `medium` | Only for unclear sequences | Implement from authoritative definitions and verify known prefixes. |
| `PpointProcess` abstraction | GPT-6.1 Sol — `high` | Gemini 3.8 Flash — `high` | Optional | Must establish clean absolute-time vs inter-arrival semantics. |
| `Prenewal` | GPT-6.1 Sol — `high` | Gemini 3.8 Flash — `high` | No | Probability/distribution semantics are nontrivial but well bounded. |
| `Phawkes` | GPT-6 Astra — `high` | Gemini 3.1 Pro Preview — `high` | Yes | Stability, self-/cross-excitation, inhibition, and event explosion safeguards require deep review. |
| `Pconstraint` | GPT-6 Astra — `high` | Gemini 3.1 Pro Preview — `high` | Yes | Search semantics, bounded backtracking, failure behavior, and lazy generation are difficult. |
| `PgraphWalk` | GPT-6.1 Sol — `high` | Gemini 3.8 Flash — `high` | Optional | Multiple walk policies and stream-local graph state require careful isolation. |
| `Pvomm` | GPT-6 Astra — `high` | Gemini 3.1 Pro Preview — `high` | Yes | Variable-order context fallback, PPM escape handling, learning, and reproducibility are subtle. |
| `Ppetri` | GPT-6 Astra — `high` | Gemini 3.1 Pro Preview — `high` | Yes | Concurrent enablement/firing semantics and token accounting need precise formalization. |
| `Pkuramoto` | GPT-6 Astra — `high` | Gemini 3.1 Pro Preview — `high` | Yes | Numerical integration, phase wrapping, synchronization metrics, and step-size behavior need mathematical validation. |
| `Pbranching` | GPT-6.1 Sol — `high` | Gemini 3.8 Flash — `high` | Optional | Tree ownership, traversal, extinction, and bounded growth are the main risks. |
| `Psandpile` | GPT-6.1 Sol — `high` | Gemini 3.8 Flash — `high` | Optional | Stabilization and avalanche accounting need deterministic invariants. |
| Four demonstration SynthDefs (`fmPiano`, `saw`, `mallet`, `farfisa`) | GPT-6.1 Sol — `low` or `medium` | Gemini 3.8 Flash — `low` or `medium` | No | They are intentionally simple Help fixtures, not synthesis research. |
| Per-class SCDoc prose | GPT-6.1 Sol — `medium` | Gemini 3.8 Flash — `medium` | No | Requires clarity and SC idiom, not maximal reasoning. |
| Required application examples in Help | GPT-6.1 Sol — `medium`; `high` only for mathematically difficult examples | Gemini 3.8 Flash — `medium`; `high` when necessary | No | Keep examples short and executable; do not burn high-reasoning tokens on routine variants. |
| Documentation style pass | GPT-6.1 Sol — `medium` | Gemini 3.8 Flash — `medium` | Optional | Check for native SC Help style, minimalism, and independent evaluability. |
| Cross-class integration tests | GPT-6.1 Sol — `high` | Gemini 3.8 Flash — `high` | Optional | Important for state isolation, nesting, reset, and reproducibility. |
| Difficult failing test / subtle runtime bug | GPT-6 Astra — `high` | Gemini 3.1 Pro Preview — `high` | Yes if still unresolved | Escalate only after reproducing the bug minimally. |
| Performance and bounded-memory audit | GPT-6 Astra — `high` | Gemini 3.8 Flash — `high` | Yes for suspicious cases | Review infinite streams, growth, search budgets, and allocation hotspots. |
| Cross-platform CI fixes | GPT-6.1 Sol — `medium` initially; `high` if platform-specific behavior is unclear | Gemini 3.8 Flash — `medium`/`high` | No by default | Usually mechanical until evidence shows a deeper language/runtime issue. |
| Final public API freeze and v1.0 review | GPT-6 Astra — `high` | Gemini 3.1 Pro Preview — `high` | Yes | Public constructor semantics become expensive to change after release. |
| Release notes / changelog cleanup | GPT-6.1 Sol — `low` or `medium` | Gemini 3.8 Flash — `low` or `medium` | No | Mechanical summarization after code is frozen. |

### 2.3 Escalation rule

Do **not** escalate merely because a task is long. Escalate from Sol/3.8 Flash to Astra/3.1 Pro only when at least one of these is true:

- The public semantics are still ambiguous after reading core Pattern implementations.
- A deterministic test exposes contradictory behavior.
- The algorithm has numerical-stability or probabilistic-correctness risks.
- The implementation manipulates several interacting state machines.
- A bug survives a minimal reproduction and one serious debugging pass.
- A release would freeze an API whose consequences have not been adequately reviewed.

When cross-review is requested, give the reviewer the implementation, tests, relevant reference definition, and the specific invariant to inspect. Do not ask it to “reimplement from scratch” unless the first implementation is demonstrably unsound.

## 3. Compatibility and license

Target:

- SuperCollider 3.14.x.
- The current SuperCollider `develop` branch where no incompatible language change is required.
- Linux, macOS, and Windows.
- Headless `sclang` use.

Use `GPL-3.0-or-later` for the repository unless the repository owner explicitly selects another SuperCollider-compatible license.

Do not copy implementations from projects with incompatible or unclear licenses. Mathematical definitions may be implemented independently from published descriptions. Record the source of any tables, constants, direction-number files, or test vectors added to the repository.

## 4. Required development method

Implement the project in small, reviewable milestones. For every public class:

1. Write deterministic tests first.
2. Implement only enough code to satisfy the specified semantics.
3. Add boundary and failure tests.
4. Add SCDoc documentation.
5. Add the full required Help example set specified in Part V: one minimal value-stream example, one minimal musical example when appropriate, and one runnable example for **every advertised application/use case** of that Pattern.
6. Run the complete test suite before committing.
7. Do not begin the next milestone while the current milestone has failing tests.

Use one public class per `.sc` file and one test class per public class unless a class becomes large enough to justify several focused test files.

## 5. Preliminary audit

Before adding any class, audit SuperCollider core, the currently installed extensions, the Community Quark Directory, and public repositories for exact class-name collisions and substantial semantic duplication.

Provisional names:

```text
Pscan
Pwindow
Ptransduce
Pmorphism
PdeBruijn
PgrayCode
Pqmc
ProtationWord
PnumSeq
PpointProcess
Prenewal
Phawkes
Pconstraint
PgraphWalk
Pvomm
Ppetri
Pkuramoto
Pbranching
Psandpile
```

Evaluate existing classes before installing the Quark. Because unresolved class references prevent compilation, the audit script must query symbols safely:

```supercollider
[
    \Pscan,
    \Pwindow,
    \Ptransduce,
    \Pmorphism,
    \PdeBruijn,
    \PgrayCode,
    \Pqmc,
    \ProtationWord,
    \PnumSeq,
    \PpointProcess,
    \Prenewal,
    \Phawkes,
    \Pconstraint,
    \PgraphWalk,
    \Pvomm,
    \Ppetri,
    \Pkuramoto,
    \Pbranching,
    \Psandpile
].do { |name|
    var class = name.asClass;
    if(class.notNil) {
        [name, class.filenameSymbol].postln;
    };
};
```

If a collision exists, use the following fallback only after confirming that the existing class cannot be reused or extended safely:

| Provisional | Fallback |
|---|---|
| `Pscan` | `PstateScan` |
| `Pwindow` | `PstreamWindow` |
| `Ptransduce` | `PstateTransduce` |
| `Pmorphism` | `PsymbolMorph` |
| `PdeBruijn` | `PdeBruijnCycle` |
| `PgrayCode` | `PmixedGrayCode` |
| `Pqmc` | `PlowDiscrepancy` |
| `ProtationWord` | `PcircleWord` |
| `PnumSeq` | `PnumberSequence` |
| `PpointProcess` | `PtemporalPointProcess` |
| `Prenewal` | `PrenewalProcess` |
| `Phawkes` | `PhawkesProcess` |
| `Pconstraint` | `PconstraintSolve` |
| `PgraphWalk` | `PweightedGraphWalk` |
| `Pvomm` | `PvariableMarkov` |
| `Ppetri` | `PpetriNet` |
| `Pkuramoto` | `PphaseNetwork` |
| `Pbranching` | `PbranchingProcess` |
| `Psandpile` | `PsandpileAvalanche` |

Do not create prefixed duplicates merely to avoid research. Document the audit in `docs/class-name-audit.md`.

## 6. Repository structure

```text
Patternarium/
├── Patternarium.quark
├── Classes/
│   ├── Foundations/
│   │   ├── Pscan.sc
│   │   ├── Pwindow.sc
│   │   ├── Ptransduce.sc
│   │   └── Pmorphism.sc
│   ├── Sequences/
│   │   ├── PdeBruijn.sc
│   │   ├── PgrayCode.sc
│   │   ├── Pqmc.sc
│   │   ├── ProtationWord.sc
│   │   └── PnumSeq.sc
│   ├── Processes/
│   │   ├── PpointProcess.sc
│   │   ├── Prenewal.sc
│   │   └── Phawkes.sc
│   ├── Systems/
│   │   ├── Pconstraint.sc
│   │   ├── PgraphWalk.sc
│   │   ├── Pvomm.sc
│   │   ├── Ppetri.sc
│   │   ├── Pkuramoto.sc
│   │   ├── Pbranching.sc
│   │   └── Psandpile.sc
│   └── Private/
│       ├── PTRValidation.sc
│       ├── PTRGraph.sc
│       ├── PTRPointProcess.sc
│       ├── PTRVommModel.sc
│       └── PTRSequenceAlgorithms.sc
├── HelpSource/
│   ├── Classes/
│   ├── Guides/
│   │   ├── Patternarium.schelp
│   │   ├── Patternarium-Foundations.schelp
│   │   ├── Patternarium-Sequences.schelp
│   │   └── Patternarium-Processes.schelp
│   └── Reference/
│       └── Patternarium-Protocols.schelp
├── Tests/
│   ├── TestPscan.sc
│   ├── TestPwindow.sc
│   ├── TestPtransduce.sc
│   ├── TestPmorphism.sc
│   ├── TestPdeBruijn.sc
│   ├── TestPgrayCode.sc
│   ├── TestPqmc.sc
│   ├── TestProtationWord.sc
│   ├── TestPnumSeq.sc
│   ├── TestPrenewal.sc
│   ├── TestPhawkes.sc
│   ├── TestPconstraint.sc
│   ├── TestPgraphWalk.sc
│   ├── TestPvomm.sc
│   ├── TestPpetri.sc
│   ├── TestPkuramoto.sc
│   ├── TestPbranching.sc
│   └── TestPsandpile.sc
├── examples/
│   ├── foundations.scd
│   ├── sequences.scd
│   ├── point-processes.scd
│   └── systems.scd
├── docs/
│   ├── class-name-audit.md
│   ├── algorithm-notes.md
│   └── release-checklist.md
├── README.md
├── CHANGELOG.md
├── LICENSE
└── .github/workflows/test.yml
```

Private helper classes still occupy SuperCollider's global class namespace. Prefix every private helper with `PTR` and include them in the collision audit.

## 7. Quark metadata

Create `Patternarium.quark` with current Quark metadata conventions:

```supercollider
(
    name: "Patternarium",
    path: "Patternarium",
    summary: "Stateful, mathematical, stochastic and structural Patterns for SuperCollider.",
    author: "PROJECT_OWNER",
    version: "0.1.0",
    schelp: "Patternarium",
    url: "PROJECT_URL",
    license: "GPL-3.0-or-later",
    dependencies: []
)
```

Verify the accepted key and version types against the installed SuperCollider version. Do not preserve obsolete metadata fields merely because an old Quark uses them.

The Quark must have no mandatory dependency other than SuperCollider. Unit tests may rely on the bundled `UnitTest` framework.

## 8. Pattern implementation contract

Every public Pattern must follow SuperCollider stream semantics.

### 8.1 `embedInStream`

Prefer `embedInStream` over custom `asStream` unless a specialized Stream class gives a measurable benefit.

The normal structure is:

```supercollider
embedInStream { |inval|
    var stream = pattern.asStream;
    var value;

    loop {
        value = stream.next(inval);
        if(value.isNil) { ^inval };
        inval = value.yield;
    };
}
```

### 8.2 `inval`

- Pass the latest `inval` to every input stream.
- Return `inval` when the Pattern ends.
- Do not return an internal state object accidentally.
- A zero-length Pattern must yield nothing and return its incoming value.

### 8.3 `nil`

`nil` terminates a Stream. Do not use bare `nil` as ordinary output. Where an algorithm needs “no emission,” use an explicit protocol rather than yielding `nil`.

### 8.4 Independent streams

All mutable iteration state must be local to `embedInStream` or to a newly created private state object. Two streams created from the same Pattern must evolve independently.

### 8.5 Pattern-valued arguments

Support Pattern-valued arguments only where their evaluation semantics are clear.

- Parameters evaluated once at stream creation should use `.value(inval)`.
- Parameters evaluated at every item should use `.asStream` and `.next(inval)`.
- Document which behavior applies to every argument.
- Do not claim an argument accepts a Pattern if the implementation only evaluates it once as an ordinary object.

### 8.6 Randomness

Random algorithms must be reproducible with `Pseed` and `thisThread.randSeed`.

- Do not create an unrelated system RNG.
- Do not use wall-clock time as an implicit seed.
- Tests must set a fixed seed.
- A seeded Pattern must produce the same sequence after a new `asStream` under the same seed.

### 8.7 Validation

Reject invalid constructor values early when possible. Use descriptive `Error` messages containing the class and argument name.

Validate again at stream creation for Function- or Pattern-derived parameters.

### 8.8 Events and cleanup

Most classes in this Quark are value Patterns and require no `EventStreamCleanup`.

Use `EventStreamCleanup` only when a Pattern may truncate or replace a nested event stream that owns resources. Do not introduce a new `Pscope` class unless a concrete behavior is demonstrated that cannot be expressed correctly with `Pprotect`, `Pproto`, `Pspawner`, and `EventStreamCleanup`.

## 9. Public API overview

| Class | Purpose | Initial status |
|---|---|---|
| `Pscan` | Stateful recurrence over an input Pattern | Required |
| `Pwindow` | Lazy overlapping windows | Required |
| `Ptransduce` | Stateful zero/one/many stream transformation | Required |
| `Pmorphism` | Parallel symbolic rewriting | Required |
| `PdeBruijn` | De Bruijn cycles | Required |
| `PgrayCode` | Mixed-radix Gray traversal | Required |
| `Pqmc` | Low-discrepancy multidimensional points | Required |
| `ProtationWord` | Mechanical and circle-rotation words | Required |
| `PnumSeq` | Curated numerical sequences | Required |
| `PpointProcess` | Abstract point-process base | Internal public base |
| `Prenewal` | Renewal processes | Required |
| `Phawkes` | Exponential-kernel Hawkes process | Required |
| `Pconstraint` | Bounded finite sequential constraint solver | Required |
| `PgraphWalk` | General graph traversal Pattern | Required |
| `Pvomm` | Variable-order Markov generation | Experimental |
| `Ppetri` | Petri-net transition firing | Experimental |
| `Pkuramoto` | Coupled phase-oscillator state Pattern | Experimental |
| `Pbranching` | Bounded branching process | Experimental |
| `Psandpile` | Sandpile avalanche process | Experimental |

“Experimental” means the class must still be implemented, tested, and documented, but its API may change before 1.0.

# Part I — Foundations

## 10. `Pscan`

### 10.1 Purpose

Generalize running accumulation and discrete state recurrence:

```text
nextState = function(state, input, index, inval)
```

### 10.2 Constructor

```supercollider
Pscan(pattern, initial, function, length: inf, includeInitial: false)
```

Arguments:

- `pattern`: input Pattern.
- `initial`: initial state, evaluated once with `.value(inval)`.
- `function`: receives `state`, `input`, zero-based `index`, and `inval`; returns the next state.
- `length`: maximum number of transition outputs; evaluated once. `inf` means source-controlled termination.
- `includeInitial`: when true, yield the initial state before consuming the source. The initial yield does not count against `length`.

### 10.3 Semantics

- The first consumed source item uses `index = 0`.
- Yield each next state.
- If the source ends, return `inval`.
- If `function` returns `nil`, terminate without yielding `nil`.
- `length = 0` consumes no source values.
- State may be any object.
- Do not copy the state automatically. Document that mutating a shared initial object can create shared external state; functional transitions are recommended.

### 10.4 Minimal examples

```supercollider
Pscan(Pseq([1, 2, 3]), 0, { |state, input| state + input }).asStream.all;
```

Expected:

```text
[1, 3, 6]
```

```supercollider
(
Pbind(
    \degree, Pscan(Pwhite(-2, 2), 0, { |state, input| (state + input).fold(-7, 7) }),
    \dur, 0.125
).play;
)
```

### 10.5 Required tests

- Finite accumulation.
- Infinite source with finite `length`.
- Zero length.
- `includeInitial` behavior.
- Source termination.
- Transition returning `nil`.
- Index values.
- `inval` propagation.
- Two independent streams.
- Reset through a new `asStream`.
- Function-derived initial state.
- Event-valued state.

## 11. `Pwindow`

### 11.1 Purpose

Create lazy fixed-size sliding windows over any Pattern without materializing the complete source.

### 11.2 Constructor

```supercollider
Pwindow(pattern, size, step: 1, partial: false)
```

Arguments:

- `pattern`: source Pattern.
- `size`: positive integer evaluated once at stream creation.
- `step`: positive integer evaluated once at stream creation.
- `partial`: when true, emit one final incomplete window after source termination if at least one un-emitted item remains.

### 11.3 Semantics

- Yield Arrays.
- Every yielded Array must be a fresh object.
- `step < size` produces overlap.
- `step == size` behaves like fixed clumping, except for the explicit `partial` rule.
- `step > size` skips `step - size` source values between windows.
- Do not produce leading partial windows.
- When a full window was just yielded and the source ends with no new item, do not duplicate it as a partial window.
- Reject nonpositive or noninteger `size` and `step`.

### 11.4 Minimal examples

```supercollider
Pwindow(Pseries(0, 1, 6), 3, 1).asStream.all;
```

Expected:

```text
[[0, 1, 2], [1, 2, 3], [2, 3, 4], [3, 4, 5]]
```

```supercollider
Pwindow(Pseries(0, 1, 7), 3, 3, true).asStream.all;
```

Expected:

```text
[[0, 1, 2], [3, 4, 5], [6]]
```

### 11.5 Required tests

- Overlapping windows.
- Non-overlapping windows.
- Gapped windows.
- Source shorter than `size` with both partial modes.
- Exact final window.
- Final incomplete window.
- Fresh Array identity.
- Invalid size and step.
- Event inputs.
- `inval` propagation.
- Two independent streams.

## 12. `Ptransduce`

### 12.1 Purpose

Consume one source item at a time while maintaining state and emitting zero, one, or many output items.

### 12.2 Constructor

```supercollider
Ptransduce(pattern, initial, function, flush: nil)
```

Arguments:

- `pattern`: source Pattern.
- `initial`: initial state evaluated once.
- `function`: receives `state`, `input`, zero-based `index`, and `inval`.
- `flush`: optional Function called once when the source terminates; receives `state`, final index, and `inval`.

### 12.3 Step protocol

The transition and flush Functions return an Event:

```supercollider
(
    state: newState,
    emit: [valueA, valueB],
    stop: false
)
```

Rules:

- `state` is required unless `stop` is true and no further state is needed.
- `emit: nil` or `emit: []` emits nothing.
- `emit` must be a SequenceableCollection.
- To emit an Array as one output item, wrap it once: `emit: [[1, 2, 3]]`.
- `stop: true` emits the specified values, then terminates.
- Returning `nil` is equivalent to immediate termination with no output.
- Unknown keys are ignored, allowing user metadata.

Create a private validator for this protocol. Do not add a public result class unless Events prove measurably inadequate.

### 12.4 Minimal examples

```supercollider
Ptransduce(
    Pseq([1, 1, 0, 0, 0, 1]),
    (last: nil, count: 0),
    { |state, input|
        var changed = state[\last].notNil and: { state[\last] != input };
        (
            state: (last: input, count: state[\count] + 1),
            emit: if(changed) { [input] } { [] }
        )
    }
).asStream.all;
```

```supercollider
Ptransduce(
    Pseries(1, 1, 8),
    [],
    { |state, input|
        var next = state.add(input);
        if(next.size == 3) {
            (state: [], emit: [next])
        } {
            (state: next, emit: [])
        }
    },
    { |state|
        (state: state, emit: if(state.isEmpty) { [] } { [state] })
    }
).asStream.all;
```

### 12.5 Required tests

- Zero emission.
- One emission.
- Several emissions.
- Array emitted as one item.
- Stop after emissions.
- `nil` transition termination.
- Flush at natural source end.
- No flush after explicit stop.
- Invalid protocol errors.
- State independence.
- `inval` updates after every yielded item.

## 13. `Pmorphism`

### 13.1 Purpose

Implement parallel symbolic rewriting with deterministic, functional, context-sensitive, and Pattern-valued rules.

Do not duplicate `Prewrite` internally without adding the specified semantics.

### 13.2 Constructor

```supercollider
Pmorphism(
    seed,
    rules,
    generations: 1,
    output: \symbols,
    includeSeed: false,
    maxSymbols: 100000
)
```

Arguments:

- `seed`: a symbol, value, SequenceableCollection, or Pattern producing generations.
- `rules`: Dictionary or Event keyed by source symbol.
- `generations`: nonnegative integer or `inf`.
- `output`: `\symbols` or `\generations`.
- `includeSeed`: include generation zero.
- `maxSymbols`: hard per-generation safety limit.

### 13.3 Rule forms

A rule value may be:

- A scalar replacement.
- A SequenceableCollection replacement.
- A Pattern that produces the replacement values for that application.
- A Function receiving:

```supercollider
{ |symbol, left, right, generation, index, inval| ... }
```

`left` and `right` are neighboring symbols or `nil` at boundaries.

A missing rule preserves the symbol.

Pattern-valued and Function-produced replacements are evaluated independently for every rule application. They must be finite. If a replacement Pattern does not end before `maxSymbols`, throw a bounded-expansion error.

### 13.4 Generation and output semantics

- Rewriting is parallel: all rules inspect the same current generation.
- `\generations` yields one fresh Array per generation.
- `\symbols` embeds the symbols of each selected generation before computing the next.
- `generations = 0` yields only the seed when `includeSeed` is true.
- `generations = inf` is allowed only with explicit `maxSymbols`; terminate with an error when the limit is exceeded.
- Do not implement symbol-age or delayed rewriting in the first commit. Add it only in a later API extension after the base semantics are stable.

### 13.5 Minimal examples

```supercollider
Pmorphism(
    [\a],
    (a: [\a, \b], b: [\a]),
    5,
    \generations,
    true
).asStream.all;
```

```supercollider
(
Pbind(
    \degree, Pmorphism([0], (0: [0, 2], 2: [3, 0]), 6),
    \dur, 0.125
).play;
)
```

### 13.6 Required tests

- Deterministic rules.
- Missing-rule preservation.
- Parallel rather than sequential rewriting.
- Function context at boundaries and center.
- Pattern-valued replacement.
- Zero generations.
- Seed inclusion.
- Both output modes.
- Expansion limit.
- Empty generation.
- Independent streams.
- Seed supplied by a finite Pattern.

# Part II — Mathematical sequences

## 14. `PdeBruijn`

### 14.1 Constructor

```supercollider
PdeBruijn(alphabet, order, repeats: 1, rotation: 0)
```

### 14.2 Requirements

- `alphabet` must be a nonempty SequenceableCollection of unique values.
- `order` must be a positive integer.
- Generate a cyclic De Bruijn sequence of length `alphabet.size ** order`.
- Use an efficient FKM or equivalent necklace algorithm.
- Do not build all possible words.
- `rotation` rotates the resulting cycle modulo its length.
- `repeats` follows normal list-Pattern semantics.
- Preserve arbitrary alphabet objects.

### 14.3 Validation property

For every result, verify in tests that every cyclic word of length `order` occurs exactly once.

### 14.4 Minimal example

```supercollider
PdeBruijn([0, 1], 3).asStream.all;
```

## 15. `PgrayCode`

### 15.1 Constructor

```supercollider
PgrayCode(radices, repeats: 1)
```

### 15.2 Requirements

- `radices` is a nonempty collection of integers greater than one.
- Output one Array per state.
- Enumerate every mixed-radix state exactly once.
- Adjacent states must differ in exactly one coordinate by exactly one unit.
- Do not claim that the end-to-start boundary is Gray-adjacent for every radix configuration.
- A repeated traversal begins again at the initial state; document any boundary jump.
- Use a loopless or amortized constant-time algorithm if practical.

### 15.3 Minimal example

```supercollider
PgrayCode([2, 3]).asStream.all;
```

### 15.4 Required tests

- Binary reflected code.
- Mixed radix.
- Correct state count.
- Uniqueness.
- One-coordinate adjacency.
- Repetition.
- Invalid radices.
- Fresh output Arrays.

## 16. `Pqmc`

### 16.1 Constructor

```supercollider
Pqmc(
    dimensions: 1,
    engine: \halton,
    length: inf,
    scramble: false,
    skip: 0,
    leap: 1
)
```

### 16.2 Engines

Required for the first stable release:

- `\halton`
- `\additive`

Optional after the required engines are correct:

- `\hammersley`, requiring finite `length`
- `\sobol`, only after licensing and provenance of direction numbers are documented

Do not label an approximate or improvised generator as Sobol.

### 16.3 Requirements

- Output Arrays of Floats in `[0, 1)`.
- `dimensions` is a positive integer.
- `length` may be finite or infinite except for Hammersley.
- `skip` is a nonnegative integer.
- `leap` is a positive integer.
- Halton bases are consecutive primes generated internally.
- Unscrambled Halton must match published reference vectors.
- Scrambling must be deterministic under `Pseed`.
- The additive engine uses a documented irrational additive recurrence generalized to the requested dimension.
- Avoid global caches whose mutation changes future stream results.

### 16.4 Minimal example

```supercollider
Pqmc(2, \halton, 8).asStream.all;
```

```supercollider
(
Pbind(
    [\degree, \pan], Pqmc(2).collect { |point|
        [point[0].linlin(0, 1, 0, 14), point[1].linlin(0, 1, -1, 1)]
    },
    \dur, 0.125
).play;
)
```

### 16.5 Required tests

- Published Halton vectors.
- Range.
- Dimensions.
- Skip and leap.
- Finite length.
- Scramble reproducibility.
- Two streams under controlled seeds.
- Prime generation beyond a small fixed list.
- Invalid engine and arguments.

## 17. `ProtationWord`

### 17.1 Constructor

```supercollider
ProtationWord(
    alpha,
    phase: 0,
    length: inf,
    cuts: nil
)
```

### 17.2 Modes

When `cuts` is `nil`, generate the lower mechanical binary word:

```text
floor((n + 1) * alpha + phase) - floor(n * alpha + phase)
```

When `cuts` is a sorted collection in `(0, 1)`, iterate an irrational or rational circle rotation and emit the zero-based interval index.

### 17.3 Requirements

- Normalize `alpha` and `phase` modulo one.
- `cuts` must be strictly increasing and contain no endpoints.
- Rational `alpha` is valid and produces a periodic word.
- Irrational `alpha` produces an aperiodic coding within floating-point limits.
- Do not call every output a Sturmian word. Reserve that term for the appropriate irrational binary mechanical case.

### 17.4 Minimal examples

```supercollider
ProtationWord((5.sqrt - 1) / 2, length: 16).asStream.all;
```

```supercollider
ProtationWord(2.sqrt - 1, cuts: [0.25, 0.7], length: 16).asStream.all;
```

## 18. `PnumSeq`

### 18.1 Purpose

Provide a curated registry of important numerical and symbolic sequences without creating one global class per sequence.

### 18.2 Constructor

```supercollider
PnumSeq(name, seed: nil, length: inf, options: ())
```

### 18.3 Required names

Implement:

```text
recaman
vanEck
golomb
kolakoski
paperfolding
rudinShapiro
stern
calkinWilf
lookAndSay
norgard
```

Use Symbols as names.

### 18.4 Sequence definitions

Document exact indexing, initial terms, and output type for every sequence. Tests must use independent published reference terms.

Minimum semantics:

- `\recaman`: default seed `0`; use a Set for membership.
- `\vanEck`: default seed `[0]`; track most recent positions efficiently.
- `\golomb`: positive integer self-describing sequence.
- `\kolakoski`: default alphabet `[1, 2]` and standard seed.
- `\paperfolding`: regular paperfolding sequence using an index formula where practical.
- `\rudinShapiro`: output `1` and `-1` by default; allow `binary: true`.
- `\stern`: Stern's diatomic sequence.
- `\calkinWilf`: output rational pairs `[numerator, denominator]` to avoid premature Float conversion.
- `\lookAndSay`: output one term Array per item, not flattened digits; enforce `maxTermSize` in options.
- `\norgard`: Per Nørgård infinity series.

### 18.5 Requirements

- Unknown names throw an error listing valid names.
- Keep dispatch internal and immutable after class initialization.
- Do not expose a mutable global registry in the first release.
- Clearly document which sequences require unbounded memory.
- Reject seeds incompatible with a selected sequence.

# Part III — Temporal point processes

## 19. `PpointProcess`

Implement `PpointProcess` as an abstract Pattern base for time-based processes. It should centralize:

- `start`
- `length`
- Output conversion
- Positive-time validation
- Event construction

Supported output modes:

```text
\delta
\time
\event
```

Event output must contain:

```supercollider
(
    time: absoluteTime,
    delta: interArrivalTime
)
```

Subclasses may add keys.

Do not make `PpointProcess.new` directly useful unless there is a complete general sampler API.

## 20. `Prenewal`

### 20.1 Constructor

```supercollider
Prenewal(
    distribution,
    start: 0,
    length: inf,
    output: \delta
)
```

### 20.2 Semantics

- `distribution` is a Pattern producing strictly positive inter-arrival times.
- Each arrival time is the cumulative sum starting from `start`.
- `\delta` outputs intervals.
- `\time` outputs absolute arrival times.
- `\event` outputs Events with `time` and `delta`.
- Terminate when the distribution ends.
- Reject zero, negative, `NaN`, and infinite intervals.

### 20.3 Minimal example

```supercollider
Prenewal(Pexprand(0.05, 1), length: 16).asStream.all;
```

## 21. `Phawkes`

### 21.1 Scope

Implement a univariate and multivariate linear Hawkes process with exponential kernels using Ogata-style thinning or another exact method for the chosen kernel.

The first stable implementation supports nonnegative excitation only. Do not advertise inhibition as ordinary Hawkes behavior.

### 21.2 Constructor

```supercollider
Phawkes(
    baseRate: 1,
    excitation: 0.5,
    decay: 1,
    dimensions: 1,
    interactionMatrix: nil,
    start: 0,
    length: inf,
    output: \event,
    allowUnstable: false,
    maxIntensity: 100000
)
```

### 21.3 Parameters

- Scalar mode uses `baseRate`, `excitation`, and `decay`.
- Multivariate mode accepts scalar or per-dimension `baseRate` and `decay`.
- `interactionMatrix[i][j]` is the excitation added to dimension `i` by an event in dimension `j`.
- When `interactionMatrix` is supplied, it determines `dimensions` after validation.

### 21.4 Event output

```supercollider
(
    time: absoluteTime,
    delta: interArrivalTime,
    dimension: dimensionIndex,
    intensity: acceptedIntensity
)
```

Other output modes may return only one field, but `\event` is the default.

### 21.5 Stability and safety

- Scalar stationary condition: excitation divided by decay must be less than one.
- Multivariate stationary condition: estimate or compute the spectral radius of the integrated kernel matrix and require it to be below one.
- Throw by default when the process is unstable.
- Allow explicit override with `allowUnstable: true`.
- Stop with a descriptive error if intensity exceeds `maxIntensity`.
- Reject negative rates, excitation, or decay.

### 21.6 Tests

- No excitation approximates an exponential renewal process under a fixed seed and shared sampler assumptions.
- Scalar deterministic reference trace under a fixed seed.
- Multivariate dimension selection.
- Stability rejection.
- Intensity cap.
- Positive deltas and monotonic times.
- Reproducibility.
- Output modes.

# Part IV — Structural systems

## 22. `Pconstraint`

### 22.1 Scope

Implement a bounded finite sequential constraint solver. Do not present it as a complete general-purpose CSP engine.

A solver cannot safely backtrack over values that have already been yielded. Therefore, solve a complete finite sequence before yielding it.

### 22.2 Constructor

```supercollider
Pconstraint(
    domain,
    constraints,
    length,
    solutions: 1,
    randomize: false,
    maxBacktracks: 10000,
    failure: \empty,
    output: \solution
)
```

### 22.3 Domain

`domain` may be:

- A Collection reused at every position.
- A Function receiving `index`, partial `history`, and `inval`, returning a finite Collection.
- A Pattern producing one finite Collection per position.

Copy candidate collections before randomization.

### 22.4 Constraints

`constraints` is a Function or Collection of Functions:

```supercollider
{ |history, candidate, index, inval| true }
```

Every constraint is evaluated against the partial solution before the candidate is appended.

### 22.5 Output

- `\solution` yields one complete solution Array per item.
- `\values` embeds every value of every solution.
- Fresh Arrays are required.

### 22.6 Failure

- `\empty`: yield nothing.
- `\warn`: warn and yield nothing.
- `\error`: throw an Error.

Exhaustion of `maxBacktracks` is a distinct bounded-search failure and must be reported clearly.

### 22.7 Minimal example

```supercollider
Pconstraint(
    [0, 1, 2, 3],
    { |history, candidate|
        history.isEmpty or: { (candidate - history.last).abs > 1 }
    },
    5
).asStream.all;
```

### 22.8 Tests

- Solvable sequence.
- Impossible sequence.
- Multiple constraints.
- Position-dependent domain.
- Multiple solutions.
- No mutation of caller domain.
- Randomization reproducibility.
- Backtrack limit.
- Both output modes.

## 23. `PgraphWalk`

### 23.1 Constructor

```supercollider
PgraphWalk(
    graph,
    start,
    length: inf,
    strategy: \weighted,
    memory: 0,
    reinforcement: 0,
    taboo: nil,
    deadEnd: \stop,
    output: \node,
    includeStart: true
)
```

### 23.2 Graph representation

Accept a Dictionary or Event mapping each node to an adjacency collection.

Normalize adjacency entries from:

```supercollider
\b
[\b, 0.5]
(to: \b, weight: 0.5, data: (interval: 7))
```

Normalized edge data:

```supercollider
(
    from: source,
    to: destination,
    weight: 1.0,
    data: nil
)
```

### 23.3 Strategies

Required:

- `\uniform`
- `\weighted`
- `\nonBacktracking`
- `\selfAvoiding`
- `\reinforced`

Definitions:

- `\nonBacktracking` excludes the immediately previous node when alternatives exist.
- `\selfAvoiding` excludes all visited nodes and terminates or applies `deadEnd` when none remain.
- `\reinforced` adds `reinforcement` to an edge's effective weight after traversal.

### 23.4 Other semantics

- `memory > 0` excludes the last `memory` nodes when alternatives exist.
- `taboo` is a Collection or Function determining forbidden nodes.
- `deadEnd` supports `\stop`, `\stay`, and `\restart`.
- `\restart` returns to the resolved start node.
- `output: \node` yields node values.
- `output: \step` yields normalized edge Events plus the destination node.

### 23.5 Tests

- Graph normalization.
- Uniform and weighted fixed-seed traces.
- Non-backtracking.
- Self-avoiding termination.
- Reinforcement updates local stream state only.
- Memory.
- Taboo Function.
- Dead-end modes.
- Missing start node.
- Independent streams.

## 24. `Pvomm`

### 24.1 Scope

Implement a variable-order Markov generator using Prediction by Partial Matching with PPM-C escape estimation for the first version.

Do not expose unsupported method names.

### 24.2 Constructor

```supercollider
Pvomm(
    corpus,
    maxOrder: 8,
    length: inf,
    start: nil,
    learning: false,
    excludeSeen: true
)
```

### 24.3 Corpus

Accept:

- One SequenceableCollection.
- A collection of SequenceableCollections interpreted as separate sequences.

Do not create contexts across corpus-sequence boundaries.

### 24.4 Model

Create a private `PTRVommModel` containing suffix-context count tables.

Requirements:

- Back off from the longest available context to shorter contexts.
- Use PPM-C escape probability.
- When `excludeSeen` is true, symbols already considered at higher orders are excluded during lower-order fallback.
- `start` may be a symbol or context collection.
- `learning: true` updates the stream-local model with generated symbols.
- Do not mutate a model shared by independent streams.

### 24.5 Tests

- Order-zero distribution.
- Deterministic corpus.
- Context fallback.
- Sequence-boundary isolation.
- PPM-C probability checks on a small corpus.
- Fixed-seed generation.
- Learning isolation between streams.
- Arbitrary object symbols.

## 25. `Ppetri`

### 25.1 Scope

Implement discrete Petri-net firing with interleaving semantics: one enabled transition fires per output item.

### 25.2 Constructor

```supercollider
Ppetri(
    marking,
    transitions,
    length: inf,
    policy: \weighted,
    deadlock: \stop,
    output: \event
)
```

### 25.3 Marking

`marking` is an Event or Dictionary mapping place Symbols to nonnegative integer token counts.

### 25.4 Transition definition

```supercollider
(
    consume: (ready: 1),
    produce: (playing: 1),
    weight: 1,
    priority: 0,
    value: \start,
    delta: 1
)
```

### 25.5 Policies

Required:

- `\uniform`
- `\weighted`
- `\priority`

Priority chooses among transitions with the highest current priority, then uses weight when several remain.

### 25.6 Output Event

```supercollider
(
    transition: transitionName,
    value: transitionValue,
    marking: copiedMarking,
    delta: transitionDelta
)
```

### 25.7 Requirements

- A transition is enabled when all required tokens are available.
- Consumption and production are atomic.
- Never expose the mutable internal marking directly.
- `deadlock` supports `\stop`, `\warn`, and `\error`.
- Dynamic inhibitor arcs and timed Petri-net semantics are out of scope for the first version.

## 26. `Pkuramoto`

### 26.1 Constructor

```supercollider
Pkuramoto(
    frequencies,
    coupling: 1,
    phases: nil,
    step: 0.01,
    length: inf,
    method: \rk4,
    output: \state
)
```

### 26.2 Model

Use the Kuramoto phase model. Support:

- Scalar all-to-all coupling.
- A square coupling matrix.
- Natural frequencies as a finite Collection.
- Initial phases as a same-size Collection or random phases when `nil`.

### 26.3 Output modes

- `\phases`: phase Array.
- `\order`: synchronization magnitude.
- `\state`: Event containing `time`, `phases`, `wraps`, and `order`.
- `\wraps`: emit state Events only for integration steps where one or more phases wrap through the cycle boundary.

### 26.4 Requirements

- Default to RK4.
- Normalize output phases to `[0, 2pi)`.
- Detect wraps from unwrapped phase advancement, not by comparing normalized values alone when a step may exceed one cycle.
- Validate finite positive step size.
- Keep the number of oscillators modest in documentation and explain the `O(N^2)` cost of dense coupling.

### 26.5 Tests

- Zero coupling independent phases.
- Identical phases and frequencies remain synchronized.
- Order parameter bounds.
- Matrix validation.
- Wrap detection.
- RK4 reference step.
- Seeded random phases.

## 27. `Pbranching`

### 27.1 Constructor

```supercollider
Pbranching(
    seed,
    offspring,
    valueFunction: nil,
    maxDepth: 8,
    maxNodes: 10000,
    traversal: \breadth,
    output: \node
)
```

### 27.2 Semantics

- Each node has a value, depth, index, parent index, and child index.
- `offspring` is a nonnegative integer, Pattern, or Function receiving the node Event.
- `valueFunction` receives parent node and child index and returns the child value.
- Without `valueFunction`, children inherit the parent value.
- Traversal supports `\breadth` and `\depth`.
- Stop at `maxDepth`.
- Throw before exceeding `maxNodes`.

### 27.3 Output modes

- `\value`: node value only.
- `\node`: copied node Event.

### 27.4 Tests

- Deterministic tree.
- Breadth and depth order.
- Zero offspring.
- Depth bound.
- Node bound.
- Parent metadata.
- Pattern-valued offspring independence.

## 28. `Psandpile`

### 28.1 Scope

Implement a finite Abelian sandpile driven by one added grain per Pattern item and fully stabilized before yielding.

### 28.2 Constructor

```supercollider
Psandpile(
    size: #[8, 8],
    initial: nil,
    drive: nil,
    threshold: 4,
    boundary: \open,
    length: inf,
    output: \avalanche,
    maxTopplings: 1000000
)
```

### 28.3 Semantics

- Support one- and two-dimensional rectangular grids.
- `initial: nil` creates an empty grid.
- `drive: nil` chooses a random site.
- `drive` may be a Pattern or Function producing a site index or coordinate.
- A site topples when its value reaches `threshold`.
- In two dimensions, distribute one grain to each orthogonal neighbor for threshold four.
- `\open` boundaries dissipate grains outside the grid.
- `\closed` boundaries reject configurations that cannot stabilize safely; do not enter an infinite loop.

### 28.4 Output Event

```supercollider
(
    drive: coordinate,
    avalancheSize: totalTopplings,
    activeSites: numberOfDistinctToppledSites,
    lostGrains: dissipatedGrains,
    state: copiedGrid
)
```

`output: \size` yields only `avalancheSize`.

### 28.5 Tests

- One-dimensional stabilization.
- Two-dimensional center toppling.
- Boundary dissipation.
- Conservation accounting.
- Deterministic drive.
- Maximum-toppling guard.
- Fresh state copy.

# Part V — Shared quality requirements

## 29. Test standards

Use `UnitTest` subclasses. Tests must be runnable individually with:

```supercollider
TestPscan.run;
```

The full suite must be runnable with:

```supercollider
UnitTest.runAll;
```

Use descriptive test names:

```supercollider
test_embedInStream_whenSourceEnds_returnsLatestInval {
    ...
}
```

Prefer one assertion per test where reasonable. Use `assertEquals` for exact data and explicit tolerance checks for floating-point results.

All random tests must set `thisThread.randSeed` or use `Pseed`.

### 29.1 Common tests for every Pattern

Where applicable, test:

- Constructor storage and `storeArgs`.
- Empty or zero-length output.
- Finite termination.
- Correct return of `inval`.
- Two independent streams from one Pattern.
- Re-creation with `asStream`.
- Arbitrary object values.
- Event values.
- Pattern-valued parameters.
- Invalid values.
- Fixed-seed reproducibility.
- No mutation of caller-owned Collections.

### 29.2 Property tests

Add bounded deterministic property tests for:

- De Bruijn n-gram coverage.
- Gray-code uniqueness and adjacency.
- QMC range and dimensionality.
- Point-process monotonicity.
- Constraint satisfaction.
- Graph-walk edge validity.
- Petri token nonnegativity.
- Kuramoto phase and order bounds.
- Sandpile stability after every output.

Do not use enormous random loops. Tests must remain fast enough for normal Quark development.

## 30. Documentation requirements

Documentation is a first-class deliverable, not cleanup after implementation.

Every public class requires SCDoc with:

1. One-sentence summary.
2. Precise conceptual description.
3. Constructor signature.
4. Argument semantics, including when Pattern-valued arguments are evaluated.
5. Output type and exact stream behavior.
6. Termination behavior and safety bounds.
7. Memory and complexity notes where material.
8. One minimal deterministic/value-stream example.
9. One minimal musical example when useful.
10. **One runnable example for every application or structure advertised for that Pattern in this specification.**
11. See-also links to relevant core classes and closely related Patternarium classes.

An application must not be claimed in prose unless the Help contains a short working example demonstrating it. Conversely, avoid adding decorative examples that do not teach a distinct behavior.

### 30.1 Documentation style: SuperCollider-native, minimal, dynamic, interpreted

All Help files, Guides, and examples must follow the characteristic **minimal, interpreted, dynamic code style of the SuperCollider documentation**:

- Prefer short expressions that can be evaluated directly in the IDE.
- Prefer several small independent code blocks over one large program.
- Make examples exploratory: users should be able to alter one number or Pattern and immediately re-evaluate it.
- Use direct Pattern expressions such as `.asStream.nextN`, `.asStream.all`, `.trace`, `.play`, and short `Pbind` blocks.
- Introduce a variable only when it clarifies state or allows interactive reuse.
- Avoid boilerplate classes, wrapper functions, application architecture, or pseudo-frameworks inside Help examples.
- Do not write examples in a static/tutorial style that requires reading a whole script before anything can run.
- Keep setup local and obvious. A user evaluating only the displayed block should understand its dependencies.
- For numerical examples, do not boot the server.
- For musical examples, use the shared Patternarium demonstration SynthDefs from the main Guide whenever appropriate.
- Keep comments sparse and explanatory. Prefer expressive code over paragraph-sized comments.
- The first example for every class should normally fit in one or two expressions.
- More sophisticated examples should remain live-code friendly and separable into independently evaluable blocks.

Preferred minimal form:

```supercollider
PdeBruijn([0, 1], 3).asStream.all;
```

Preferred interactive musical form:

```supercollider
(
Pbind(
    \instrument, \saw,
    \degree, PdeBruijn((0..4), 2),
    \dur, 0.125
).play;
)
```

Avoid turning Help into large demonstration applications.

### 30.2 Main Guide and shared demonstration instruments

Create `HelpSource/Guides/Patternarium.schelp` as the main entry point. Near the beginning, include a section titled **Example instruments** containing four deliberately compact SynthDefs. Although these are server-side examples, they are documentation fixtures only and are not part of the Quark's algorithmic implementation.

Use short, idiomatic SynthDef names that keep the Help examples readable:

Do **not** prefix these SynthDef names with `ptr`, `PTR`, `Patternarium`, or any other library namespace. The intended names are exactly `\fmPiano`, `\saw`, `\mallet`, and `\farfisa`.

```supercollider
(
SynthDef(\fmPiano, { |out=0, freq=440, amp=0.1, gate=1, pan=0|
    var env = EnvGen.kr(Env.perc(0.005, 2.8, curve: -5), gate, doneAction: 2);
    var mod = SinOsc.ar(freq * 2, 0, freq * 1.6 * env);
    var sig = SinOsc.ar(freq + mod) * env;
    sig = sig + (SinOsc.ar(freq * 2.01) * env.squared * 0.12);
    Out.ar(out, Pan2.ar(sig * amp, pan));
}).add;

SynthDef(\saw, { |out=0, freq=440, amp=0.1, gate=1, pan=0, cutoff=2200, rq=0.25|
    var env = EnvGen.kr(Env.adsr(0.01, 0.15, 0.65, 0.4), gate, doneAction: 2);
    var sig = Saw.ar(freq * [1, 1.005]).sum * 0.5;
    sig = RLPF.ar(sig, cutoff.clip(40, 18000), rq.clip(0.05, 1));
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

SynthDef(\mallet, { |out=0, freq=440, amp=0.1, pan=0|
    var exc = PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.02));
    var body = Ringz.ar(exc, freq * [1, 2.01, 3.97], [1.3, 0.8, 0.45]).sum;
    var round = SinOsc.ar(freq, 0, 0.12) * EnvGen.ar(Env.perc(0.001, 0.32));
    var env = EnvGen.kr(Env.perc(0.001, 1.4, curve: -4), doneAction: 2);
    Out.ar(out, Pan2.ar((body * 0.22 + round) * env * amp, pan));
}).add;

SynthDef(\farfisa, { |out=0, freq=440, amp=0.08, gate=1, pan=0|
    var env = EnvGen.kr(Env.asr(0.02, 1, 0.12), gate, doneAction: 2);
    var vibrato = SinOsc.kr(5.7, 0, 0.004, 1);
    var f = freq * vibrato;
    var sig = Pulse.ar(f * [1, 2, 4], [0.48, 0.5, 0.52], [0.65, 0.25, 0.1]).sum;
    sig = HPF.ar(sig, 90);
    sig = LPF.ar(sig, 5200);
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;
)
```

The agent may refine coefficients after listening, but must preserve the four roles and keep the SynthDefs short, dependency-free, and easy to understand. These names are deliberately generic because the SynthDefs are documentation fixtures, not installed library infrastructure:

- `\fmPiano`: soft FM/electric-piano-like voice.
- `\saw`: filtered sawtooth subtractive voice.
- `\mallet`: round percussive synthetic mallet.
- `\farfisa`: bright transistor-organ/Farfisa-like voice.

Do not spend implementation time pursuing high-fidelity instrument emulation. Their purpose is to make Pattern examples musically legible.

### 30.3 Required Help example coverage

The following is the minimum application-example catalogue. Each item must become at least one **small, runnable SCDoc example** in the relevant class Help or in the main/secondary Guide with a direct link from that class Help. Reuse the four shared SynthDefs when doing so improves clarity.

#### `Pscan`

Provide separate examples for:

- Recamán-type recurrence.
- Running average.
- Adaptive threshold driven by recent state.
- Numerical integration of a changing input.
- Leaky integration / one-pole state memory.
- Ecological population recurrence, e.g. a logistic population update.
- Reinforcement process in which previous selections alter later state or weight.

Do not hide all of these behind one generalized example. The pedagogical point is to show that one recurrence primitive expresses several domains.

#### `Pwindow`

Provide separate examples for:

- Moving mean.
- Moving median.
- Moving variance.
- Moving entropy of a symbolic stream.
- N-gram extraction.
- Local melodic interval analysis.
- Pattern convolution / finite impulse-style weighted window operation.
- Motif detection.
- Peak detection.
- Zero-crossing detection.
- Direction-change detection.
- Online local normalization.
- Building training contexts for a variable-order corpus model.

#### `Ptransduce`

Provide separate examples for:

- Debouncing a noisy binary/control-like stream.
- Hysteresis with distinct upper and lower thresholds.
- Parsing a symbolic stream into higher-level tokens.
- Ornament insertion.
- Conditional rhythmic rewriting.
- Pairing note-on/note-off style messages into completed note events.
- Phrase segmentation.
- Stateful quantization.
- Run-length encoding.
- Run-length decoding.
- Simple protocol interpretation/state machine driven by an input stream.

At least one example must demonstrate zero output for some inputs, and one must demonstrate multiple outputs from one input.

#### `Pmorphism`

Provide separate examples for:

- Formal growth across generations.
- Ornament proliferation.
- Self-similar rhythm generation.
- Phrase mutation.
- Evolving orchestration/instrument-symbol assignment.
- Symbolically controlled synthesis parameter generation.

Include at least one context-sensitive Function rule and one Pattern-valued replacement example.

#### `PdeBruijn`

Provide separate examples for:

- Exhaustively auditioning articulation transitions.
- Traversing all short rhythmic cells of a specified local order.
- Exhaustive discrete synthesis-parameter combinations with n-gram coverage.
- Balanced n-gram musical material.
- Perceptual-test ordering in which every local transition/context occurs.
- Speaker/channel transition testing.

The Help must explicitly explain why De Bruijn order is about **local subsequences**, not simply permutations.

#### `PgrayCode`

Provide separate examples for:

- Smooth traversal of a discrete synthesis parameter space.
- Orchestration changes where only one property changes at a time.
- Controlled mutation.
- Perceptually traceable parameter exploration.
- Click-reduced switching between discrete states where only one control changes.
- Hardware or loudspeaker/channel configuration testing.

At least one example must display which coordinate changed between consecutive states.

#### `Pqmc`

Provide separate examples for:

- Multidimensional timbre exploration.
- Spatial trajectory/position sampling.
- Preset interpolation coordinates.
- Experimental-design parameter sampling.
- General parameter-space coverage compared conceptually with `Pwhite`.
- Irregular but evenly spread generative material.

Include a small visualization-free numerical comparison demonstrating coverage without depending on GUI plotting.

#### `ProtationWord`

Provide separate examples for:

- A balanced binary rhythmic stream.
- Complementary binary streams derived from one rotation.
- Aperiodic pitch/degree selection using irrational rotation.
- Periodic behavior with rational `alpha` for contrast.
- Multisymbol interval partitioning using `cuts`.
- Quasicrystal/cut-and-project-like musical ordering as a conceptual application, without overstating mathematical equivalence.

#### `PnumSeq`

Provide at least one minimal runnable example for **each registered sequence**:

- Recamán.
- Van Eck.
- Golomb.
- Kolakoski.
- Paperfolding.
- Rudin–Shapiro.
- Stern's diatomic sequence.
- Calkin–Wilf rationals.
- Look-and-say.
- Nørgård infinity series.

For musically relevant sequences, add a second example showing a meaningful mapping rather than blindly using the raw integer as pitch.

#### `PpointProcess` / `Prenewal`

The main Guide must use `Prenewal` to demonstrate the point-process abstraction with separate examples for:

- Exponential/Poisson renewal timing.
- Gamma renewal timing.
- Weibull renewal timing.
- Refractory-like timing using a minimum interval plus a random tail.
- Non-homogeneous arrival-rate approximation when expressible by a time-varying interval Pattern; clearly label approximations.
- Self-correcting timing concept if it can be represented safely with the available recurrence machinery; otherwise document it as a future specialization rather than pretending `Prenewal` implements it directly.

Self-excitation belongs primarily in `Phawkes` and must link there.

#### `Phawkes`

Provide separate examples for:

- Aftershock-like event clustering.
- Echo-like rhythmic proliferation.
- Call-and-response between two dimensions/voices.
- Contagion between voices through a cross-excitation matrix.
- Local acceleration after events.
- Bursts separated by sparse regions.
- Cross-channel activation/spatial triggering.

Include one example where the interaction matrix is printed or inspected before playback so the coupling is understandable.

#### `Pconstraint`

Provide separate examples for:

- Voice leading with bounded leaps.
- Simple counterpoint-like interval restrictions; avoid claiming stylistically complete species counterpoint.
- All-interval-row or interval-coverage construction.
- Chord voicing under range and spacing restrictions.
- Rhythmic tiling / duration-combination constraints.
- Register allocation.
- Instrument-assignment restrictions.
- Spatial trajectories avoiding forbidden positions/regions.
- Combinations with bounded repetition.
- Valid multidimensional synthesis-parameter states.

Each example must use a deliberately small search space so it remains instantaneous in the Help browser.

#### `PgraphWalk`

Provide separate examples for:

- Harmonic/chord-transition network.
- Timbral-state graph.
- Spatial routing graph.
- Sample-transition graph using symbolic sample names rather than external files.
- Nonlinear musical form graph.
- Non-backtracking exploration.
- Reinforced paths that become more likely after use.
- Self-avoiding traversal.

#### `Pvomm`

Provide separate examples for:

- Using long contexts when they are informative.
- Falling back to shorter contexts when the corpus is sparse.
- Learning recurring phrases.
- Online learning from generated output.
- Balancing repetition and variation relative to a fixed-order Markov example.
- Treating separate corpus sequences without creating false transitions across boundaries.

Use tiny symbolic corpora so probability and context behavior can be inspected manually.

#### `Ppetri`

Provide separate examples for:

- Concurrent independent processes.
- Synchronization requiring multiple prerequisite tokens.
- Resource constraints.
- One musical process waiting for another.
- Tokens representing performers/voices.
- Tokens representing buffers or channels.
- Tokens representing abstract energy/capacity.
- Competing enabled transitions with weights.

At least one example should print the marking after every firing before adding audio.

#### `Pkuramoto`

Provide separate examples for:

- Independent polyrhythms at zero coupling.
- Gradual synchronization as coupling increases.
- Desynchronization caused by divergent natural frequencies.
- Phase-cluster formation with a coupling matrix.
- Using phase-wrap events to trigger notes.
- Mapping the order parameter to a synthesis control.

Keep oscillator counts small enough for the Help examples to remain transparent.

#### `Pbranching`

Provide separate examples for:

- Proliferating ornamentation.
- Phrase genealogies.
- Population growth.
- Population extinction.
- Hierarchical event density.
- Recursive spatial diffusion.
- Avalanche-like branching structures.

Show both breadth-first and depth-first traversal at least once.

#### `Psandpile`

Provide separate examples for:

- Granular-cloud density driven by avalanche size.
- Clustered percussion.
- Spatial spreading based on toppled sites.
- Form-level density derived from avalanche statistics.
- Boundary dissipation.
- Critical-state buildup through repeated grain addition.

Do not describe the sandpile as producing a power law in a tiny demonstration unless the example actually measures enough data to justify that statement.

### 30.4 Example execution policy

Every documentation example must be mechanically checked before release.

Create `Tests/DocumentationExamples.scd` or an equivalent extraction runner that verifies, at minimum:

- Numerical examples compile and terminate.
- Shared SynthDefs compile after server boot.
- All example class names and arguments still match the public API.
- No example requires a third-party Quark.
- No example writes files or depends on user-specific paths.
- Examples using infinite Patterns explicitly bound inspection with `nextN`, `Pfin`, finite `length`, or user-controlled playback.

Do not attempt brittle full-text parsing of SCDoc if a curated executable example manifest is more reliable. The source of truth must still be the Help documentation.

## 31. Performance requirements

- Do not precompute infinite streams.
- Use queues or ring-buffer logic for `Pwindow`; avoid repeated full-array shifting where a simple indexed buffer is clearer.
- Use Sets and Dictionaries for membership and last-occurrence algorithms.
- Avoid repeated deep copies inside numerical integration.
- Return copied user-visible mutable state, but keep internal state private.
- Add hard bounds to rewriting, constraint search, branching, unstable point processes, and sandpile stabilization.
- Document unavoidable unbounded memory in `PnumSeq`, `Pvomm` learning mode, and self-avoiding graph traversal.

Add a small benchmark script, but do not make performance claims without measurements.

## 32. Error behavior

Errors must identify:

- Class.
- Invalid argument or process state.
- Received value.
- Expected condition.

Example:

```text
Pwindow: 'size' must be a positive Integer; received 0.
```

Do not silently clamp structural parameters. Normalizing circular phases modulo one or `2pi` is expected and should be documented.

## 33. Source references and provenance

Create `docs/algorithm-notes.md` containing, for every specialized algorithm:

- Mathematical definition.
- Selected implementation algorithm.
- Complexity.
- Source references.
- Any implementation deviation.
- Test-vector source.
- License and provenance of included data.

This is mandatory for:

- De Bruijn generation.
- Mixed-radix Gray code.
- Halton and other QMC engines.
- Every `PnumSeq` sequence.
- Hawkes simulation.
- PPM-C.
- Kuramoto integration.
- Sandpile stabilization.

# Part VI — Milestones and commits

## 34. Milestone 0 — Repository and audit

Deliver:

- Quark skeleton.
- Metadata.
- License.
- README.
- Main `Patternarium.schelp` Guide skeleton, including the shared example-instrument section.
- Test loading.
- Class-name audit.
- CI smoke compile.

Suggested commits:

```text
chore: initialize Patternarium quark
chore: add class-name and dependency audit
ci: compile quark and run empty test suite
```

## 35. Milestone 1 — Foundational Patterns

Implement in order:

```text
Pscan
Pwindow
Ptransduce
Pmorphism
```

Suggested commits:

```text
test: specify Pscan stream semantics
feat: implement Pscan
 docs: document Pscan

test: specify Pwindow overlap and termination
feat: implement Pwindow
 docs: document Pwindow

test: specify Ptransduce step protocol
feat: implement Ptransduce
 docs: document Ptransduce

test: specify Pmorphism parallel rewriting
feat: implement Pmorphism
 docs: document Pmorphism
```

Release `v0.1.0` only when these four classes are stable.

## 36. Milestone 2 — Mathematical sequences

Implement:

```text
PdeBruijn
PgrayCode
Pqmc
ProtationWord
PnumSeq
```

Release `v0.2.0`.

## 37. Milestone 3 — Point processes and graph systems

Implement:

```text
PpointProcess
Prenewal
Phawkes
Pconstraint
PgraphWalk
```

Release `v0.3.0`.

## 38. Milestone 4 — Experimental systems

Implement:

```text
Pvomm
Ppetri
Pkuramoto
Pbranching
Psandpile
```

Mark these classes experimental in SCDoc and the README. Release `v0.4.0`.

## 39. Milestone 5 — Stabilization

Before `v1.0.0`:

- Run all tests on Linux, macOS, and Windows.
- Recheck class-name collisions.
- Validate help-file rendering.
- Run every documentation example, including every application example listed in Section 30.3.
- Confirm no server is required for tests.
- Benchmark representative finite workloads.
- Remove unused private abstractions.
- Freeze public constructor signatures.
- Review all Errors and warnings.
- Verify GPL notices and source provenance.
- Add migration notes for any renamed experimental classes.

Do not promote an experimental class to stable merely to reach 1.0.

# Part VII — CI and local execution

## 40. Local installation

Document:

```supercollider
Quarks.install("/absolute/path/to/Patternarium");
thisProcess.recompile;
```

## 41. Test runner

Create `Tests/run.scd` that:

1. Confirms all expected classes exist.
2. Runs only Patternarium test classes.
3. Exits `sclang` with a nonzero status when any test fails.

Do not rely on the graphical test interface.

Because SuperCollider installations differ, keep OS-specific CI launcher details isolated in scripts. The source tests themselves must remain platform independent.

# Part VIII — Definition of done

The project is complete when:

- The Quark installs without external dependencies.
- The class library compiles without warnings introduced by this Quark.
- Every required and experimental class in this specification exists, except `Pscope`, which is intentionally gated against duplication.
- Every class follows the stated termination and `inval` semantics.
- All deterministic reference tests pass.
- All seeded random tests are reproducible.
- Independent streams do not share mutable iteration state.
- All finite algorithms terminate.
- Dangerous growth paths have explicit limits.
- Every public class has valid SCDoc in the minimal, dynamic, interpreted style specified above.
- Every advertised application in Section 30.3 has at least one runnable example.
- The main Guide contains the four shared demonstration SynthDefs.
- Every runnable documentation example has been executed successfully.
- The Quark can be used without booting a server for all numerical operations.
- The release checklist is complete.

# Part IX — Explicit non-goals

Do not implement in this project:

- New UGens.
- Production SynthDef libraries or instrument-emulation subsystems; only the four compact Help/demo SynthDefs are in scope.
- Server-side chaotic oscillators.
- A duplicate Euclidean rhythm Pattern.
- A duplicate Xenakis sieve library.
- Cellular automata already provided adequately by existing extensions, except the specifically scoped sandpile avalanche model.
- Generic L-systems that add nothing beyond `Prewrite`.
- One class for every OEIS sequence.
- A general theorem prover or unrestricted CSP system.
- Neural-network models.
- Corpus audio analysis.
- GUI editors.
- MIDI or OSC device management.
- Automatic spawning or cleanup classes without a demonstrated gap in `Pproto`, `Pprotect`, `Pspawner`, and `EventStreamCleanup`.

# Part X — Primary implementation references

Use current official SuperCollider source and documentation as the authority for Pattern behavior and testing conventions:

- Pattern: https://doc.sccode.org/Classes/Pattern.html
- Pattern internals: https://doc.sccode.org/Tutorials/A-Practical-Guide/PG_Ref01_Pattern_Internals.html
- Using Quarks: https://doc.sccode.org/Guides/UsingQuarks.html
- EventStreamCleanup: https://doc.sccode.org/Classes/EventStreamCleanup.html
- Core Pattern source: https://github.com/supercollider/supercollider/tree/develop/SCClassLibrary/Common/Streams
- Core Pattern tests: https://github.com/supercollider/supercollider/blob/develop/testsuite/classlibrary/TestPattern.sc
- Unit testing guide: https://github.com/supercollider/supercollider/wiki/Unit-Testing-Guide
- Community Quark Directory: https://github.com/supercollider-quarks/quarks

For the specialized algorithms, prefer original papers, authoritative mathematical references, or official reference implementations. Record exact citations in `docs/algorithm-notes.md` rather than relying on uncited summaries.
