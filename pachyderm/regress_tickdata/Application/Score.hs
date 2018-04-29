{-# LANGUAGE TypeSynonymInstances, FlexibleInstances #-}

module Application.Score where

import Data.Char
import Control.Applicative
import Application.Data
import Data.Semigroup
    
type Score = SimpleData ScoreMetadata Double
data ScoreMetadata = SMeta { underlier :: Underlier } deriving (Eq, Ord, Show, Read)

instance Semigroup Score where
    Data m d u <> Data m' d' u'
        | m == m' = Data m (liftA2 (+) d d') (u + u')
        | otherwise = Data m (Left ("Underliers disagree", concat [show d, ", ", show d']))  (u + u')


    
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
