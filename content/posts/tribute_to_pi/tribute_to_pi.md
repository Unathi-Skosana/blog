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

```python
import numpy as np
import csv

from decimal import Decimal, getcontext
from math import factorial


def pi_digits(n):
    """
    Computes PI using the Chudnovsky algorithm from
    http://stackoverflow.com/questions/28284996/python-pi-calculation
    """

    # Set precision

    getcontext().prec = n

    t = Decimal(0)
    pi = Decimal(0)
    d = Decimal(0)

    # Chudnovsky algorithm

    for k in range(n):
        t = ((-1)**k)*(factorial(6*k))*(13591409+545140134*k)
        d = factorial(3*k)*(factorial(k)**3)*(640320**(3*k))

        pi += Decimal(t) / Decimal(d)

    pi = pi * Decimal(12) / Decimal(640320**(Decimal(1.5)))
    pi = 1 / pi

    return str(pi)


if __name__ == '__main__':
    import argparse

    # Parse arguments
    parser = argparse.ArgumentParser(
        description="Compute Pi digits that fit in an r x c grid.")
    parser.add_argument("r", nargs=1, type=int, help="Rows of grid")
    parser.add_argument("c", nargs=1, type=int, help="Columns of grid")
    args = parser.parse_args()

    rows = args.r[0]
    cols = args.c[0]

    # Put digits in 2D array
    digits = pi_digits(rows * cols)
    digits = digits.replace(".", "")
    digits = [[digits[r*cols + c] for c in range(cols)] for r in range(rows)]

    # digits to .dat file to reuse
    with open('pi_{}_by_{}.dat'.format(rows, cols), 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerows(digits)
```

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

```python
import numpy as np
import csv
import matplotlib.pyplot as plt

from matplotlib import rc

# Aesthetics
rc('font', **{'family': 'monospace',
              'serif': ['DejaVu Sans Mono'], 'size': '20'})
rc('text', usetex=True)
plt.style.use('dark_background')


def read_digits(dat):
    digits = []
    with open(dat) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        for row in csv_reader:
            digits.append(row)
    return np.array(digits, dtype="int")


# By Jake VanderPlas
# License: BSD-style
# https://gist.github.com/jakevdp/91077b0cae40f8f8244a
def discrete_cmap(N, base_cmap=None):
    """Create an N-bin discrete colormap from the specified input map"""

    # Note that if base_cmap is a string or None, you can simply do
    #    return plt.cm.get_cmap(base_cmap, N)
    # The following works for string, None, or a colormap instance:

    base = plt.cm.get_cmap(base_cmap)
    color_list = base(np.linspace(0, 1, N))
    cmap_name = base.name + str(N)
    return base.from_list(cmap_name, color_list, N)


if __name__ == '__main__':
    import argparse

    # Parse arguments
    parser = argparse.ArgumentParser(
        description="Read digits from data file.")
    parser.add_argument("dat", nargs=1, type=str, help="name of file")
    args = parser.parse_args()

    dat = args.dat[0]
    digits = read_digits(dat)
    r, c = np.shape(digits)
    x, y = np.meshgrid(np.arange(r), np.arange(c))

    fig, axes = plt.subplots(figsize=(r, c))

    scat = axes.scatter(x, y, c=digits[x, y], s=50,
                        cmap=discrete_cmap(10, 'rainbow'))
    axes.axis('off')

    # produce a legend with the unique colors from the scatter
    legend1 = axes.legend(*scat.legend_elements(),
                          loc="lower center", ncol=10, frameon=True,
                          bbox_to_anchor=(0.5, -0.1))
    axes.add_artist(legend1)
    plt.tight_layout()
    fig.savefig('pi_{}_by_{}.svg'.format(r, c), format='svg', dpi=1200,
                pad_inches=0)
```

The visualizations below were for $23\times23$ and $31\times31$
grids (yes, I like primes) respectively.

![](./pi_23_by_23.png#center "pi 23x23")
![](./pi_31_by_31.png#center "pi 31x31")

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
for $23\times23$ and $31\times31$ grids.


![](./pi_23_by_23_edges.png#center "pi 23x23")
![](./pi_31_by_31_edges.png#center "pi 31x31")

The updated source code and higher quality images can be found
[here](https://github.com/Unathi-Skosana/numart). If you have comments or
quarrels, [reach out](/).

## Updates : 23 by 23 meshgrids for Euler's number and the golden ratio

![](./e_23_by_23_edges.png#center "e 23x23")
![](./phi_23_by_23_edges.png#center "phi 23x23")

## Sources:
- [1] : https://stackoverflow.com/questions/46737409/finding-connected-components-in-a-pixel-array
- [2] : https://stackoverflow.com/questions/28274091/removing-completely-isolated-cells-from-python-array
- [3] : https://stackoverflow.com/questions/28284996/python-pi-calculation
- [4] : http://mkweb.bcgsc.ca/pi/piday/
- [5] : https://en.wikipedia.org/wiki/Component_(graph_theory)
- [6] : https://en.wikipedia.org/wiki/Chudnovsky_algorithm
- [7] : https://gist.github.com/jakevdp/91077b0cae40f8f8244a
