module Example

import Data.List1

public export
data Vote : Type where
  MkVote : Double -> Vote

public export
data Ballot : forall Option. Option -> Type where
  MkBallot : forall Option. (Option -> Vote) -> Ballot Option

data AssignedVote : (Option : Type) -> Option -> Type where
  MkAssignedVote : forall Option. forall option. Vote -> AssignedVote Option option

countOption : forall Option. (option : Option) -> List (Ballot Option) -> AssignedVote Option option
countOption option = \case
  [] => MkAssignedVote (MkVote 0)
  MkBallot getVote :: ballots =>
    case countOption option ballots of
      MkAssignedVote (MkVote sum) =>
        MkAssignedVote (MkVote (sum + case getVote option of MkVote x => x))

normalizeBallotAfterElimination : forall Option. (eliminatedOption : Option) -> Ballot Option -> Ballot Option
normalizeBallotAfterElimination eliminatedOption (MkBallot getVote) = MkBallot (applyFactor getVote)
 where
   factor : Double
   factor =
     case getVote eliminatedOption of
       MkVote x => if x >= 1
                      then 0
                      else
                        if x >= 0
                           then (1/(1 - x))
                           else ?howDidWeGetANegativeVote
   applyFactor : (Option -> Vote) -> Option -> Vote
   applyFactor f option =
     case f option of
       MkVote x => MkVote (x * factor)

public export
countBallots : forall Option. List1 Option -> List1 (Ballot Option) -> List1 Option
countBallots options ballots = result
 where
  optionVote : (option : Option) -> (option ** AssignedVote Option option)
  optionVote option = (option ** countOption option (toList ballots))

  votes : List1 (option ** AssignedVote Option option)
  votes = map optionVote options

  eliminateOption :
    (option ** AssignedVote Option option) ->
    List (option ** AssignedVote Option option) ->
    ((option ** AssignedVote Option option), List (option ** AssignedVote Option option))
  eliminateOption currentMinimum = \case
    [] => (currentMinimum, [])
    newCandidate :: otherCandidates =>
      let
        minVote : Double = case currentMinimum of (_ ** MkAssignedVote (MkVote x)) => x
        newVote : Double = case newCandidate of (_ ** MkAssignedVote (MkVote x)) => x
      in
        if newVote < minVote
           then
             let (finalMinimum, survivors) = eliminateOption newCandidate otherCandidates
             in (finalMinimum, currentMinimum :: survivors)
           else
             let (finalMinimum, survivors) = eliminateOption currentMinimum otherCandidates
             in (finalMinimum, newCandidate :: survivors)

  eliminateOptionResult : ((option ** AssignedVote Option option), List (option ** AssignedVote Option option))
  eliminateOptionResult =
    case votes of
      v ::: vs => eliminateOption v vs

  eliminatedOption : Option
  eliminatedOption =
    case eliminateOptionResult of
      ((option ** _), _) => option

  survivingOptions : List Option
  survivingOptions = map fst (snd eliminateOptionResult)

  result : List1 Option
  result =
    case Data.List1.fromList survivingOptions of
      Nothing => eliminatedOption ::: []
      Just survivingOptions1 =>
        let recResult = countBallots survivingOptions1 (map (normalizeBallotAfterElimination eliminatedOption) ballots)
        in cons eliminatedOption recResult
