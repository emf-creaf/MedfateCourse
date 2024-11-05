README
================
Miquel De Cáceres

# Course on the medfate modelling framework

## Introduction

This repository contains a course devoted to use simulation models in
**medfate** and **medfateland** packages. The course is presented as a
set of Quarto markdown (`*.qmd`) files, which can be easily deployed
into html format.

Course sessions are updated to the most recent course edition and
package versions.

## Usage

The course slides are made using [Quarto](https://quarto.org/). This
publishing system should be installed in order to recreate and modify
course slides.

## Course sessions

Code for course sessions is in `sessions/*.qmd` files. Printed
`sessions/pdf/*.pdf` files can also be found.

1.  Introduction
    - Introduction to process-based forest modelling (theory)
    - Introduction to *medfate* modelling framework (theory)
2.  Forest water and energy balance
    - Design and formulation of forest water/energy balance (theory)
    - Running forest water energy balance (practice)
3.  Forest carbon balance and forest dynamics
    - Design and formulation of forest carbon balance and forest
      dynamics (theory)
    - Running forest growth and forest dynamics (practice)
4.  Large-scale simulations

## Ancillary files

These are required to recreate slide presentations from `*.qmd` files.

- `sessions/resources/scss` contains style sheets that customize slide
  appearance.
- `sessions/resources/img` contains figures in PNG, SVG or JPG format
  used in slides.

## Exercises

Exercises are included in a separate folder.

- `exercises/guidelines/Exercise_*.Rmd` are guidelines for exercises
- `exercises/solutions/Exercise_*_solution.Rmd` are solutions for
  exercises
- `exercises/StudentRdata/*.rds` are data sets required for exercises

## Course editions

Three different course editions have been done so far:

- **June 2022**: CREAF (Barcelona, Spain), Miquel De Cáceres, Víctor
  Granda, Aitor Améztegui
- **December 2022**: University of Eastern Finland (Joensuu, Finland),
  Miquel De Cáceres & Víctor Granda
- **November 2024**: Universidad de Valladolid (Soria, Spain), Miquel De
  Cáceres & Rodrigo Balaguer-Romano
