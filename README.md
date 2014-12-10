draughts-engine
===============

A massively parallel draughts engine with a combination of serialism and parallelism.

We created a draughts engine which could predict the next move upto some level of depth search. We optimized our serial code using alpha-beta prunng. We then fed the leaves of the game tree into threads of parallel processor for further search. 

Languages used: C++, OpenCL
