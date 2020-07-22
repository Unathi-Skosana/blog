---
title: Quantum Fourier Transform
date: 2020-06-19 05:04
draft: true
---

This post is the first iteration of an $N$-part series of blog posts aimed at
attempting to understand some of the ideas behind Shor's factoring algorithm.
One such idea is that of the quantum Fourier transform (QFT), which will be
the subject of inquiry here. I would strongly recommend familiarity with linear algebra and bra-ket notation.
The following lecture notes on [bra-ket](https://ocw.mit.edu/courses/physics/8-05-quantum-physics-ii-fall-2013/lecture-notes/MIT8_05F13_Chap_04.pdf)
notation should be sufficient.

### Tableau

1) [Not So Quantum Fourier Transform](#classical)
   i. [Definitions](#classical_definitions)
   ii. [Examples](#classical_examples)
   iii. [Properties of interest](#classical_properties)
2) [Going Quantum](#quantum)
   i. [Definitions](#quantum_definitions)
   ii. [Circuits & Examples](#quantum_examples)
   iii. [Complexity](#quantum_complexity)
4) [Notes](#notes)
5) [Conclusion](#conclusion)

## Not So Quantum, Fourier Transform {#classical}

The quantum Fourier transform is intimately related (same transform but different notations) to
the ubiquitous **discrete Fourier transform (DFT)**. The DFT converts a sequence of
values, usually from some time-dependent function $f(t)$ sampled at equidistant time intervals,
into another sequence of values, sampled from a frequency-dependent function
$F(\nu)$ at equidistant frequency intervals. The transformation from $f(t)$ to
$F(\nu)$ is the Fourier transform.


### Definitions {#classical_definitions}
The discrete Fourier transform is a transformation $\mathcal{F} : \{x_k\}_{k=0}^{N-1} \to \{y_k\}_{k=0}^{N-1}$,
that maps a tuple of $N$ complex-valued numbers

$$
\underline{\mathbf{x}} = (x_0, x_1, x_2, \ldots, x_{N-1})
$$

to another tuple

$$
\underline{\mathbf{y}} = (y_0, y_1, y_2, \ldots, y_{N-1})
$$

The relation between the two tuples is given by

$$
y_n \equiv  \displaystyle\sum_{k=0}^{N-1} x_k e^{-2\pi ikn/N}
$$

For the seek of notational convenience, we may denote $\omega_N = e^{-2\pi i/N}$
and rewrite the sum as

$$
y_n \equiv  \displaystyle\sum_{k=0}^{N-1} x_k \omega_N^{kn} \\
$$

which lends itself to the following linear expression i.e
$\underline{\mathbf{y}} = \hat{U}\underline{\mathbf{x}}$, with the matrix elements of $U$,
given by $U_{nk} = \omega_N^{kn}$.

$$
\begin{aligned}
  \begin{pmatrix}
    y_0 \\ y_1 \\ y_2 \\ \vdots \\ y_{N-1} 
  \end{pmatrix} &=
  \begin{pmatrix}
    1 & 1 & 1 & \ldots & 1 \\
    1 & \omega_N & \omega_N^2 & \ldots  & \omega_N^{(N-1)} \\
    1 & \omega_N^2 & \omega_N^4 & \ldots & \omega_N^{2(N-1)} \\
    \vdots & \vdots & \vdots & \ddots & \vdots \\
    1 & \omega_N^{(N-1)} & \omega_N^{2(N-1)} & \ldots & \omega_N^{(N-1)^2}
  \end{pmatrix}
  \begin{pmatrix}
      x_0 \\ x_1 \\ x_2 \\ \vdots \\ x_{N-1}
  \end{pmatrix}
\end{aligned}
$$

If the input values $x_k$ are real-valued, the discrete Fourier transform can be
thought of as encoding of a discretized signal in amplitude and phase of a sin wave
with frequencies $\nu_k = \frac{2\pi k}{N}$.

### Examples {#classical_examples}

Example 1

:   Consider $\underline{\mathbf{x}} = (x_0, x_1, x_2, x_3) = (0, 0,
0, 1)$ with $\omega_4 = e^{-2\pi i/4}$ 

$$
\begin{aligned}
  \begin{pmatrix}
    y_0 \\ y_1 \\ y_2 \\ y_3
  \end{pmatrix}
  &=
  \begin{pmatrix}
    1 \\
    \omega_4^{3} \\
    \omega_4^{6} \\
    \omega_4^{9}
  \end{pmatrix}
  &=
  \begin{pmatrix}
     1 \\
     i \\
     -1 \\
     -i
  \end{pmatrix}
\end{aligned}
$$

Example 2

:   Consider $\underline{\mathbf{x}} = (x_0, x_1, x_2, x_3) = (-1, 0,
-1, 0)$ with $\omega_4 = e^{-2\pi i/4}$

$$
\begin{aligned}
  \begin{pmatrix}
    y_0 \\ y_1 \\ y_2 \\ y_3
  \end{pmatrix}
  &=
  \begin{pmatrix}
    -2 \\
    -1 - \omega_4^{2} \\
    -1 - \omega_4^{4} \\
    -1 - \omega_4^{6}
  \end{pmatrix}
  &=
  \begin{pmatrix}
    -2 \\
     0 \\
     -2 \\
     0
  \end{pmatrix}
\end{aligned}
$$

### Properties of interest {#classical_properties}

The discrete Fourier transform has many interesting properties, however we'll only
focus on ones relevant to our inquiry here.

_Linearity_

: We saw earlier that can represent the transformation as a matrix.

$$
\begin{aligned}
  \hat{U}(\alpha \underline{\mathbf{x}}_0 + \beta\underline{\mathbf{x}}_1) &= \hat{U}(a\underline{x}_0) + \hat{U}(b\underline{x}_1) \\
  &= a\hat{U}\underline{\mathbf{x}}_0 + b\hat{U}\underline{\mathbf{x}}_1 \\
  &= a\underline{\mathbf{y}}_0 + b \underline{\mathbf{y}}_1
\end{aligned}
$$

_Periodic_

: The discrete Fourier transform is periodic with period $N$

$$
\begin{aligned}
  y_{n+N} &= \displaystyle\sum_{k=0}^{N-1} x_k e^{-2\pi ik(n+N)/N} \\
  &= \displaystyle\sum_{k=0}^{N-1} x_k e^{-2\pi ik n/N}e^{-2\pi ik} \\
  &=  \displaystyle\sum_{k=0}^{N-1} x_k e^{-2\pi ik n/N} \\
  &= y_n
\end{aligned}
$$

_Revealing frequent/periodic patterns (very hand-wavey)_

: Consider the input tuple below

$$
  \mathbf{x} = (1,2,3,1,2,3,1,2,3,1,2,3)
$$

>The above tuple has a repeating sub-tuple $(1,2,3)$, each element of this
sub-tuple has a period of $3$ or equivalently a frequency of $\frac{1}{3}$. Computing $\underline{\mathbf{y}} = 
(y_0, y_1, \ldots, y_{11})$ and $\mathcal{P}(n)$ given by the square modulus of the $n^\text{th}$ term of
$\mathbf{y}$.

$$
\mathcal{P}(n) = \frac{|y_n|^2}{\sqrt{\sum_{k=1}^{11} |y_k|^2}} \quad 1 \leq n \leq 11
$$

>The coefficient $P(n)$ is associated with power of the frequency $\nu_{n} =
\frac{2\pi n}{12}$, note the term associated with the frequency $\nu_{0}$ (average of
all samples) is omitted here. Since the frequency $\frac{1}{3}$ is
prevalent here, we should expect to see pronounced peaks in $\mathcal{P}$ where

$$
\frac{n-1}{12} = \frac{m}{3}
$$

>for some integer $1 \leq m \leq 11$.

![Plot of $\mathcal{P}$](/static/images/plot.svg#center "Plot")


>This is indeed the case, the plot above shows the expected peaks at
$n=5$ and $n=9$

$$
\frac{4}{12} = \frac{1}{3}, \frac{8}{12} = \frac{2}{3}
$$

$\mathcal{P}$ is called a **periodogram**.

_Invertible_

: Multiplying both sides of the original definition by $\displaystyle\sum_{n=0}^{N-1} e^{2\pi i j n / N}$ for some integer
$j$ yields

$$
\begin{aligned}
\displaystyle\sum_{n=0}^{N-1}y_{n} e^{2\pi i j n / N} &= \displaystyle\sum_{n=0}^{N - 1}\displaystyle\sum_{k=0}^{N-1} x_k e^{-2\pi ikn/N}e^{2\pi i j n  / N}  \\
&=  \displaystyle\sum_{n=0}^{N - 1}\displaystyle\sum_{k=0}^{N-1} x_k e^{-2\pi in(k-j)/N} \\
&=  \displaystyle\sum_{k=0}^{N - 1}x_k\displaystyle\sum_{n=0}^{N-1} e^{-2\pi in(k-j)/N}  \\
\end{aligned}
$$

> Isolating the inner sum, we can consider the two possible scenario, $k = j$ and $k \neq
j$. The first case is trivial

$$
\begin{aligned}
\displaystyle\sum_{n=0}^{N-1} e^{-2\pi i n(k - k)/N} = \displaystyle\sum_{n=0}^{N-1} 1 = N
\end{aligned}
$$

> The second case, not so

$$
\begin{aligned}
\displaystyle\sum_{n=0}^{N-1} \left(e^{-2\pi i (k - j)/N}\right)^n =  \displaystyle\sum_{n=0}^{N-1} r^n
\end{aligned}
$$

> where $r = e^{-2\pi i (k - j)/N}$. The summation above is a geometric progression, which has an explicit formula

$$
\begin{aligned}
\displaystyle\sum_{n=0}^{N-1} r^n &= \frac{1 - r^N}{1 - r} , \quad |r| \lt 1 \\
&= \frac{1 - e^{-2\pi i (k - j)}}{1 - e^{-2\pi i (k - j)/N}} \\
&= \frac{1 - 1}{1 - e^{-2\pi i (k - j)/N}} \\
= 0
\end{aligned}
$$

> since $e^{-2\pi i m} = 0$ for any integer $m$. Thus 

$$
\begin{aligned}
  \displaystyle\sum_{n=0}^{N-1} e^{-2\pi i n(k - j)/N}
  &= \begin{cases}
  N  & k = j \\
  0  & k \neq j \\
  \end{cases}
  \\
  &= N\delta_{kj}
\end{aligned}
$$

> where $\delta_{kj}$ is the delta Kronecker function. We can now show that

$$
\begin{aligned}
\displaystyle\sum_{n=0}^{N-1}y_{n} e^{2\pi i j n / N}  &= \displaystyle\sum_{k=0}^{N - 1} x_k N\delta_{kj} \\
&= N x_j \\
x_j &= \frac{1}{N} \displaystyle\sum_{n=0}^{N-1}y_{n} e^{2\pi i j n / N} 
\end{aligned}
$$

> The above linear map is called the **discrete inverse Fourier transform**.

_Unitary_

: See [Parseval's theorem](https://en.wikipedia.org/wiki/Parseval's_theorem). The theorem's results is that $\frac{1}{N} U^{*}U = I$, which implies unitarity,
i.e $\frac{1}{\sqrt{N}} U^{*} = \frac{1}{\sqrt{N}}U^{-1}$.

### Computational complexity {#classical_complexity}

For a specific transformed coefficient $y_n$, computing the sum requires
at least $2$ multiplications for each term in the sum (one for real part and one for the imaginary part)
and adding $2N$ terms requires $2N-1$ additions. Thus computing each $y_n$ term requires at least

$$
\begin{aligned}
 2N + 2N - 1 &= 4N -1 \quad \text{arithmetic operations}
\end{aligned}
$$

computing $N$ such terms would require

$$
\begin{aligned}
 N(4N -1) &= 4N^2 - N \quad \text{arithmetic operations} \\
 & \sim \mathcal{O}(N^2) \quad \text{arithmetic operations}
\end{aligned}
$$

>> The **fast Fourier transform** can reduce this scaling to
  $\mathcal{O}(N\log N)$, which still scales exponentially with
  the number of classical bit operations $N=2^n$ (assuming $N$ is even), $\mathcal{O}(n2^n)$

## Going Quantum {#quantum}

Improvement in complexity is plateaued, even with the best classical algorithm for computing the Fourier transform.
In what follows, we'll see how a quantum computer can compute the discrete Fourier transform with polynomial
scaling $\mathcal{O}(n^2)$ in the number of resources (quantum gates) on a quantum state described by $n$ quantum
bits (qubits).

### Definitions {#quantum_definitions}

Any $n$-qubit state $|\psi\rangle$ can be expressed as a linear combination of orthonormal
basis states for
$\mathbb{C}^{2^n}$, given by the maximal set $\{|x\rangle\}_{x \in \{0,1\}^n}$ where the elements are $2^n$-dimensional one-hot vectors of the form

$$
|x\rangle = \begin{pmatrix}0 \\ \vdots \\1 \\ \vdots \\ 0\end{pmatrix} \to
1 \text{ at some } i^\text{th} \text{ position and the rest of the entries are }
0
$$

Thus

$$
|\psi\rangle = \displaystyle\sum_{x \in \{0,1\}^n} \alpha_x |x\rangle \\
\alpha_x \in \mathbb{C} \text{  and  } \displaystyle\sum_{x \in \{0,1\}^n} |\alpha_x|^2 = 1
$$

where $|x\rangle  = |x_{1}x_{2}\cdots x_{n-1} x_{n}\rangle =
|x_{1}\rangle\otimes|x_{2}\rangle\cdots |x_{n-1}\rangle\otimes|x_{n}\rangle$

Alternatively, since the elements of the maximal set $\{x\}_{x \in \{0,1\}^n}$ are the
numbers from $0$ in $2^n -1$ expressed in binary notation, one can write

$$
|\psi\rangle = \displaystyle\sum_{x = 0}^{2^n - 1} \alpha_x |x\rangle \quad, ...
$$

The **quantum Fourier transform** 
^[The (not inverted) quantum Fourier transform is equivalent to the inverse
discrete Fourier transform] is defined as a linear and unitary (norm
preserving) map that acts on the basis states as follows

$$
\hat{U}_\text{QFT}|x\rangle =  \frac{1}{\sqrt{N}} \displaystyle\sum_{y=0}^{N
-1}e^{2\pi i x y / N } |y\rangle
$$

Like before

$$
\hat{U}_\text{QFT} = \frac{1}{\sqrt{N}} \begin{pmatrix}
    1 & 1 & 1 & \ldots & 1 \\
    1 & \omega_N & \omega_N^2 & \ldots  & \omega_N^{(N-1)} \\
    1 & \omega_N^2 & \omega_N^4 & \ldots & \omega_N^{2(N-1)} \\
    \vdots & \vdots & \vdots & \ddots & \vdots \\
    1 & \omega_N^{(N-1)} & \omega_N^{2(N-1)} & \ldots & \omega_N^{(N-1)^2}
  \end{pmatrix}
$$

Here $N = 2^n$ where $n$ is number of qubits.

#### Tensor product states

The QFT lends itself to a tensor product representation
that allows one to somewhat visual it geometrically. Recall that

$$
\begin{aligned}
\hat{U}_\text{QFT}|x\rangle &=  \frac{1}{\sqrt{2^n}} \displaystyle\sum_{y=0}^{2^n-1}e^{2\pi i x y /N } |y\rangle \\
&= \frac{1}{\sqrt{2^n}}\displaystyle\sum_{y \in \{0,1\}^n} e^{2\pi i x y /2^n } |y_{1}y_{2}\cdots
y_{n-1}y_{n}\rangle
\end{aligned}
$$

Since $y \leq 2^n -1 \implies y / 2^n \lt 1$. If we express $y$ in binary
as $y = y_0 y_{1} \cdots y_{n-2} y_{n-1}$

$$
\begin{aligned}
y = y_1 2^{n-1} + y_2 2^{n-2} + \cdots + y_{n}2^0 = \displaystyle\sum_{l=1}^{n}
y_l 2^{n-l}
\end{aligned}
$$

Thus 

$$
\begin{aligned}
y / 2^n = \displaystyle\sum_{l = 1}^{n} y_{l}2^{n-l}/2^n =
\displaystyle\sum_{l=1}^{n} y_l2^{n - n - l} = \displaystyle\sum_{l=1}^n y_l
2^{-l}
\end{aligned}
$$

Rewriting the expression

$$
\begin{aligned}
\hat{U}_\text{QFT}|x\rangle &= \frac{1}{\sqrt{2^n}}\displaystyle\sum_{y \in \{0,1\}^n} e^{2\pi i x y /N } |y_{1}y_{2}\cdots
y_{n-1}y_{n}\rangle \\
&= \frac{1}{\sqrt{2^n}}\displaystyle\sum_{y \in \{0,1\}^n} e^{2\pi i x (\sum_{l=1}^n y_l
2^{-l}) } |y_{1}y_{2}\cdots
y_{n-1}y_{n}\rangle \\
&= \frac{1}{\sqrt{2^n}}\displaystyle\sum_{y_1 = 0}^{1}\displaystyle\sum_{y_2 = 0}^{1}\cdots\displaystyle\sum_{y_{n} = 0}^{1} 
e^{2\pi i x (\sum_{l=1}^n y_l 2^{-l}) } |y_{1}y_{2}\cdots y_{n-1}y_{n}\rangle 
\end{aligned}
$$

The last step is due to expressing $y$ in binary form. For any $j$, $y_j = 0 \text{ or } 1$

$$
\begin{aligned}
&= \frac{1}{\sqrt{2^n}}\displaystyle\sum_{y_1 = 0}^{1}\displaystyle\sum_{y_2 = 0}^{1}\cdots\displaystyle\sum_{y_{n} = 0}^{1} 
\displaystyle\prod_{l=1}^{n}e^{2\pi i x (y_l 2^{-l}) } |y_{1}y_{2}\cdots y_{n-1}y_{n}\rangle  \\
&= \frac{1}{\sqrt{2^n}}\displaystyle\prod_{l=1}^{n}\displaystyle\sum_{y_l
=0}^{1}e^{2\pi i x (y_l2^{-l})}|y_l\rangle \\
&= \frac{1}{\sqrt{2^n}}\displaystyle\prod_{l=1}^{n}(e^{2\pi i x (0\cdot 2^{-l})}|0\rangle + 
e^{2\pi i x (1\cdot 2^{-l})}|1\rangle ) \\
&= \frac{1}{\sqrt{2^n}}\displaystyle\prod_{l=1}^{n}(|0\rangle + e^{2\pi i x / 2^l}|1\rangle) \\
&= \frac{1}{\sqrt{2^n}} (|0\rangle + e^{2\pi i x / 2^1}|1\rangle) \otimes (|0\rangle +
e^{2 \pi i x /2^2}|1\rangle)\cdots(|0\rangle + e^{2\pi i x /2^n}|1\rangle)
\end{aligned}
$$

The representation above reveals that each of the individual qubits after
applying $\hat{U}_\text{QFT}$, acquire a phase that scales down with progressive
powers of two from the leftmost to the rightmost qubit.

#### Sun dial basis states

Due to the normalization constraint, a single qubit state be represented
geometrically as a unit vector on the surface of a unit sphere in $3$-space. For
real numbers $\theta$ and $\varphi$, any single qubit state can be expressed as

$$
|\psi\rangle = \cos{\left(\frac{\theta}{2}\right)}|0\rangle + e^{i\varphi}\sin{\left(\frac{\theta}{2}\right)}|1\rangle, \quad 0 \leq \theta \leq \pi, 0 \leq \varphi \lt 2\pi
$$

>>*Ex: Check that the state above is normalized.*

$\theta$ and $\varphi$ parametrize a point on a unit sphere in
$\mathbb{R}^3$

$$
\vec{r} = (\sin{\theta}\cos{\varphi}, \sin{\theta}\sin{\varphi},\cos{\theta})
$$

This $\mathbb{R}^3$ sphere is called a **Bloch sphere** and the vector above is
called a **Bloch vector**.

![**Single qubit state depicted on a Bloch sphere**](/static/images/blochsphere.svg#center "Bloch sphere")

We shall confine ourselves to states that
lie on the line of latitude on the Bloch sphere, $\theta = \frac{\pi}{2}$.

$$
\begin{aligned}
|\phi\rangle &= \cos{\left(\frac{\pi}{4}\right)}|0\rangle + e^{i\varphi}\sin{\left(\frac{\pi}{4}\right)}|1\rangle \\
&= \frac{1}{\sqrt{2}}\left(|0\rangle + e^{i\varphi}|1\rangle\right)
\end{aligned}
$$

The state above is depicted below

![**Single qubit state on the line of latitude of a Bloch sphere**](/static/images/sundial.svg#center "Sun dials")

Now let's consider the action of $\hat{U}_\text{QFT}$ on the basis states of a three-qubit system;
being lazy I will omit the normalization factor.

$$
\begin{aligned}
\hat{U}_\text{QFT}|000\rangle &= \hat{U}_\text{QFT}|0\rangle = (|0\rangle
+ e^{2\pi i 0 /2 ^1}|1\rangle)\otimes(|0\rangle + e^{2\pi i 0  /
    2^2}|1\rangle)\otimes(|0\rangle + e^{2\pi i 0 / 2^3}|1\rangle) \\
\hat{U}_\text{QFT}|100\rangle &= \hat{U}_\text{QFT}|1\rangle = (|0\rangle
+ e^{2\pi i 1 /2 ^1}|1\rangle)\otimes(|0\rangle + e^{2\pi i 1 /
    2^2}|1\rangle)\otimes(|0\rangle + e^{2\pi i 1 / 2^3}|1\rangle) \\
 & \phantom{\;=}\vdots \\
\hat{U}_\text{QFT}|011\rangle &= \hat{U}_\text{QFT}|6\rangle = (|0\rangle
+ e^{2\pi i 6 /2 ^1}|1\rangle)\otimes(|0\rangle + e^{2\pi i 6 /
    2^2}|1\rangle)\otimes(|0\rangle + e^{2\pi i 6 / 2^3}|1\rangle) \\
\hat{U}_\text{QFT}|111\rangle &= \hat{U}_\text{QFT}|7\rangle = (|0\rangle
+ e^{2\pi i 7 /2 ^1}|1\rangle)\otimes(|0\rangle + e^{2\pi i 7 /
    2^2}|1\rangle)\otimes(|0\rangle + e^{2\pi i 7 / 2^3}|1\rangle)
\end{aligned}
$$

Visually

![](/static/images/3q-qft-0.svg#center){height=80px}
![](/static/images/3q-qft-1.svg#center){height=80px}
$$
\vdots
$$
![](/static/images/3q-qft-6.svg#center){height=80px}
![](/static/images/3q-qft-7.svg#center){height=80px}

We see here that the action of $\hat{U}_\text{QFT}$ is to encode the basis states, e.g $|6\rangle$,
by rotating the leftmost qubit along the line of
latitude through $\frac{6}{2^3}$ revolutions, the middle qubit
double that of the leftmost qubit, $\frac{6}{2^2}$ revolutions and the pattern
continues. Turns out the states above also form an orthonormal basis,
the sundial basis (or more appropriate Fourier basis) states, since
$\hat{U}_\text{QFT}$ is a norm preserving operation.

### Circuits & Examples {#quantum_examples}

We'll briefly look at a few _quantum logic gates_ (linear & unitary maps) relevant to
the QFT and _quantum circuits_ that realize $\hat{U}_\text{QFT}$.

#### Prequel : Notational convenience

Before proceeding, it is important we adopt fractional binary notation for expressing the angle $\varphi$. For some integer $l$

$$
\frac{x}{2^l} = d + r
$$

where $0 \leq d \leq \left\lfloor\frac{x}{2^l}\right\rfloor$ is an integer
and $0 \leq r \lt 1$ is a rational.

$$
\begin{aligned}
e^{2\pi i x / 2^l} &= e^{2\pi i (d + r)} \\
&= e^{2\pi i d} e^{2\pi i r} \\
&= e^{2\pi i r}
\end{aligned}
$$

Thus we only need to concern ourselves with the fractional part of $\frac{x}{2^l}$
when evaluating $e^{2 \pi i x / 2^l}$, for which we'll denote as
$\text{frac}(x/2^l)$. Recall that we can write $x/2^l$ in binary as

$$
\begin{aligned}
x / 2^l = \displaystyle\sum_{i = 1}^{n} x_{i}2^{n-i}/2^l =
\displaystyle\sum_{i=1}^{n} x_i 2^{n - (i + l)} 
\end{aligned}
$$

Fractional terms occur whenever $(i + l) > n \implies i > n - l\implies i \geq j = n - l + 1$

$$
\begin{aligned}
\text{frac}(x / 2^l) = \displaystyle\sum_{i=j}^{n} x_i 2^{j-i+1} 
\end{aligned}
$$

The above expression is often written as $0.x_jx_{j+1} \cdots x_n$. We can rewrite the tensor product expression we saw earlier as 

$$
\hat{U}_\text{QFT}|x_1x_2\cdots x_{n-1}x_{n}\rangle = \frac{1}{\sqrt{2^n}} (|0\rangle + e^{2\pi i 0. x_{n}} |1\rangle) \otimes (|0\rangle +
e^{2 \pi i 0. x_{n-1} x_{n}} |1\rangle)\cdots(|0\rangle + e^{2\pi i 0. x_1 x_2 \cdots x_{n}} |1\rangle)
$$

### Gates & Circuits

A quantum logic gate is represented by a norm preserving linear map $U$. The
action of a quantum logic gate $U$ on an input state $|\psi\rangle$ is diagrammatically
represented as:

![](/static/images/U.png#center){height=120px}


#### Examples of quantum logic gates

*Hadamard*

![](/static/images/H.png#center){height=120px}

: The Hadamard gate $H$ acts on the basis states like

$$
H |0\rangle \to |+\rangle = \frac{1}{\sqrt{2}}(|0\rangle + e^{i 0}|1\rangle) \\
H|1\rangle \to |-\rangle = \frac{1}{\sqrt{2}}(|0\rangle + e^{i \pi}|1\rangle)
$$

Visually this gate as the effect of moving a state at one of the poles of the
Bloch sphere to line of latitude.

*NOT*

![](/static/images/X.png#center){height=120px}

: The NOT gate $X$ flips the basis states

$$
X|0\rangle \to |1\rangle \\
X|1\rangle \to |0\rangle
$$

*Phase shift*

![](/static/images/phase.png#center){height=120px}

: The Phase shift gate $R_{\varphi}$ modifies the phase of the basis states 

$$
\begin{aligned}
R_{\varphi}|0\rangle &\to |0\rangle \\
R_{\varphi}|1\rangle &\to e^{i\varphi}|1\rangle
\end{aligned}
$$


*Controlled-U*

![](/static/images/Cu.png#center){height=120px}

:  A controlled-$U$ for an arbitrary $U$, is a two-qubit gate, which has the action of
applying $U$ to the target qubit $|t\rangle$ if the control qubit $|c\rangle$ is in the state
$|1\rangle$.

$$
C(U)|c\rangle|t\rangle \to |c\rangle U^c |t\rangle
$$

A controlled-$U$ can written as a block diagonal matrix, where first block is the
$2\times2$ identity matrix and the second block is $U$.

![](/static/images/CCU.png#center)

Special case when $U = R_{\varphi}$ implements a controlled phase shift gate.

#### Circuits for $U_\text{QFT}$

Define unitary map $R_k \equiv R_{2 \pi / 2^k}$ as a special case for the phase shift gate.
We'll also denote a single-qubit  gate acting on the qubit $i$ as $U^{(i)}$ and a two-qubit gate controlled by qubit
$j$ and targeted to qubit $k$ as $C(U)^{(jk)}$ whenever there's a possibility of
ambiguity.

$n = 1$
: This case above is trivial is equivalent to the $H$, since $H|x_1\rangle =
\frac{1}{\sqrt{2}} (|0\rangle + e^{2\pi 0.x_1}|1\rangle)$, for which $e^{2\pi
0.x_1}$ is either $-1$ or $+1$ for $x_1 = 1$ or $x_1 = 0$ respectively.

![](/static/images/qft1_c.png#center){height=80px}

$n= 2$
: The case is similar to the first, amended only slightly. Consider the operations
on a single qubit below

$$
\begin{aligned}
R_{2} H |x_1\rangle &= R_2 \left[\frac{1}{\sqrt{2}} (|0\rangle + e^{2\pi 0.x_1 0 }|1\rangle)\right] \\
&= \frac{1}{\sqrt{2}} (|0\rangle + e^{2\pi 0.x_1 1}|1\rangle)
\end{aligned}
$$

The action of $R_2$ on $H|x_1\rangle$ is modifies the phase $2\pi 0.x_1 0$ to
$2\pi0.x_1 1$. Thus by controlling $R_2$ with qubit $|x_2\rangle$ we can encode $2\pi0.x_1x_2$ in the
phase, since whenever $x_2 = 0$, $R_2$ isn't applied on $|x_1\rangle$ leaving the phase $2\pi 0.x_1 0$ unmodified and
whenever $x_2 = 1$ we encode $2\pi 0.x_1 1$. Finally by apply a Hadamard gate on the second qubit, we can realize the $U_\text{QFT}$ for
two qubits.^[Note that this is in reverse order, can be easily remedied by
swap gates between the relevant qubits. The swap can also happen on the
classical outcomes i.e $110 \to 011$]


$$
\begin{aligned}
H^{(2)}C(R_{2})^{(21)}H^{(1)}|x_1x_2\rangle &= \frac{1}{\sqrt{2}} (|0\rangle + e^{2\pi 0.x_1 x_2 }|1\rangle)\otimes(|0\rangle + e^{2\pi 0.x_2 }|1\rangle)
\end{aligned}
$$

![](/static/images/qft2_c.png#center){height=150px}

$n = 3$
: I challenge the keen innanet dweller to convince themselves that the circuit
below realizes $U_\text{QFT}$ for three qubits.

![](/static/images/qft3_c.png#center)

General
: The pattern carries on to the general case, each
qubit will have a Hadamard gate followed by a sequence of controlled phase shift gates,
controlled by each of the qubits below the line -- i.e
The line immediately below controls $R_2$, the next one $R_3$ and so on.

![](/static/images/qftn_c.png#center)

### Complexity {#quantum_complexity}

On the $i^{th}$ qubit, there's a Hadamard followed by $n - i$ controlled phase
shift gates, controlled by the qubits that proceed it and there are $n$ qubits
in total.

$$
\begin{aligned}
\displaystyle\sum_{i=1}^{n} n + 1 - i &= \displaystyle\sum_{j=0}^{n-1} n - j \\
&= n(n+1)/2 \\
&= n^2/2 + n/2
\end{aligned}
$$

The total number of gates thus scales polynomially $\mathcal{O}(n^2)$, a great improvement over the
exponential scaling $\mathcal{O}(n 2^n)$ of the classical analog.

### Conclusion

The reduction in complexity of some problems, here the DFT, is one of the reasons
why quantum computers hold promise (well, kinda of).^[Albeit the reduced complexity,
the QFT is not very useful (not useful at all) as a direct substitute for the classical analog,
as quantum mechanics forbids access to the amplitude coefficients] In the
iterations that follow, we will concern ourselves with quantum phase estimation and order-finding.

### Notes

- There is a fun interactive tools for visualizing the [Bloch sphere](https://javafxpert.github.io/grok-bloch/) by [James Weaver](https://github.com/JavaFXpert). Check it out.
- If the inputs to $\hat{U}_\text{QFT}$ are just basis states (no superposition of states), one can classically
    precompute all the relevant combinations of the phase shift angles and
    avoid controlling the phase shift gates.
- The innanet dweller who seeks a more well thought out delve into the
    subject, I cannot recommend [Mike & Ike](https://www.amazon.com/Quantum-Computation-Information-10th-Anniversary/dp/1107002176)
    enough.


### Bibliography

Roberts, S. _Lecture 7-The Discrete Fourier Transform_. pp. 82-96. [https://www.robots.ox.ac.uk/~sjrob/Teaching/SP/l7.pdf](https://www.robots.ox.ac.uk/~sjrob/Teaching/SP/l7.pdf).

Weisstein, E, "Discrete Fourier Transform." From MathWorld--A Wolfram Web
Resource. [https://mathworld.wolfram.com/DiscreteFourierTransform.html](https://mathworld.wolfram.com/DiscreteFourierTransform.html)

Wikipedia 2020, _Periodogram_, Wikipedia, viewed 22 Jul. 2020, [<https://en.wikipedia.org/wiki/Periodogram>](https://en.wikipedia.org/wiki/Periodogram)

Nielsen, M & Chuang, I 2000, _Quantum Computation and Quantum Information_, Cambridge University Press, Cambridge.

Weinstein, Y, Pravia, M, Fortunato, E, Lloyd, S, Cory,
D 2001, "Implementation of the Quantum Fourier Transform", _Phys. Rev.
Lett._, vol. 86, n. 9, pp. 1889-1891
