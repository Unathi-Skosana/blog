---
title: "Tribute to &pi;"
date: 2020-03-14 16:33
---

Happy 3.14 Day, which also happens to be the day Albert Einstein was born ! So
March 14 is irrationally (bad pun, I know) anticipated with much excitement by
the science and mathematics communities alike. I will follow tradition, as I did
last year and honor $\pi$-day by recreating a visual representation of the
digits of $\pi$.
The recreation will be a derivative of a 2013 $\pi$-day poster by [Martin Krzywinski](https://twitter.com/MKrzywinski) found at  [http://mkweb.bcgsc.ca/pi/piday](http://mkweb.bcgsc.ca/pi/piday)

The digits of $\pi$ were computed using the [Chudnovsky
algorithm](https://en.wikipedia.org/wiki/Chudnovsky_algorithm). Due to the
CPU-intensive nature  of such a computation, I precomputed the digits and saved
to them a .dat file for reuse. This is less time consuming than computing the
digits every time when visualizing them (or if you write buggy programs like I do).
Below is the python script that computes the $n$ first digits of $\pi$ and saves as them to .dat file:

{{< gist Unathi-Skosana f612e6d6b2511cd30c0df2be8497af14 >}}

Since the digits will be displayed on a grid, the python script takes as input
the dimensions of the grid, the number of rows and number of columns
respectively.


Now that we have computed the $n = rc$ digits of $\pi$, we want to
visualize them. The visualization was done using
`scatter` from `matplotlib` where the digits are laid out on a $r \times c$
evenly-spaced meshgrid and the values of the digits are used to fill the colors of
the points on the grid, these colors are taken from a discrete color map of size $10$.
The python script used to read the digits from a file and visualize them as
explained above
is as follows:

{{< gist Unathi-Skosana  a97583a8eaec4247191c4fda2ed41e77>}}

The visualizations below were for $23\times23$, $31\times31$, $47\times47$,$59\times59$
and $71\times71$ grids (yes, I like primes) respectively.

{{< imgproc "pi_23_by_23.png" Fit 800x800/>}}
{{< imgproc "pi_31_by_31.png" Fit 800x800/>}}
{{< imgproc "pi_47_by_47.png" Fit 800x800/>}}
{{< imgproc "pi_59_by_59.png" Fit 800x800/>}}
{{< imgproc "pi_71_by_71.png" Fit 800x800/>}}


What would be even more visually appealing is if we could connect the same-valued
digits that are one point away from each other in either direction with edges as in
the original poster. For example, for a 3 by 3 grid

$$
\begin{aligned}
    3,1,4 \\
    1,5,9 \\
    2,6,6
\end{aligned}
$$

In this case the $1$s across the diagonal from the first row and second row will
be connected with an edge. Similarly the $6$s along the third row
will be connected with an edge.

To do this, we need to able to find the indices of the
connected clusters of numbers across the whole grid and use them to draw the
edges between the corresponding grid points. Scouring around the internet, I found that such a
computation is related to a concept in graph theory, which is the concept of
[connected components](https://en.wikipedia.org/wiki/Component_(graph_theory))
of an undirected graph. Finding the connected components of all the digits from
$0-9$ across the grid will give us what we seek. At first sight, this seemed like
a daunting task and I was apprehensive of whether a vanilla python
implementation would be up to the task.
However, it turns out this task is related to labeling components in a
pixel array. Consider the following $3\times3$ pixel array.

$$
\begin{aligned}
    0,1,0 \\
    1,0,1 \\
    0,1,0
\end{aligned}
$$

The four $1$s in the grid would deemed as a label/component and we would have
only one component in the grid. The `SciPy` has a high performance C implementation,
`scipy.ndimage.label`, to label the components and subsequently extract their
indices. The single downfall of this method is that it also considers isolated
groups ($1$ surrounded by $0$s in all directions) as connected components.
However, one can filter out isolated groups from the
original array as done
[here](https://stackoverflow.com/questions/28274091/removing-completely-isolated-cells-from-python-array). Putting this all together, we can produce the stunning visuals below. Here are the visualizations
for $23\times23$,$31\times31$, $47\times47$,$59\times59$ and $71\times71$ grids.

{{< imgproc "pi_23_by_23_edges.png" Fit 800x800/>}}
{{< imgproc "pi_31_by_31_edges.png" Fit 800x800/>}}
{{< imgproc "pi_47_by_47_edges.png" Fit 800x800/>}}
{{< imgproc "pi_59_by_59_edges.png" Fit 800x800/>}}
{{< imgproc "pi_71_by_71_edges.png" Fit 800x800/>}}

The updated source code and higher quality images can be found
[here](https://github.com/Unathi-Skosana/numart). If you have comments or
quarrels, [reach out](/).

## Updates : 47 by 47 meshgrids for Euler's number and the golden ratio

{{< imgproc "e_47_by_47_edges.png" Fit 800x800/>}}
{{< imgproc "phi_47_by_47_edges.png" Fit 800x800/>}}


## Sources:
- [1] : https://stackoverflow.com/questions/46737409/finding-connected-components-in-a-pixel-array
- [2] : https://stackoverflow.com/questions/28274091/removing-completely-isolated-cells-from-python-array
- [3] : https://stackoverflow.com/questions/28284996/python-pi-calculation
- [4] : http://mkweb.bcgsc.ca/pi/piday/
- [5] : https://en.wikipedia.org/wiki/Component_(graph_theory)
- [6] : https://en.wikipedia.org/wiki/Chudnovsky_algorithm
- [7] : https://gist.github.com/jakevdp/91077b0cae40f8f8244a
