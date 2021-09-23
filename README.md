# SignatureComparisonExperiment


This repo is to test and experiment with the signature comparison functionality.
Currently there are two functions that are taking a significant amount of processing time to complete.
These functions include: 
parseImagePhase1() = 70-80% Overhead 
parseImagePhase2() = 10-17% Overhead

The goal of this project is to optimize these functions so that the signature comparsion engine can perform
in a much more efficient manner.

The actual SPM engine used in the app this is located at https://github.com/knowink-dev/SignatureComparison_SPM
Any production changes made here will need to be moved over to SPM and tested. 
