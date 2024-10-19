# Ray Tracing in One Weekend (in Zig)

Following [Shirley, Black & Hollasch's](https://raytracing.github.io/books/RayTracingInOneWeekend.html) Ray Tracing in One Weekend Course


...but in zig.

## Anti-aliasing

To fix the jagged image, we implement anti-aliasing, using a point-sampling technique.

![Raytraced antialiased sphere](assets/antialiasing.png)

## Diffuse materials

Diffuse materials scatter (or even absorb) light in unexpected ways. Implement this random scattering by using a rejection algorithm that gives us a random reflection that still is on the surface of the hemisphere.

![Raytraced diffuse material sphere](assets/diffuse.png)
