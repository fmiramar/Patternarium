# Algorithm notes

All implementations are original language-side code, GPL-3.0-or-later. No external implementation code, direction tables or datasets are included. Test prefixes are short mathematical reference vectors with provenance below.

## Foundations

- **Pscan** computes `s[i+1] = f(s[i], x[i], i, inval)` lazily. O(1) library state, plus caller-owned recurrence state. Reference vectors are hand-calculated sums.
- **Pwindow** buffers at most `size` references and advances by `step`. An indexed ring buffer uses O(size) storage and O(min(step, size)) reference clearing per output; retained items never shift. Each fresh output Array costs O(size) to assemble in source order. Gapped windows additionally evaluate step-size skipped source items. Partial emission requires at least one new buffered item since the last output. Reference vectors are explicitly enumerated offsets.
- **Ptransduce** consumes one source value per transition, emits the supplied finite collection, and flushes only at natural source end. O(state + emission collection) storage. No automatic state copying. Tests define the Event protocol directly.
- **Pmorphism** applies a parallel substitution to each generation, using only previous-generation neighbors. O(maxSymbols) references for current and next generations; time is proportional to visited symbols and produced replacements. Replacement Patterns are read through one terminating nil beyond a full legal replacement. A nonterminating replacement is rejected on its first item beyond the bound. Empty arrays delete; nil is rejected as a symbol. References: [core Prewrite](https://github.com/supercollider/supercollider/blob/develop/SCClassLibrary/Common/Streams/Prewrite.sc) for the comparison only, and the parallel-rewriting definition in the project specification. Test vectors are manually expanded Fibonacci words. No Prewrite implementation was copied.

Pattern behavior follows [Pattern internals](https://doc.sccode.org/Tutorials/A-Practical-Guide/PG_Ref01_Pattern_Internals.html) and the installed core Pattern, List, Event, and UnitTest sources.

## Mathematical sequences

### De Bruijn generation

For alphabet size k and order n, every cyclic n-word occurs once in a k^n-symbol cycle. The implementation concatenates lexicographically ordered Lyndon words whose lengths divide n using a recursive FKM prenecklace traversal. It does not enumerate a word table. Source: Ruskey, Savage and Wang, [Generating necklaces](https://doi.org/10.1016/0196-6774(92)90047-G), Journal of Algorithms 13 (1992), 414–430; Sawada, Williams and Wong, [Generalizing the Classic Greedy and Necklace Constructions](https://www.combinatorics.org/ojs/index.php/eljc/article/view/v23i1p24), Electronic Journal of Combinatorics 23(1) (2016).

O(k^n) output storage plus O(n) recursion/work storage, with the necklace traversal's amortized generation bound. A hard one-million-symbol cycle limit is checked before allocation. Unary alphabets are handled separately to avoid needless deep recursion. Rotation is a left starting offset. Tests use the standard binary FKM cycle 00010111 and independently count all cyclic windows for several sizes. No source code or data tables were copied.

### Mixed-radix Gray traversal

A reflected traversal changes the last available coordinate by one. A blocked coordinate reverses direction and carries left. Every product state occurs once before all coordinates are blocked. Reference: Donald Knuth, *The Art of Computer Programming*, Volume 4A, §7.2.1.1, combinatorial generation and Gray codes. This is an original implementation of the reflected traversal, with a carry scan rather than a focus-pointer loopless variant.

O(d) state; amortized constant carry work per output, plus O(d) to copy the result. No product-space table is allocated. Tests explicitly enumerate the two-bit reflected code and [2,3] traversal and independently check uniqueness and unit adjacency for bounded products. Repeated traversals may have a boundary jump.

### Halton and additive sampling

Halton coordinate j is the base-p[j] radical inverse of integer n, with consecutive primes and n = skip + outputIndex × leap. Index zero is included. Reference: J. H. Halton, [On the efficiency of certain quasi-random sequences of points in evaluating multi-dimensional integrals](https://doi.org/10.1007/BF01386213), Numerische Mathematik 2 (1960), 84–90. Numerical test vectors use the first five unscrambled 2D points in the [official SciPy Halton documentation](https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.qmc.Halton.html), with exact fractions used in tests. SciPy is not a dependency and no implementation code is copied.

The additive engine is a Kronecker sequence: coordinate j = fractionalPart(n × fractionalPart(sqrt(p[j]))). Distinct prime square roots and 1 are rationally independent in exact arithmetic. Reference: Kuipers and Niederreiter, *Uniform Distribution of Sequences* (Wiley, 1974), Chapter 1, uniform distribution of multiples of irrational vectors. Tests calculate a three-point definition vector separately. This engine is not advertised as a Sobol or generalized-golden-ratio construction.

Scramble means a per-coordinate uniform random torus shift, sampled once per stream, rather than digit permutation. Reference: Cranley and Patterson, [Randomization of Number Theoretic Methods for Multiple Integration](https://doi.org/10.1137/0713019), SIAM Journal on Numerical Analysis 13(6) (1976), 904–914. It preserves the underlying deterministic ordering under a shift; it does not cure every high-dimensional correlation. Tests use finite Pseed seed streams to check reproducibility. The shift is generated by sclang's thread RNG.

Prime generation is local trial division, bounded by O(d times p[d]) divisibility checks with the present simple scan; each Halton point costs O(d log n), each additive point O(d), and storage O(d). Dimensions are capped at 4096; indices above 2147483646 fail before conversion to a machine Integer. Floating precision limits exact irrational behavior. No direction-number files or external tables are used.

### Circle rotation coding

Mechanical output is the exact stated floor-difference formula evaluated in floating arithmetic after alpha/phase normalization modulo one. Partition output counts cuts at or below the rotated point, assigning boundary points to the interval on their right. Source: Lothaire, *Algebraic Combinatorics on Words* (Cambridge University Press, 2002), Chapter 2, Sturmian words and mechanical coding. O(1) space for binary coding, O(cuts) storage and work for partition coding. Direct index evaluation avoids cumulative addition drift but still has finite-precision limits. Reference vectors are hand-calculated rational rotations and a direct floor-formula comparison; balanced-subword counts are checked separately. No external data is included.

### Numerical sequence registry

All dispatch is fixed in code; returned name lists are copies. The following references supply definitions and the short independent prefixes in TestPnumSeq. Numeric sequences are mathematical data, not copied implementation code. OEIS references are attributed to their entries and contributors; its content licensing information is at [OEIS licenses](https://oeis.org/wiki/The_OEIS_End-User_License_Agreement). No complete b-files or prose extracts are distributed.

| Name | Definition, indexing, algorithm | Complexity per output / memory | Vector source |
| --- | --- | --- | --- |
| recaman | a(0)=seed; at n>0 subtract n if nonnegative and unseen, otherwise add n. Set membership. | expected O(1) / O(distinct values) | [A005132](https://oeis.org/A005132), first 12 terms |
| vanEck | Output the seed prefix, then distance to previous occurrence of current value, else zero. Dictionary of latest positions. | expected O(1) / O(distinct values) | [A181391](https://oeis.org/A181391), first 12 terms |
| golomb | a(1)=1; a(n)=1+a(n-a(a(n-1))). Indexed history buffer. | O(1) / O(outputs) | [A001462](https://oeis.org/A001462), first 12 terms |
| kolakoski | Standard alphabet [1,2], prefix 1,2,2; indexed run-length expansion of its own terms. Generalized two-positive-integer alphabets use the documented canonical bootstrap. | O(max alphabet) amortized append work / O(outputs + bootstrap) | [A000002](https://oeis.org/A000002), first 15 terms; generalized alphabet checked by run-length property |
| paperfolding | n starts at 0; take odd part of n+1; output 1 iff it is 1 mod 4. | O(log n) worst case / O(1) | [A014577](https://oeis.org/A014577), first 15 terms |
| rudinShapiro | n starts at 0; parity of overlapping 11 bits gives sign (-1)^parity, or parity with binary=true. | O(log n) / O(1) | [A020985](https://oeis.org/A020985), first 12 signed terms |
| stern | s(0)=0, s(1)=1; s(2n)=s(n), s(2n+1)=s(n)+s(n+1). Emit numerator of the adjacent-Stern-pair successor starting at [0,1]. | O(1) / O(1) | [A002487](https://oeis.org/A002487), first 12 terms |
| calkinWilf | Start [1,1]. Successor of a/b is b/((2 floor(a/b)+1)b-a). | O(1) / O(1) | Calkin and Wilf, [Recounting the Rationals](https://cecas.clemson.edu/~calkin/Papers/recount.pdf), American Mathematical Monthly 107(4), 2000, 360–363; first seven pairs |
| lookAndSay | Start digit Array [1]; describe each maximal run by decimal count digits followed by the digit. | O(term size) / O(maxTermSize) | [A005150](https://oeis.org/A005150), first six terms converted to digit Arrays |
| norgard | a(0)=0, a(2n)=-a(n), a(2n+1)=a(n)+1. Fold the bits of n from most significant to least. | O(log n) / O(log n) transient digit array | [A004718](https://oeis.org/A004718), first 16 terms |

The registry does not offer arbitrary seeds for sequences whose canonical recurrence would become ambiguous. Recaman, vanEck and lookAndSay explicitly support seeds. Golomb, Kolakoski and the index-formula sequences reject them. Look-and-say checks maxTermSize before expansion, yields shallow copies, and handles run counts above nine as multiple decimal digits. Integer overflows are guarded; arbitrary precision is outside the current API.

Experimental-system references will be recorded with that later milestone.

## Temporal point processes

### Shared time/output contract and renewal timing

PpointProcess is abstract. Prenewal consumes strictly positive finite intervals, accumulates them from a finite start, and yields delta, absolute time or fresh Events. Empty history at start means the first interval precedes the first emitted arrival. Floating-point time must strictly advance; overflow and lost precision throw rather than silently yielding equal timestamps. Storage/work is O(1) per interval beyond the supplied stream.

Exponential intervals use inverse-CDF sampling `-log(U)/rate` with U uniform in (0,1). PTRPointProcess.exponential redraws the RNG's possible zero endpoint and uses sclang's thread RNG. No additional acceptance or dimension-choice random draws are made in scalar zero-excitation Hawkes mode, allowing exact seeded comparison to Prenewal under the shared sampler. Gamma/Erlang and Weibull Help examples implement their elementary transformations locally, rather than adding distribution dependencies. The time-varying-rate example freezes the rate at the previous arrival and is explicitly an approximation, not an exact non-homogeneous Poisson sampler. A self-correcting intensity model is deferred.

References: J. F. C. Kingman, *Poisson Processes*, Oxford University Press, 1993; the inverse-CDF exponential definition. Deterministic renewal vectors are hand-calculated cumulative sums. No tables or external code are included.

### Exponential Hawkes simulation

The intensity of recipient i is

`lambda_i(t) = mu_i + sum_{events k before t} A[i][dimension_k] * exp(-beta_i * (t - time_k))`.

The stream begins with no prior events. A supplied matrix fixes the number of dimensions, with rows receiving excitation and columns producing it. Scalar excitation without a matrix creates diagonal coupling. Beta is per recipient, so the integrated kernel is `K[i][j] = A[i][j] / beta_i`. Baselines and jumps are nonnegative; decays are strictly positive. Inhibition is not implemented.

Simulation uses adaptive Ogata thinning. The current total intensity is a valid upper bound until the next jump because every excess term decays monotonically. Draw an exponential proposal at that bound, decay all excess intensities, accept with actualTotal/bound, and choose a dimension proportional to its accepted intensity. Rejection advances proposal time and decays state but adds no excitation. After acceptance, add the source column and check the total post-jump intensity cap before yielding. Delta includes all rejected proposal intervals since the previous accepted event. The Event intensity is the selected dimension's pre-jump intensity; totalIntensity also records the accepted total.

Primary references:

- Y. Ogata, [On Lewis' Simulation Method for Point Processes](https://doi.org/10.1109/TIT.1981.1056305), IEEE Transactions on Information Theory 27(1), 1981, 23–31; [author-hosted paper](https://bemlar.ism.ac.jp/zhuang/Refs/Refs/ogata1981ieee.pdf).
- A. G. Hawkes, [Spectra of some self-exciting and mutually exciting point processes](https://doi.org/10.1093/biomet/58.1.83), Biometrika 58(1), 1971, 83–90.

The stationary regime requires spectral radius rho(K)<1; this does not mean an empty-history simulation is initially in equilibrium. To certify the condition without an external matrix library, first use the maximum row-sum bound. If inconclusive, solve `(I-K)x=1` by pivoted Gaussian elimination. For any positive x, Collatz-Wielandt gives `rho(K) <= max_i ((Kx)_i/x_i)`. A valid positive solution supplies a bound below one. Reducible and nilpotent matrices are handled without requiring a strictly positive dominant eigenvector. Reference: Berman and Plemmons, *Nonnegative Matrices in the Mathematical Sciences*, SIAM, 1994; [SIAM tutorial on the Collatz upper bound for nonnegative matrices](https://ftudisco.github.io/siam-nonlinear-pf-tutorial/ch1/sec1/).

The implementation rejects bounds >= 1 - 1e-10 and pivots below 1e-12; this deliberately can reject a stable but near-critical or ill-conditioned case. allowUnstable bypasses only this certificate. The dimension cap is 64, each accepted-arrival search has at most 100000 proposals, and maxIntensity caps the baseline and each post-jump total. Time must remain finite and strictly increasing. Arrival indices are guarded before signed Integer overflow. These are explicit finite-precision deviations from ideal exact-real simulation.

State storage is O(d²) for the matrix plus O(d) decaying intensities. The certificate costs O(d³) worst case; each proposal and accepted update costs O(d), excluding RNG and output allocation. No entire event history is retained by the production sampler.

Test provenance: TestPhawkes contains a 32-arrival scalar golden trace using sclang seed 42 uniforms. It was independently calculated by summing every historical exponential kernel at each proposal, rather than using the implementation's recursive decay state. The trace includes three rejected proposals, before accepted indices 15, 19 and 22. The initial eight arrivals agree within 6e-15, and all 32 are checked with tolerance 1e-10. Other tests verify zero-excitation equality to exponential renewal, recipient/source orientation, seeded reproducibility, monotonicity, intensity caps and analytically stable/unstable 2D matrices. All trace values are original test calculations, not copied third-party data.

## Bounded sequential constraints

Pconstraint performs iterative depth-first search over finite candidate collections. It constructs a complete sequence before yielding either its Array or its individual values. Literal domains are reused, Function domains are evaluated at prefix entry with a copied shallow history, and Pattern domains are sampled once per position before search and cached for backtracking. Candidate collections are copied before shuffling. Each rejected candidate and each exhausted search position consumes one backtrack unit; budget exhaustion always throws distinctly from natural unsatisfiability. Duplicate candidate values can produce duplicate solutions.

Length is capped at 4096 and each domain collection at 100000 candidates. Search work is exponential in the worst case, with rejected/dead branches bounded by maxBacktracks and complete results bounded by solutions. Storage is O(sum of cached/active domain sizes + length), excluding caller-owned candidate objects. Callback execution time itself cannot be bounded by the library. No general CSP completeness, propagation or stylistic counterpoint claim is made. This is an original implementation of standard backtracking; the finite solution vectors and Help cases are hand-calculated and property checked.

## Graph traversal

PgraphWalk normalizes a literal adjacency Dictionary into private edge Events. Missing target adjacency is terminal. Uniform sampling ignores weights; every other strategy samples positive effective weights. Non-backtracking and recent-node memory are soft exclusions applied when alternatives remain; self-avoiding visits and taboo restrictions are hard edge filters. Explicit stay/restart dead-end actions create marked synthetic steps, so repeated nodes under those policies are intentional. Restart clears visit/memory history but preserves reinforced edge weights. Reinforcement changes only that stream's selected directed edge after selection.

Finite graph storage is O(V+E), plus copied metadata and bounded recent memory. Self-avoiding visit storage is O(V). Per-step work is proportional to outgoing edges times membership/callback costs, plus recent-list maintenance. Outputs preserve node identities; step containers and metadata are copied to isolate caller mutation. Golden uniform and weighted traces use fixed adjacency order and sclang seed 42. Properties verify edge validity, memory/non-backtracking behavior, dead-end actions, taboo inval propagation and independent reinforcement. No external graph implementation or data is included.

## Experimental systems

All five systems in this section are experimental. No external source implementation, tables or binary data were copied. Definitions below document the implemented finite-precision contracts rather than promising equivalence to every variant of each model.

### PPM-C variable-order generation

PTRVommModel stores suffix-context count dictionaries, including order zero. Training starts a new history at every corpus sequence boundary. Sampling descends from the longest available context; for eligible total count N and distinct-symbol count T, symbol mass is count/(N+T) and escape mass is T/(N+T). Full exclusion removes higher-order eligible symbols from lower-order counts when excludeSeen is true. Missing or wholly excluded contexts are skipped. A complete mixture distribution is formed before a single weighted draw; this consumes one native RNG choice per output rather than a separate draw at each escape.

Primary reference: A. Moffat, [Implementing the PPM Data Compression Scheme](https://cs.nyu.edu/home/people/in_memoriam/roweis/csc310-2006/extras/implementing_ppm.pdf), IEEE Transactions on Communications 38(11), 1990, 1917–1921, for method-C escape estimation and exclusions. This is a symbol generator, not a compression implementation: it has no arithmetic coder, count rescaling or paper-specific storage optimizations.

The alphabet is closed to observed corpus symbols. Escape is suppressed when the eligible context covers every remaining alphabet symbol, avoiding an escape with no destination. This explicit finite-alphabet boundary adaptation is part of this experimental API. For corpus [a,b,a,c] and context [a], excluding higher-order symbols gives P(a)=1/2, P(b)=P(c)=1/4. Without exclusion, probabilities are 1/4, 3/8, 3/8. At order zero they are 1/2, 1/4, 1/4. Tests check these independently calculated probabilities, normalization across multiple suffixes, and absence of b->c training across [[a,b],[c,d]].

Counts are stored as exact-valued Floats in the guarded output range, avoiding signed Integer counter overflow. Each stream trains its own model, even with learning disabled. Online learning observes generated symbols before extending its history. Corpus tokens retain identity and must remain stable as Dictionary/Set keys. A corpus whose elements are all sequenceable is interpreted as a collection of separate sequences; nested single-sequence wrapping allows Array-valued tokens.

MaxOrder is 64 and corpus size is at most 1000000 symbols. Training key construction can take O(L × order²) work; stored context keys/counts determine memory. Sampling scans the observed alphabet at each usable order, plus context-key lookup costs. Learning can grow the context table substantially over a long run; it is not a fixed-memory predictor. Tests also verify public learning changes predictions, does not change the corpus or later frozen streams, and reproduces under a finite Pseed seed stream.

### Interleaved Petri nets

A marking maps place Symbols to nonnegative integer tokens. A transition is enabled exactly when every consume arc can be satisfied. It fires by constructing a new marking, subtracting all consumption and adding production atomically. Missing arc places are initialized to zero. Transition names are sorted for reproducible candidate order. Uniform ignores weights; weighted selects positive weights; priority restricts to the highest enabled priority before weighted selection. A zero-weight highest-priority group can cause a selectable deadlock.

Reference: T. Murata, *Petri Nets: Properties, Analysis and Applications*, Proceedings of the IEEE 77(4), 1989, 541–580, for place/transition enablement and interleaving semantics. The implementation excludes timed nets, dynamic arcs, inhibitor arcs and Function-valued priorities. Delta is nonnegative metadata, not a simulated firing delay. Output marking containers are copied; arbitrary transition values retain caller-owned identity.

Enabling scans consume arcs; firing copies O(places) state. Memory is O(places + transition arcs). Per-place counts and output indices are guarded against machine-Integer overflow. Test vectors are hand-calculated token transfers, synchronization and priority choices; a 100-step two-place net independently checks nonnegative counts and conserved total tokens.

### Kuramoto integration

The implemented angular-frequency model is

`thetaDot[i] = omega[i] + (1/N) * sum_j K[i][j] * sin(theta[j]-theta[i])`.

Scalar K fills the matrix, so a uniform matrix agrees exactly with scalar coupling. Matrix rows receive influence from columns. Frequencies are radians per unit time, not Hertz. Primary model reference: Y. Kuramoto, *Chemical Oscillations, Waves, and Turbulence*, Springer, 1984; [Cleve Moler's model discussion](https://blogs.mathworks.com/cleve/2019/10/30/stability-of-kuramoto-oscillators/) gives the same K/N convention.

Classical fixed-step fourth-order Runge-Kutta is the default, with Euler as an explicit comparison option. Stage phases are unwrapped within the step. Each final signed wrap count is floor((previousNormalizedPhase + advancement)/(2pi)), then the phase is reduced modulo 2pi. This records multiple cycle crossings and negative wraps; crossing times are not interpolated. The synchronization magnitude is sqrt(mean(cos(theta))² + mean(sin(theta))²), clipped only for floating roundoff.

The initial phases are not emitted: first output time is step. Length counts integration steps, including steps filtered out by wraps mode. Exactly stationary phase vectors terminate wraps mode immediately; otherwise more than 100000 silent steps throws. Frequencies/coupling/phases/step must be finite, step positive, N at most 128, and advancement/time/wrap/index overflow is guarded. There is no adaptive-step accuracy guarantee.

Dense work is O(N²) per derivative and four derivatives per RK4 step; storage is O(N²) for coupling plus stage/output arrays. Test vectors include the independently calculated RK4 step omega=[1,2], K=1.2, phases=[0.1,1], h=0.05 -> [0.1735274047754872,1.0764725952245129]. A stronger analytic test uses equal zero frequencies with phase difference delta(t)=2 atan(tan(delta(0)/2) exp(-K t)), checking the result at t=1. Other tests cover zero coupling, synchronization, scalar/matrix equivalence, order bounds, seeded phases, copied outputs, and multi-cycle positive/negative wraps.

### Bounded branching trees

Each root/child is a value with depth, creation index, parentIndex and childIndex metadata. Root is depth/index zero. Breadth traversal uses an append-only queue with a moving head; depth traversal uses a stack, pushing children in reverse to preserve ascending childIndex visitation. Creation indices therefore need not be emitted in numeric order under depth traversal. A parent is yielded before its children are evaluated, so resumed expansion sees the latest inval.

Reference: standard breadth-first/depth-first finite rooted-tree traversal; no third-party code or vectors were copied. Offspring can be a fixed count, a Function of copied parent metadata and inval, or a stream-local Pattern. Exhausted offspring Patterns produce no further children. MaxDepth is checked before requesting offspring. MaxNodes includes all created/emitted/queued nodes and is checked before allocating the next children; it is at most 1000000.

Memory is O(maxNodes), including references retained by the breadth queue; work is proportional to visited nodes plus user callbacks. Metadata is copied but arbitrary values are shallow and may refer to caller state. Tests use independently enumerated binary trees in both traversal orders, exact parent metadata, extinction, bounds, Pattern and seeded offspring independence, and functional Event-valued children.

### Finite Abelian sandpiles

Each item adds one grain, then runs a FIFO queue until stable or until the explicit toppling budget fails. A cell at threshold subtracts threshold and sends one grain in each orthogonal direction. Degree is 2 in 1D and 4 in 2D. Threshold may exceed degree, with the difference counted as bulk dissipation; it may not be smaller. Thus the default threshold 4 in 1D is dissipative, while threshold 2 is the conservative-interior 1D choice.

Open boundaries send out-of-grid grains to the sink. The experimental closed convention reflects those grains back to the toppled cell. Closed grids with threshold=degree conserve grains and need not stabilize. Mass above maximum stable capacity is rejected early; that necessary test is not treated as sufficient. For example, initial 2x2 grid [[3,2],[3,3]] plus a grain at linear site 0 has mass 12 (within stable capacity 12) but cycles under closed reflection. A test confirms it throws under a 20-toppling budget rather than hanging. Threshold>degree retains bulk loss even at closed boundaries.

Primary mathematical reference: D. Dhar, *Self-organized critical state of sandpile automaton models*, Physical Review Letters 64, 1990, 1613–1616. The [official SageMath sandpile tutorial](https://doc.sagemath.org/html/en/thematic_tutorials/sandpile.html) describes finite toppling, stabilization and sink models. The reflecting-closed convention, optional bulk dissipation, initial-state accounting and safety limits above are explicit implementation choices.

Size is capped at 65536 sites; maxTopplings at 1000000 per drive. Total mass is checked before addition so cell/loss counters remain exact machine Integers. Initial unstable cells are stabilized as part of the first avalanche. No state is yielded before stabilization. Each step costs O(sites + topplings), excluding callback and collection costs, and uses O(sites + queued topplings) storage. Output grid rows, drive coordinates and toppledSites arrays are fresh. The extra toppledSites field supports the required spatial examples; activeSites remains the distinct-site count.

Reference tests are hand-calculated 1D and center/boundary 2D topplings, mass accounting, drive exhaustion and copied state. A drive-order test sends the same multiset of grains in different orders on an open 3x3 grid and checks identical final state and total loss, plus stability after every emitted avalanche. No power-law distribution is claimed from the small Help demonstrations.
