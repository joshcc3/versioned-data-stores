module Application.Score where

import Data.Char
import Application.Data

type Score = SimpleData ScoreMetadata Double
data ScoreMetadata = SMeta { underlier :: Underlier }
    
mkScore :: Double -> String -> Score
mkScore a underlier = mkData checks (SMeta (mkUnderlier underlier)) a
  where
    checks = Right

type Underlier = SimpleData () String

mkUnderlier :: String -> Underlier
mkUnderlier s = mkData checks () s
    where
      checks x@(_, s)
       | length s >= 2 && length s <= 10 = Right x
       | otherwise = Left ("Ticker suspiciously small/large", s)
      check2 (_, s)
       | all isUpper s = Right s
       | otherwise = Left ("Expected all characters to be upper case", s)
