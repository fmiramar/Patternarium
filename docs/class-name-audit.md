# Class-name and dependency audit

Date: 2026-11-17. Scope: foundation milestone, with provisional future names checked locally. Recheck before each later milestone and before release.

## Local source scan

Searched class declarations in `/Applications/SuperCollider.app/Contents/Resources/SCClassLibrary`, the user's `Library/Application Support/SuperCollider/Extensions`, and `downloaded-quarks` using anchored `rg` queries. No declaration matches for any of the 19 provisional public names or the five planned PTR helper names. Only `PTRValidation` is currently implemented. The configured external Probe path was not audited; the runtime symbol audit is still required.

`scripts/audit-class-names.scd` safely resolves symbols with `asClass` and reports each source filename. Run it **before installing Patternarium**, using the normal extension configuration. The local run aborted in Qt before compiling the library: `Incompatible processor. This Qt build requires ... neon`. A source scan does not establish the absence of runtime collisions.

## Public sources checked

- [Community directory](https://github.com/supercollider-quarks/quarks/blob/master/directory.txt): package index inspected; it is not a class index.
- [Core Streams sources](https://github.com/supercollider/supercollider/tree/develop/SCClassLibrary/Common/Streams).
- Public web searches for each foundation class name combined with SuperCollider returned no relevant exact-name implementation. This is a limited search, not an exhaustive audit of every public repository or Quark source.

## Semantic overlap and decision

| New class | Existing mechanism | Added behavior |
| --- | --- | --- |
| Pscan | Pattern.integrate, Pseries, Pfunc | Explicit general state, source input, index, latest inval, optional initial output and transition limit. |
| Pwindow | Pclump, Pslide | Lazy windows over arbitrary streams, overlap/gaps, and one final partial only after new items. Pslide indexes an existing collection. |
| Ptransduce | Pcollect, Pselect, Prout | Explicit persistent state and zero/one/many output protocol, stop semantics and natural-end flush. |
| Pmorphism | Prewrite | Parallel generation snapshots, neighbor context, independently evaluated Pattern replacements and hard generation bounds. Prewrite recursively embeds terminal rewrites. |

No fallback names selected on the evidence above. Runtime symbol audit and broader repository review remain release gates. No external dependencies or copied third-party implementations were added.

## Runtime follow-up and sequence milestone

The normal configured runtime audit completed successfully on SuperCollider 3.14.1 after the session received full execution access. Before loading Patternarium, every one of the 19 provisional public Symbols and five planned helper Symbols resolved to nil, including the externally configured Probe path. No fallback is needed in this installation. The earlier NEON startup failure was environmental, not a collision.

For milestone 2, exact-name public searches for PdeBruijn, PgrayCode, Pqmc, ProtationWord and PnumSeq found no relevant implementation. The Community directory was checked again. The MathLib source repository was inspected at commit `c539982578da73ad29ea291ddb82babd9465df12` (https://github.com/supercollider-quarks/MathLib). No exact new public/helper class names occur. Its P3n1/Pcollatz cover Collatz recurrences, not the ten registry sequences. Its Preduce reduces simultaneous values from parallel streams, rather than accumulating state across time. Plsys offers lazy rewriteString-based L-systems with contextSize; Pmorphism's complete parallel-generation snapshots and explicit expansion bound remain a distinct requirement. None of this source was copied or installed as a dependency.

Sequence implementation decisions:

| New class | Comparison | Reason for keeping the new class |
| --- | --- | --- |
| PdeBruijn | Pseq/Pslide | Exhaustive cyclic n-word coverage generated with FKM, rather than a supplied list. |
| PgrayCode | Ptuple/Pseries | Reflected traversal of a product state space with unit adjacency. |
| Pqmc | Pwhite/Pseries | Radical inverses and irrational multidimensional coordinates with explicit index sampling. |
| ProtationWord | Pseries plus arithmetic | Precisely documented mechanical and partition codings, including normalization and boundary assignment. |
| PnumSeq | MathLib P3n1/Pcollatz | Curated fixed registry of ten other named sequences with exact indexing and output contracts. |

The audit is evidence from the installed class set, directory, MathLib and public search; it does not claim to exhaust every unindexed or private repository. Recheck before publication and before later milestone classes are added.

## Point-process and graph-system milestone

The normal pre-install audit was rerun on SuperCollider 3.14.1 on 2026-11-17; PpointProcess, Prenewal, Phawkes, Pconstraint, PgraphWalk, PTRPointProcess and PTRGraph are absent from the configured class set. Exact-name public searches found no matching SuperCollider class implementation. The Community Quark Directory remains a package index, so this is not a guarantee about unindexed repositories.

Compared the core Pexprand/Pwhite/Pseries timing machinery, Pwalk and Pfsm, and MathLib MarkovSet. Pexprand is log-uniform rather than an exponential waiting-time sampler; no existing core abstraction supplies the shared arrival-time/output contract here. Pwalk indexes a list, Pfsm follows a finite-state graph, and MarkovSet supports weighted learned transitions. PgraphWalk adds the specified edge metadata, explicit dead-end policy, hard taboo/self-avoidance and soft memory/non-backtracking policies, with per-stream reinforcement. Pconstraint differs from rejection filtering by solving the entire finite sequence before exposing any value, with an explicit bounded search failure. A public backtracking composition example exists at https://sccode.org/1-1i; no implementation code was copied and it is not a reusable class satisfying the full required contract.

No fallback names or external dependencies were introduced. Independent API/algorithm review remains a release gate; the repository does not claim an independent second-provider review has occurred.

## Experimental-systems milestone

The configured pre-install runtime audit again resolves Pvomm, Ppetri, Pkuramoto, Pbranching, Psandpile and PTRVommModel to nil. Exact-name public searches found no matching SuperCollider class declarations. These results do not guarantee absence from unindexed/private repositories.

Reviewed MathLib MarkovSetN and ShannonMarkovSet: they provide fixed/requested-order transition and corpus search mechanisms, rather than the specified PPM-C escape/exclusion mixture and per-stream Pattern API.

A broader semantic search found SCMIR's existing PPMC and PPMCOnline. Inspected the primary source at SCMIR tree revision `59ae32b9c2b331b1a561865def98b491a74bccb9`, `SCMIRExtensions/Classes/SCMIRLearning/PPMC.sc` and `PPMCOnline.sc` (https://github.com/sicklincoln/SCMIR). Its source identifies an AX variant and explicitly notes that exclusion is not implemented. It is therefore not a drop-in implementation of this plan's required excluded-symbol PPM-C policy and stream-local Pattern contract. Patternarium uses a small original model with a documented closed-alphabet boundary rule and no SCMIR dependency; no implementation was copied.

The Thr44 Petri framework appears in published SuperCollider composition literature, including https://oro.open.ac.uk/81935/1/Bellingham_Choosers_2021.pdf. Its source was not located/inspected in this audit, so no claim of complete comparison is made. Ppetri is scoped to the specified headless interleaved token/value generator, without attaching audio files, GUI patchers or external runtime resources. This remaining broader comparison should be revisited during independent API review.

Kuramoto phase integration differs from the core Phasor UGen by running a language-side coupled numerical network; Pbranching adds bounded explicit tree metadata/traversal to recursive sequencing; Psandpile implements the specifically permitted finite sandpile model rather than a general cellular-automaton framework. No fallback names, plugin classes or external dependencies were added.
