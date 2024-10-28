module Main

import Data.List1
import Example

data ExampleOption
  = A
  | B
  | C
  | D
  | E

Show ExampleOption where
  show = \case
    A => "A"
    B => "B"
    C => "C"
    D => "D"
    E => "E"

exampleOptions : List1 ExampleOption
exampleOptions = A ::: [B, C, D, E]

exampleBallots : List1 (Ballot ExampleOption)
exampleBallots =
  case fromList x of
       Nothing => ?listWontBeEmpty
       Just y => y
 where
  x : List (Ballot ExampleOption)
  x =
    [ MkBallot $ \case
        A => MkVote 0.10
        B => MkVote 0.10
        C => MkVote 0.0
        D => MkVote 0.30
        E => MkVote 0.50
    , MkBallot $ \case
        A => MkVote 0.0
        B => MkVote 0.0
        C => MkVote 1.00
        D => MkVote 0.0
        E => MkVote 0.0
    , MkBallot $ \case
        A => MkVote 0.30
        B => MkVote 0.30
        C => MkVote 0.30
        D => MkVote 0.0
        E => MkVote 0.10
    , MkBallot $ \case
        A => MkVote 0.50
        B => MkVote 0.50
        C => MkVote 0.0
        D => MkVote 0.0
        E => MkVote 0.0
    , MkBallot $ \case
        A => MkVote 0.10
        B => MkVote 0.20
        C => MkVote 0.10
        D => MkVote 0.0
        E => MkVote 0.60
    ]

main : IO ()
main = do
  putStrLn "Printing voting result: `[worst, ..., best]`"
  printLn $ countBallots exampleOptions exampleBallots
