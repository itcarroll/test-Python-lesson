---
---

## Load Data

We will use the function `read.csv()` to load data from a Comma Separated Value
file. The essential argument for the function to read in data is the path to the
file, other optional arguments adjust how the file is read.

Additional file types can be read in using `read.table()`; in fact, `read.csv()`
is a simple wrapper for the `read.table()` function having set some default
values for some of the optional arguments (e.g. `sep = ","`).
{:.notes}

===

Type `read.csv(` into the console and then press **tab** to see what arguments
this function takes. Hovering over each item in the list will show a description
of that argument from the help documentation about that function. Specify the
values to use for an argument using the syntax `name = value`.



~~~python
import pandas as pd

pd.read_csv('data/species.csv')
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


~~~
    id             genus          species     taxa
0   AB        Amphispiza        bilineata     Bird
1   AH  Ammospermophilus          harrisi   Rodent
2   AS        Ammodramus       savannarum     Bird
3   BA           Baiomys          taylori   Rodent
4   CB   Campylorhynchus  brunneicapillus     Bird
5   CM       Calamospiza      melanocorys     Bird
6   CQ        Callipepla         squamata     Bird
7   CS          Crotalus       scutalatus  Reptile
8   CT     Cnemidophorus           tigris  Reptile
9   CU     Cnemidophorus        uniparens  Reptile
10  CV          Crotalus          viridis  Reptile
11  DM         Dipodomys         merriami   Rodent
12  DO         Dipodomys            ordii   Rodent
13  DS         Dipodomys      spectabilis   Rodent
14  DX         Dipodomys              sp.   Rodent
15  EO           Eumeces        obsoletus  Reptile
16  GS          Gambelia            silus  Reptile
17  NL           Neotoma         albigula   Rodent
18  NX           Neotoma              sp.   Rodent
19  OL         Onychomys      leucogaster   Rodent
20  OT         Onychomys         torridus   Rodent
21  OX         Onychomys              sp.   Rodent
22  PB       Chaetodipus          baileyi   Rodent
23  PC            Pipilo        chlorurus     Bird
24  PE        Peromyscus         eremicus   Rodent
25  PF       Perognathus           flavus   Rodent
26  PG         Pooecetes        gramineus     Bird
27  PH       Perognathus         hispidus   Rodent
28  PI       Chaetodipus      intermedius   Rodent
29  PL        Peromyscus         leucopus   Rodent
30  PM        Peromyscus      maniculatus   Rodent
31  PP       Chaetodipus     penicillatus   Rodent
32  PU            Pipilo           fuscus     Bird
33  PX       Chaetodipus              sp.   Rodent
34  RF   Reithrodontomys       fulvescens   Rodent
35  RM   Reithrodontomys        megalotis   Rodent
36  RO   Reithrodontomys         montanus   Rodent
37  RX   Reithrodontomys              sp.   Rodent
38  SA        Sylvilagus        audubonii   Rabbit
39  SB          Spizella          breweri     Bird
40  SC        Sceloporus           clarki  Reptile
41  SF          Sigmodon      fulviventer   Rodent
42  SH          Sigmodon         hispidus   Rodent
43  SO          Sigmodon     ochrognathus   Rodent
44  SS      Spermophilus        spilosoma   Rodent
45  ST      Spermophilus     tereticaudus   Rodent
46  SU        Sceloporus        undulatus  Reptile
47  SX          Sigmodon              sp.   Rodent
48  UL            Lizard              sp.  Reptile
49  UP            Pipilo              sp.     Bird
50  UR            Rodent              sp.   Rodent
51  US           Sparrow              sp.     Bird
52  ZL       Zonotrichia       leucophrys     Bird
53  ZM           Zenaida         macroura     Bird
~~~
{:.output}


===

Question
: How does `read.csv` determine the field names?

Answer
: {:.fragment} The `read.csv` command assumes the first row in the file contains
column names. Look at `?read.csv` to see the default `header = TRUE` argument.
What exactly that means is described down in the "Arguments" section.

===

Use the assignment operator "<-" to load data into a variable for
subsequent operations.



~~~python
animals = pd.read_csv('data/animals.csv')
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

After reading in the "animals.csv" file, you can explore what types of data are
in each column with the `str` function, short for "structure".



~~~python
> animals.dtypes
~~~
{:title="Console" .input}


~~~
id                   int64
month                int64
day                  int64
year                 int64
plot_id              int64
species_id          object
sex                 object
hindfoot_length    float64
weight             float64
dtype: object
~~~
{:.output}


===

Missing data, as interpreted by the `read.csv` function, is controlled by the
`na.strings` argument. Override the default value of `'NA'` with the empty
string, `''`, to properly interpret the "species_id" and "sex" columns.

You can also specify multiple things to be interpreted as missing values, such
as `na.strings = c("missing", "no data", "< 0.05 mg/L", "XX")`.
{:.notes}



~~~python
animals = pd.read_csv('data/animals.csv', na_values='')
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


The data type is the same.



~~~python
> animals.dtypes
~~~
{:title="Console" .input}


~~~
id                   int64
month                int64
day                  int64
year                 int64
plot_id              int64
species_id          object
sex                 object
hindfoot_length    float64
weight             float64
dtype: object
~~~
{:.output}

