# Seeded ChainHash: proved bounds and the single-seed gap

Models A and B below have proved nontrivial collision bounds for the **unchanged raw-product ChainHash**. Model C retains the conditional five-wise finalizer theorem, but the field-power PH argument does not supply a useful collision bound after reusing its seed in the recurrence. Model D has neither that independence theorem nor a useful bound established here. The trivial bounds shown for C/D are certificates, not estimates of their true worst collision probabilities.

This document and `THEOREMS.tex` contain the same mathematical text. The reference is the supplied `appendix_chainhash.tex`, especially `lem:ph:stream`, `lem:ph:injective`, `lem:ph:twist`, and `thm:ph:kwise`. No pseudorandom-generator assumption is used. Computation is evidence reported in `REFEREE.md`, not a substitute for the proofs.

**Formalization status.** The model-A portions of Theorems 1 and 2 are
Lean-proved in [ModelA.lean](../lean/ProvenHashes/ModelA.lean), as
`ProvenHashes.ChainHash.ModelA.reference_collision_bound_fixed` and
`reference_collision_bound_atMost`. They use exactly `d(L)` and `E_A(L)`
below, with the ten independent uniform words in the table. All stage,
field, encoding, and finalizer obligations are discharged; the axiom audit
allows only `propext`, `Classical.choice`, and `Quot.sound`.
Model B's portions of Theorems 1 and 2, including the recurrence substitution
in Lemma 7, remain written proofs: the completed model-A lane contains no
model-B Lean theorem to import. This status does not claim that every
auxiliary statement, score, or sharper pair-specific formula in this
write-up is formalized. See [the Lean catalogue](../lean/THEOREM_STATEMENTS.md)
for the exact checked statements.

## 1. Assumptions, schedules, and interpretation of the numbers

Put $q=2^{64}$ and $F=\mathbb F_2[X]/(X^{64}+X^4+X^3+X+1)$. A word is its polynomial-basis representative of degree below 64. Write $\operatorname{clmul}$ for the **unreduced** binary-polynomial product, and juxtaposition for multiplication in $F$ when the operands are field elements. Reduction sends $X^{64}$ to $r=27$; consequently $1+r=26\ne0$ in $F$.

Messages are fixed, distinct byte strings chosen independently of the random key. Their lengths satisfy $0\le\ell<q$. Words are little endian. There are 32 words per 256-byte block and one stream pair per block: $W=32,S=1$, $n(m)=\max(1,\lceil\ell(m)/256\rceil)$. Each nonempty last four-word group is padded with zero bytes. Positions $4j,4j+2$ form one product, and positions $4j+1,4j+3$ the other. Each position is XORed with the key at that same position. An empty block has no products. The byte length is XORed into **both** halves of the last raw block result.

For the resulting stream $((a_i,b_i))_{i=1}^n$, the unchanged hash is

$$
 P_0=z,\qquad P_i=a_i+(b_i+y)(P_{i-1}+u),\qquad V=P_n,
$$

$$
 H(m)=f_c(V\boxplus\tau),\qquad
 f_c(x)=(x+c_2)\big((x^2+c_0)(x+x^2+c_1)+c_3\big)+c_4.
$$

Here $\boxplus$ is integer addition modulo $2^{64}$, not field addition. No change to these operations is contemplated.

The symbols $c_i$ denote the five **circuit parameters** used in the code. Their bijective correspondence with the five ordinary polynomial coefficients is proved below. In A/B/C, $c=(c_0,\ldots,c_4)$ is joint uniform on $F^5$ and independent of all upstream randomness. This requires 320 genuinely random bits for $c$ alone; a deterministic 64-bit expander cannot meet that hypothesis. All random words listed below are mutually independent and uniform, including zero.

| Model | Independently sampled material | Expanded schedule | Random input bytes |
|---|---|---|---:|
| A | $s,u,y,z,c_0,\ldots,c_4,\tau$ | $k_i=s^{i+1}$, $0\le i<32$ | 80 |
| B | $s,t,c_0,\ldots,c_4$ | $k_i=s^{i+1}$; $(u,y,z)=(t^2,t^3,t)$; $\tau=s^4$ | 56 |
| C | $s,c_0,\ldots,c_4$ | $k_i=s^{i+1}$; $(u,y,z)=(s^2,s^3,s)$; $\tau=s^4$ | 48 |
| D, reference | $s$ | C's PH/chain keys; $c_i=s^{33+i}$; $\tau=s^{38}$ | 8 |

The current repository header still stores **41 expanded words, 328 bytes**, in every model. These are entropy/input-size savings, not resident-state savings. In particular B is not a seven-word resident-key implementation under the paper's separate cache-line criterion. The legacy SplitMix64 expansion is not any of these models.

Independence of $\tau$ from the upstream keys is unnecessary: a fixed $\tau$, or any function of $(s,t,u,y,z)$, works in A/B/C. The sufficient condition used by the proof is that, after conditioning on the upstream keys and $\tau$, $c$ remains uniform on $F^5$. Thus $\tau=s^4$ costs no new random word. Arbitrary dependence on $c$ is not justified by the twist lemma. A retains an independent $\tau$ as requested; optional independent twists would make B/C 64/56 bytes.

An $\varepsilon$ below is an explicitly proved **upper bound**, not a claim that the worst pair attains it. The displayed scores use these published bounds, as the paper's scoring convention does. Define $L\ge1$ to be an integer number of eight-byte words, with $8L<q$. The fixed-length column means **both** messages have length exactly $8L$. A separate envelope covers every pair of lengths at most $8L$, including the empty message. The empty length itself is excluded from the score because $\log_2(0/\varepsilon)$ is undefined. KB and MB here mean 1024 and 1048576 bytes.

## 2. Main bounds and scores

For positive integer $L$, let $n=\lceil L/32\rceil$, $R=L-32(n-1)$, and $G=\lceil R/4\rceil$. Define

$$
 d(L)=\begin{cases}
 1&L=1,\\
 2&L=2,\\
 4\lfloor(\min(L,32)-1)/4\rfloor+3&L\ge3,\ \min(L,32)\equiv1\pmod4,\\
 4\lfloor(\min(L,32)-1)/4\rfloor+4&\text{otherwise}.
 \end{cases}
$$

The values begin $1,2,4,4,7,8,8,8,11,12,\ldots,31,32,32,32$ and remain 32 after the first block. The improvements at one and two words count distinct roots instead of counting the multiplicity of the root zero.

**Theorem 1 (fixed-length certificates).** For A and B respectively, on messages of length exactly $8L$,

$$
 \varepsilon_A^{=}(L)=\min\{1,(d(L)+n+1)/q\},\qquad
 \varepsilon_B^{=}(L)=\min\{1,(d(L)+3n)/q\}
$$

are collision bounds. C and D always have the trivial certificates $\varepsilon_C^{=}(L)=\varepsilon_D^{=}(L)=1$. No nontrivial uniform certificate for C/D is asserted here.

**Theorem 2 (all lengths up to a limit).** Define

$$
 E_A(L)=\begin{cases}8G&n=1,\\ n+62+\mathbf1_{R\ge29}&n\ge2,\end{cases}
 \qquad
 E_B(L)=\begin{cases}8G+1&n=1,\\3n+59+3\mathbf1_{R\ge29}&n\ge2.\end{cases}
$$

Then $\varepsilon_A^{\le}(L)=\min(1,E_A(L)/q)$ and $\varepsilon_B^{\le}(L)=\min(1,E_B(L)/q)$ bound every pair of distinct byte strings of lengths at most $8L$. In particular unequal lengths must **not** be silently assigned the fixed-length formulas. The simpler, slightly looser envelopes $(n+63)/q$ and $(3n+62)/q$ hold for every $L$.

| Model | Random bytes | Fixed-length $\varepsilon^{=}(L)$ | Fixed-length score; minimizing $L$ | At-most score; minimizing $L$ | 256 B / 1 KB / 1 MB, fixed length |
|---|---:|---|---|---|---|
| A | 80 | $(d+n+1)/q$ | $62.4150374993$; 1 | $61$; 1 | $34/q$, $37/q$, $4129/q$ |
| B | 56 | $(d+3n)/q$ | $62$; 1 | $60.8300749986$; 1 | $35/q$, $44/q$, $12320/q$ |
| C | 48 | $1$ only established | $0$ from trivial certificate; 1 | $0$ from trivial certificate; 1 | $1$, $1$, $1$ only established |
| D | 8 | $1$ only established | $0$ from trivial certificate; 1 | $0$ from trivial certificate; 1 | $1$, $1$, $1$ only established |

The exact nonintegral scores in the table are $64-\log_2 3$ for fixed-length A and $64-\log_2 9$ for at-most B. The true worst-probability scores of C/D are **undetermined**; the zeros in this table are not attacks proving zero security. The clipping at one in the theorem definitions is understood in the table.

| Model and domain | 256 B | 1 KB | 1 MB |
|---|---:|---:|---:|
| A, fixed | $34/q$ | $37/q$ | $4129/q$ |
| B, fixed | $35/q$ | $44/q$ | $12320/q$ |
| A, at most | $64/q$ | $67/q$ | $4159/q$ |
| B, at most | $65/q$ | $74/q$ | $12350/q$ |

These probabilities correspond, for example, to fixed-length collision exponents $58.9125,58.7905,51.9884$ bits for A and $58.8707,58.5406,50.4113$ for B. These exponents $-\log_2\varepsilon$ differ from the length-normalized score $\log_2(L/\varepsilon)$.

## 3. Seeded PH and the stream lemma

**Lemma 3 (the exponents actually touched).** In one group, a difference in positions $4j,4j+1,4j+2,4j+3$ multiplies key powers with exponents

$$ (4j+3,\ 4j+4,\ 4j+1,\ 4j+2), $$

respectively. For sub-blocks with the same group count, reduction of their raw PH difference minus any fixed 128-bit target is a polynomial in $s$. Its nonconstant coefficients are exactly the word differences, each in its own exponent. It is nonzero whenever a word differs. Its degree is bounded by the largest touched exponent having a nonzero difference.

If two sub-blocks have different group counts and the larger count is $g\ge1$, their reduced difference minus any target is nonzero of degree exactly $8g-2\le62$.

**Proof.** Expand a strided product in characteristic two. The key-only product cancels when the pair is present on both sides, and its two linear terms place the two word differences on their partner keys. All partner exponents are distinct. Data-data products and the target contribute only the constant coefficient, so cannot cancel any nonzero nonconstant coefficient. When a pair is present only on the longer side, its key-only product survives. Group $j$ contributes powers $s^{8j+4}$ and $s^{8j+6}$. These exponents are distinct across all groups. The highest is $8g-2$, has coefficient one, and exceeds every possible linear exponent $4g$. It therefore cannot cancel. Reduction of raw products is legitimate here because a raw equality implies the corresponding field equality. The converse is not used. $\square$

In particular, the reduced-PH observation in `user_note.md` is valid at this stage. It does **not** assert that each separate raw half is a low-degree polynomial in the seed.

**Lemma 4 (stream separation without a factor for the number of blocks).** Suppose $m\ne m'$. If their block counts differ, their streams differ for every $s$. If their block counts agree, select one nontrivial component equation required for stream equality, for example the first differing sub-block. For a nonfinal block its target is zero; for the last it is

$$ C=(\ell\mathbin{\mathrm{xor}}\ell')(1+X^{64}). $$

Its reduction is the constant $(\ell\mathbin{\mathrm{xor}}\ell')\,26$. Give this equation the following root budget $\alpha$:

1. Same padded words and same group count, but different final length: $\alpha=0$.
2. Same group count and different words: the largest partner-key exponent at a differing position.
3. Different group counts, larger count $g$: $\alpha=8g-2$.

For equal one-word messages replace case 2 by $\alpha=1$; for equal two-word messages use $\alpha\le2$. Then

$$ \Pr_s[\sigma_s(m)=\sigma_s(m')]\le\min(1,\alpha/q). $$

Any available component equation may be used; taking the minimum of their individual budgets is valid. In particular the padded-last-block deterministic separation holds even when earlier blocks differ.

**Proof.** Different stream lengths cannot be equal. With the same number of blocks, stream equality implies every component equation, hence implies the selected one. Case 1 is impossible since $\ell\ne\ell'$ and $26\ne0$. Cases 2 and 3 follow from Lemma 3 and the fact that a nonzero degree-$d$ polynomial has at most $d$ distinct roots in a field. This root fact follows by repeatedly dividing by $T-a$ for each distinct root; their product divides the polynomial and its degree cannot exceed $d$.

For equal one-word messages only position zero varies; the raw difference is $\operatorname{clmul}(\delta,s^3)$, $\delta\ne0$. The polynomial ring is an integral domain, so it vanishes exactly at $s=0$. For two words the reduced difference has the form $s^3(\delta_0+\delta_1s)$ with at least one nonzero coefficient; there are at most two distinct roots. No data-data constant occurs, since both partner words are zero-padded. These refinements concern equal lengths only. For equal longer lengths a differing block exists; a full block has budget at most 32, while the partner exponents in the last partial block give exactly the upper envelope $d(L)$. Only one necessary equation was used, so there is no union bound over blocks. $\square$

## 4. Recurrence injectivity and the correct substitution

**Lemma 5 (formal recurrence decoder).** For a stream of length $n\ge1$, in $F[U,Y,Z]$ one has

$$
 P_n=A(Y)+Z B(Y)+U C(Y),\quad
 g_i=\prod_{j=i}^n(Y+b_j),\quad
 A=\sum_{i=1}^n a_i g_{i+1},\quad B=g_1,\quad C=\sum_{i=1}^n g_i.
$$

Here $g_{n+1}=1$, $B,C$ are monic of degree $n$, and $\deg A\le n-1$. The stream-to-polynomial map is injective. Distinct streams of the same length have a nonzero difference of total degree at most $n$; for different lengths the difference has degree exactly $\max(n,n')+1$.

**Proof.** Expanding one recurrence step gives the updates $A_i=a_i+(Y+b_i)A_{i-1}$, $B_i=(Y+b_i)B_{i-1}$, and $C_i=(Y+b_i)(C_{i-1}+1)$, initially $(0,1,0)$. These prove the displayed formulas.

To decode a suffix of length $h$, write its product and sum of suffix products as $(B,C)$. The coefficient of $Y^{h-1}$ in $B$ is the sum of its $b$'s. The coefficient of $Y^{h-2}$ in $C+B$ is the sum of all but its first $b$, plus $\mathbf1_{h\ge3}$. Interpret a negative coefficient index as zero. Therefore its first $b$ is

$$ [Y^{h-1}]B+[Y^{h-2}](C+B)+\mathbf1_{h\ge3}. $$

Divide $B$ by the now known monic factor $Y+b_1$, and replace $C$ by $C+B$ using the old $B$. This yields the same two objects for the suffix with the first pair removed. Iterate. Once the $b_i$ and $g_i$ are known, read $a_1$ from degree $n-1$ of $A$, subtract $a_1g_2$, and continue in descending degrees. This reconstructs the whole stream. Finally the total-degree-$n+1$ part is $(Z+U)Y^n$, independent of the data. It cancels for equal lengths; for unequal lengths the longer stream's leading part survives. $\square$

**Lemma 6 (three independent recurrence keys).** Condition on any fixed PH key for which the streams differ. With independent uniform $u,y,z$, the conditional collision probability is at most $n/q$ for streams of common length $n$, and at most $(N+1)/q$ for different lengths, where $N=\max(n,n')$.

**Proof.** Lemma 5 gives a nonzero polynomial of the stated total degree. For completeness, a polynomial of total degree $D$ evaluated at independent uniform field elements has zero probability at most $D/q$. Induct on the number of variables: write it as $\sum_{j=0}^h Q_j T^j$ with $Q_h\ne0$. The leading coefficient vanishes with probability at most $(D-h)/q$ by induction; otherwise the univariate root bound is $h/q$. Their sum is $D/q$. This also holds when the sum exceeds one after clipping. Independence of the recurrence keys from $s$ permits this conditioning. $\square$

**Lemma 7 (one independent recurrence seed).** Set $(U,Y,Z)=(T^2,T^3,T)$. The formal map from streams to polynomials in $T$ is still injective, including across different stream lengths. Equal-length differences have degree at most $3n-1$; different-length differences have degree exactly $3N+2$.

**Proof.** The three terms become $A(T^3)$, $T B(T^3)$ and $T^2 C(T^3)$, whose exponents lie respectively in residue classes $0,1,2$ modulo 3. Extracting these classes recovers $A,B,C$ coefficient by coefficient. Lemma 5 therefore still decodes the stream. The leading degree is $3n+2$; the coefficients at degrees $3n+2,3n+1,3n$ are always $1,1,0$. Equal-length subtraction cancels them; unequal-length subtraction preserves the longer polynomial's leading term. Evaluating the independent uniform $t$ and applying the univariate root bound proves conditional probabilities at most $(3n-1)/q$ and $(3N+2)/q$. No multivariate nonzero claim has been assumed to survive substitution without proof. $\square$

**Exponent choice and scope of optimality.** Among the six assignments that permute exponents $1,2,3$, precisely the two residue-separated assignments with $y=T^3$ have the above general injectivity guarantee. They tie at degree $3n-1$ for equal lengths and $3n+2$ otherwise. More generally, in the residue-separated monomial embedding $Y=T^e$, the residues of $1,T^{e_u},T^{e_z}$ must be distinct modulo $e$. Thus $e\ge3$ and the smallest two positive offsets are 1 and 2. Our assignment minimizes the resulting degree within that construction, uniformly in the stream length. We do not claim a global optimization theorem over every possible large exponent triple and every possible different decoder.

The apparently better $(u,y,z)=(T,T^2,T^3)$ is not injective. Let $\alpha^2+\alpha+1=0$ in the subfield $\mathrm{GF}(4)\subset F$. Take all $a_i=0$ and the length-three $b$-vectors

$$ (\alpha,\alpha,\alpha)\quad\hbox{and}\quad(\alpha+1,1,0). $$

Their specialized polynomials are identical. To verify it, write $Y=T^2$ and divide the odd polynomial $P$ by $T$. The recurrence becomes $R_0=Y$, $R_i=(Y+b_i)(R_{i-1}+1)$. For the first vector the final polynomial is

$$Y^4+\alpha^2Y^3+\alpha^2Y,$$

and direct expansion for the second gives the same result. This identity holds in $F[T]$, not merely on a finite sample. One actual field representative of $\alpha$ is `0x19c9369f278adc02`.

For completeness the other assignments with $y\ne T^3$ also fail. For $(u,y,z)=(T^3,T,T^2)$ and $(T^3,T^2,T)$, all-zero $a$ and $b$-vectors $(0,0,0)$ and $(1,0,1)$ give identical polynomials. For $(T^2,T,T^3)$ use $b=(0,0,1)$ versus $b'=(0,1,0)$: their all-zero-$a$ difference is $T^2$; adding $a'=(1,1,0)$ cancels it, since its contribution is $(T+1)T+T=T^2$. These are counterexamples to recurrence injectivity on streams; they are not being advertised as fixed message-pair collisions in full ChainHash under every PH seed.

## 5. Finalizer, twist, and composition

**Lemma 8 (uniform finalizer and a free twist).** For independent uniform $c\in F^5$, the displayed circuit is a uniformly random monic degree-five polynomial. At any two distinct fixed inputs its collision probability is exactly $1/q$. At up to five distinct fixed inputs its values are independent uniform. All these conclusions hold after any common bijection of the inputs that is fixed by conditioning while $c$ remains uniform.

**Proof.** Put $b=c_0+c_1$ and $d=c_0c_1$. Expansion gives $f_c(x)=x^5+\sum_{i=0}^4e_ix^i$, with

$$
 e_4=1+c_2,\quad e_3=b+c_2,\quad e_2=c_0+c_2b,\quad
 e_1=d+c_3+c_0c_2,\quad e_0=c_4+c_2(d+c_3).
$$

Conversely recover, in this order,

$$
 c_2=e_4+1,\quad b=e_3+c_2,\quad c_0=e_2+c_2b,\quad c_1=b+c_0,
$$

$$ c_3=e_1+c_0c_1+c_0c_2,\qquad c_4=e_0+c_2(c_0c_1+c_3). $$

This is a two-sided inverse, so $e$ is uniform on $F^5$. For distinct $v,v'$, the coefficient of $e_1$ in $f(v)+f(v')$ is $v+v'\ne0$; conditioning on all other $e_i$ leaves exactly one colliding $e_1$. For $j\le5$ distinct points, the evaluation matrix with columns $1,v,\ldots,v^4$ has rank $j$, because its first $j$ columns form an invertible Vandermonde matrix. Every output vector has exactly $q^{5-j}$ coefficient preimages; adding the monic term is a fixed translation. A bijection preserves distinctness. Integer addition by any fixed $\tau$ is a bijection, with inverse subtraction modulo $q$. $\square$

**Theorem 9 (pair-specific A/B bounds, including unequal lengths).** Let $p_{12}=\Pr[V(m)=V(m')]$. If block counts agree, let $\alpha$ be any budget from Lemma 4, and put $b=n$ in A and $b=3n-1$ in B. Then, writing $a=\min(1,\alpha/q)$ and $v=\min(1,b/q)$,

$$ p_{12}\le a+(1-a)v,\qquad
 \Pr[H(m)=H(m')]=q^{-1}+(1-q^{-1})p_{12}.
$$

In particular the simpler bound is $\min(1,(\alpha+b+1)/q)$. For different block counts use $a=0$ and $b=N+1$ in A or $b=3N+2$ in B. These give the simpler bounds $(N+2)/q$ and $(3N+3)/q$, clipped at one.

**Proof.** Streams coincide with probability at most $a$. Condition on each $s$ for which they differ; Lemma 6 or 7 bounds the conditional recurrence collision by $v$. Thus $p_{12}\le a+(1-a)v$; monotonicity in the actual stream-collision probability justifies substituting its upper bound. Different block counts make stream equality impossible. Condition now on all upstream words and $\tau$. If $V=V'$, the final hash collides certainly; otherwise Lemma 8 gives probability exactly $1/q$. Average these disjoint alternatives. This also proves that the finalizer contributes $1/q$, rather than multiplying a seed-degree bound by five. The derived twist has disappeared from the argument without assuming it independent of the earlier seed. $\square$

**Proof of Theorems 1 and 2.** For equal length, Lemma 4 supplies $\alpha\le d(L)$. Substitution into Theorem 9 gives Theorem 1.

For a maximum byte length $8L$, first fix a common block count $k$ and a limit $r$ on the number of words in its last block. When $k=1$, different group counts (including an empty message) have root budget at most $8\lceil r/4\rceil-2$, which also dominates the equal-group budget. When $k\ge2$, an earlier differing full block costs at most 32, so the common-count budget is at most

$$ \max\{32,8\lceil r/4\rceil-2\}. $$

For $k<n$, the largest possible contribution occurs at $k=n-1$, with a full last block. Its A numerator is $62+(n-1)+1=n+62$; its B numerator is $62+3(n-1)=3n+59$. For $k=n$, the numerators are $n+1+\max(32,8G-2)$ and $3n+\max(32,8G-2)$. Taking the maximum yields exactly the piecewise $E_A,E_B$ in Theorem 2: $8G-2\le54$ for $R\le28$, and equals 62 for $R\ge29$. The different-count bounds $n+2$ and $3n+3$ are dominated by these common-count envelopes. This maximizes the proved degree bounds over the permitted lengths, not actual collision probabilities. Clipping at one finishes the proof. $\square$

**Proof of the score claims.** At $L=1$, the fixed-length numerators are 3 and 4, and the at-most numerators are 8 and 9. For $2\le L\le32$, the partner-exponent formula gives $d(L)\le L+2$ (with the stated further improvement at $L=2$). Consequently $d+n+1<3L$ and $d+3n<4L$. For $L\ge33$, use $d=32$ and $n\le(L+31)/32$ to obtain the same strict inequalities. The at-most numerators for $L\le32$ satisfy $8\lceil L/4\rceil\le2L+6$ and $8\lceil L/4\rceil+1\le2L+7$, strictly below $8L$ and $9L$ for $L>1$. For $L\ge33$ the bounds $n+63<8L$ and $3n+62<9L$ suffice. Thus every minimum occurs uniquely at $L=1$. For the trivial certificate $\varepsilon=1$, the score is $\log_2L$ and has the same unique minimizer. $\square$

The slightly stronger multiplicative bounds in Theorem 9 have not been substituted into the published score table; doing so changes tiny lower-order terms. As an additional exact check, for A and two distinct eight-byte messages the worst final collision probability is

$$ \frac{3q^2-6q+4}{q^3}. $$

Indeed their PH difference is $\operatorname{clmul}(\delta,s^3)$. It is zero exactly at $s=0$. If its high half is nonzero, the independent uniform $z+u$ gives exactly one recurrence collision out of $q$; if the high half is zero and the raw value is nonzero, none. For any $\delta\ne0$, the high half is zero for at least the four seeds with $s^3\in\{0,1\}$, since $3\mid(q-1)$. For $\deg_X\delta=63$ these are exactly all such seeds. Hence the largest pre-final collision probability is $(2q-4)/q^2$, and Theorem 9's exact composition identity gives the stated expression. This is consistent with, and slightly below, the table's $3/q$ certificate.

## 6. The five-wise statement that actually survives

**Theorem 10 (conditional independence and distance bound).** In A/B/C let $m_1,\ldots,m_j$, $j\le5$, be distinct fixed messages, and let $\mathcal D$ be the event that their level-two values are pairwise distinct. Conditioned on any upstream key in $\mathcal D$ and its scheduled twist, their final hashes are independent uniform on $F^j$. Unconditionally, their law has total-variation distance from uniform at most

$$ \Pr[\neg\mathcal D]\le\min\left(1,\sum_{i<h}\Pr[V(m_i)=V(m_h)]\right). $$

For A/B, each summand has the bound in Theorem 9. In particular for messages of one fixed length use $\binom j2(d(L)+n)/q$ in A and $\binom j2(d(L)+3n-1)/q$ in B; for arbitrary lengths up to $8L$, use $\binom j2(E_A(L)-1)/q$ and $\binom j2(E_B(L)-1)/q$, all clipped at one. For C the conditional assertion remains exact, but this work supplies no nontrivial uniform upper bound for $\Pr[\neg\mathcal D]$.

**Proof.** A union bound gives the bound on $\neg\mathcal D$. On every good conditioned key, Lemma 8 gives the uniform output law. Averaging over good keys still gives uniform. Thus the unconditional law is $(1-p)U+pR$, where $p=\Pr[\neg\mathcal D]$, $U$ is uniform, and $R$ is some probability law; its total-variation distance from $U$ is at most $p$. The conditioning fixes the twist but does not alter the uniform finalizer coefficients. $\square$

This is **not unconditional exact five-wise independence of the message hash**. For example two eight-byte messages containing the words 0 and 1 have the same raw PH value at $s=0$. Thus $p_{12}\ge1/q$ in A/B/C, and their final collision probability is strictly greater than $1/q$. They are not even unconditionally pairwise independent. The qualification in the original `thm:ph:kwise` is essential. Conditional uniformity of five outputs needs at least $q^5$ equally weighted possibilities in the remaining randomness, hence at least 320 random bits, matching the five independent $c$ words.

## 7. What can and cannot be concluded for C and D

**Theorem 11 (exact reduction to seed counts; no unsupported degree claim).** For the specified C schedule, define

$$ N_C(m,m')=\#\{s\in F:V_s(m)=V_s(m')\}. $$

For every fixed pair, including unequal lengths,

$$ \Pr_C[H(m)=H(m')]=\frac{q+(q-1)N_C(m,m')}{q^2}. $$

For D define $N_D(m,m')=\#\{s:H_s(m)=H_s(m')\}$. Its collision probability is exactly $N_D(m,m')/q$. These identities and $0\le N_C,N_D\le q$ prove the displayed trivial certificates. Determining a useful worst-pair bound for these counts in the 64-bit field is an unresolved part of the requested program, not a consequence of the supplied note.

**Proof.** In C the upstream key is determined by $s$ and the finalizer is independent. Apply the exact identity in Theorem 9 and $p_{12}=N_C/q$. In D all randomness is the one uniformly sampled seed, so count the successful seeds directly. $\square$

**Proposition 12 (a concrete 64-bit lower bound).** For the two eight-byte messages containing the numerical words $0$ and $\delta=2^{63}+3$, both C and D have pre-final collisions at $s=0$ and $s=2$. Consequently the full collision probability is at least $3/q-2/q^2$ in C and at least $2/q$ in D.

**Proof.** At $s=0$ the differing word's partner key is zero. At $s=2=X$, the partner key is $s^3=X^3$ and the raw difference is

$$ (X^{63}+X+1)X^3=X^{66}+X^4+X^3. $$

Its low/high halves are 24 and 4, while $u+z=s^2+s=6$. The one-step recurrence difference is therefore $24+6\cdot4=0$ in $F$. Equal lengths cancel their length words and all common terms. Apply Theorem 11 for C; in D the two equal pre-final values certainly stay equal. No claim that these are the only roots is required. $\square$

There are two separate obstructions to the proposed shortcut for C. First, after conditioning on $s$ to make the stream coefficients constant, there is no remaining independent recurrence seed on which to apply Lemma 7. Nonzero multivariate polynomials can vanish identically on a diagonal; injectivity over independent variables does not settle this. Second, the actual hash feeds the raw low and high words to the recurrence. Only their combination $a+27b$ is the reduced PH polynomial of small degree. A bit projection of a field element is a linearized field polynomial of degree $2^{63}$, not generally a degree-one field polynomial.

Here is a concrete verification of the second obstruction. Take two same-length sub-blocks differing by $2^{63}$ at position 2, with all other message words zero. Their raw PH difference is $\operatorname{clmul}(2^{63},s)$, whose low half is $2^{63}$ times the least significant bit of $s$. Every nonzero binary linear functional on $F$ is $s\mapsto\operatorname{Tr}(\beta s)$ for a nonzero $\beta$ (the trace pairing is nondegenerate); its unique degree-below-$q$ polynomial is

$$ \operatorname{Tr}(\beta s)=\sum_{i=0}^{63}\beta^{2^i}s^{2^i}, $$

of degree exactly $2^{63}$. To see nondegeneracy without an assumption, the polynomial $\sum_{i=0}^{63}T^{2^i}$ is nonzero of degree $2^{63}<q$, so its trace map is not identically zero; for nonzero $\beta$, multiplication by $\beta$ is a bijection. The trace pairings give all 64-dimensional binary dual functionals. Polynomial-function uniqueness below degree $q$ follows from the root bound. Thus the low-half function in this example cannot have the claimed degree at most 32, although its reduced PH difference has degree one. Cancellation between the two raw halves is crucial to the note's proof and is lost with a seed-dependent recurrence multiplier.

The GF(256) referee gives a further explicit warning. With the faithfully scaled C schedule and modulus $X^8+X^4+X^3+X+1$, the one-word messages `16` and `61` in hexadecimal have pre-final collisions at seeds `00 28 3b 41 c3 ee`: six of 256. Their full collision probability, integrating the independent finalizer exactly, is $1786/65536\approx0.0272522$, exceeding the unjustified B-style $4/256$ bound. This disproves that general substitution argument for scaled ChainHash. It does not by itself disprove any particular numerical bound over GF$(2^{64})$.

In D there is the additional loss of independent finalizer coefficients. One cannot keep the $1/q$ finalizer term, use the Vandermonde uniformity argument, or automatically multiply a preceding bound by five. The integer-add twist also introduces carries and is not a small-degree field polynomial in its arguments. Even without those carries, a seed-dependent polynomial finalizer could identify two distinct seed-dependent inputs identically; a nonzero-composition argument would have to be proved. Finally a one-word key has at most $q$ possible five-tuples of outputs on five messages, so cannot give the uniform distribution on $q^5$ tuples. There is no five-wise claim for D.

These limitations are explicit: the work proves A/B and the conditional finalizer part of C, supplies the constructors for all requested schedules, and leaves a useful 64-bit C/D collision theorem and unrestricted exponent-triple optimality unproved. It does not label either missing result as a conjecture supported merely by passing tests.
