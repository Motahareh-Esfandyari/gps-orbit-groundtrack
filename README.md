# GeoInterp

Numerical interpolation and approximation methods in geodesy, implemented in
MATLAB. The collection goes from basic 1D polynomial interpolation up to
kriging, and includes two applications: interpolating GPS satellite orbits
from precise ephemeris files and computing the dilatation of a geodetic
network from its displacement field.

## Contents

```
1-polynomial/
    newton.m               Newton divided differences
    lagrange.m             Lagrange basis polynomials
    chebyshev.m            Chebyshev approximation
    LagrangeDerivative.m   evaluation of a tabulated function via Lagrange coefficients
    CubicSpline.m          natural cubic spline (function)

2-scattered-data/
    IDW.m                  inverse distance weighting, with a support domain study
    RBF.m                  radial basis functions (Gaussian, MQ, IMQ) with derivatives
    RMLS.m                 recursive moving least squares, quadratic basis

3-geostatistics/
    KrigingDemo.m          ordinary kriging demo on a correlated random field
    kriging.m              ordinary kriging (third party, W. Schwanghart)
    variogram.m            experimental variogram (third party, W. Schwanghart)

4-applications/
    OrbitInterpolation.m   GPS orbit interpolation from SP3, cubic spline
    OrbitInterpLagrange.m  same but with Lagrange interpolation (unfinished)
    Lagrange0.m            Lagrange routine for the above (unfinished)
    sp3Cread.m             SP3-a ephemeris reader (original by LaQ, TU Delft)
    igs13730.sp3           sample IGS ephemeris file
    DILITATION.m           dilatation of a displacement field via RBF

5-special-functions/
    clpn.m                 Legendre polynomials Pn(z) for complex z (Jin and Zhang)
    Pnm.m                  driver for clpn.m
```

## A few highlights

OrbitInterpolation.m reads a precise IGS ephemeris with 15 minute sampling,
rotates the ECEF positions to an inertial frame and interpolates the
satellite position at any epoch with cubic splines.

DILITATION.m interpolates the displacement field of a scattered station
network with RBFs, using their analytical derivatives, and compares the
numerical dilatation with the analytical one.

IDW.m and RMLS.m look at how the interpolation error and the coefficient
convergence behave as the support domain (number of nearest neighbours)
grows.

## Requirements

MATLAB with the Symbolic Math Toolbox (for newton, lagrange and chebyshev),
the Statistics Toolbox (knnsearch) and the Image Processing Toolbox (for the
kriging demo). KrigingDemo.m also needs variogramfit.m from the MATLAB File
Exchange, which is not included here:
https://www.mathworks.com/matlabcentral/fileexchange/25948-variogramfit

## Examples

```matlab
% GPS orbit interpolation, asks for PRN and time
OrbitInterpolation

% cubic spline at a query point
yInt = CubicSpline(x, y, x0);

% local RBF interpolation with derivatives, Gaussian kernel
[u0, du_dx, du_dy] = RBF(x, y, u, x0, y0, 10, 10, 'G');
```

## Known issues

OrbitInterpLagrange.m and Lagrange0.m are unfinished. Pnm.m still has two
leftover lines from the original Fortran conversion that have to be removed
before it runs.

## Credits

kriging.m and variogram.m are by Wolfgang Schwanghart (MATLAB File Exchange)
and are included unchanged, with their documentation in the file headers.
sp3Cread.m was originally written by LaQ at TU Delft (2003). clpn.m is a
MATLAB conversion of the CLPN routine from Jin and Zhang, Computation of
Special Functions. The rest is my own work.

Motahareh Esfandyari-Kaloukan
