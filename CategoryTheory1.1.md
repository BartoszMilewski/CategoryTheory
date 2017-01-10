#Lecture 1.1 - Motivation and Philosophy 

[00:00](https://youtu.be/I8LbkfSSR58)

Posing question: What has category theory got to do with programming?

Assembly language is a very imperative approach telling the computer precisely what to do. Assembly language related to Turing Machines.

Assembly is one approach to programming, the other approach coming from Mathematics, e.g. Alonzo Church.

Impractical to write assembly programs, so abstraction is needed. Next level is procedural programming. Dividing problems into procedures.

Next level of abstraction is Object Oriented, hiding stuff inside objects, allowing you to forget about the implementation and deal with a bigger picture.

To deal with more complex problem you need to chop problems into smaller problems. This is Composability.

Abstraction means subtraction - getting rid of details. E.g. In OO objects hide details.

Concurrency doesn't mix well with OO programming. Because objects hide two things that are important - mutation and sharing. Mixing sharing and mutation means it is abstracting over data races. Locks don't help much either.

Next level of abstraction is over functions.

In C++ template programming is the highest level of abstraction. Very complex in C++ - but they are based on simple ideas in Haskell.

Even in Haskell some things are awkward to express. E.g. Edward Kmett libraries that seem hard to understand, but they are based on ideas in category theory that are harder to express in Haskell.

Category theory is a higher-level language above other languages like Haskell, C++, Scala, and ideas can be translated into these. In the same way that Haskell is a higher-level language compared to C++, and Haskell ideas can be translated into C++.

[22:41](https://youtu.be/I8LbkfSSR58?t=1301)

There is a theoretical motivation to study Cateogry Theory, because it makes a lot of programming ideas look the same. And beyond that Category Theory makes a lot of separate parts of Mathematics looks the same - set theory, algebra, topology etc.

There is Type theory in computer science and Type theory in mathematics.

Curry-Howard- Lambek Isomorpishm: whatever you do in Logic can be direct translated to something you do in Type theory ... and again to anything you do in Cartesian Complete Categories.

Some Mathematicians see this as we are discovering something deep truth, but Bartosz thinks there is a simpler explanation based on evolution. 

We are well evolved for image processing due to the pressing need to tell allies from enemies, but only for the last 'millisecond' of evolution have we evolved the ability to think - and more for social and hunting rather than programming and mathematics.

The only way we know how to deal with complex problems is by decomposing them. In science and mathematics, we can only see problems that can be chopped into pieces and put back. No wonder they all look the same. If the problem isn't choppable we move onto something else!

In physics, we chop things into pieces, e.g. things are made of atoms - but what is inside the atom? Protons, electrons, etc. We should be able to find a point if we keep chopping. But we can't deal with point particles because things can't get infinitely close. String theory deals with this but it is not choppable.

In conclusion, maybe category theory is more about how our minds work than about mathematics. It is an epistemology rather than ontology.








