{-# LANGUAGE DeriveFunctor, GeneralizedNewtypeDeriving #-}

module Application.List where


import Application.Data
import Control.Applicative
import System.Directory
import Control.Monad.Trans.Either
import Control.Monad.Trans


type List a = SimpleData () [a]

mkNonEmptyList :: Show a => [a] -> List a
mkNonEmptyList = mkListWithChecks [nonEmpty]
    where
      nonEmpty l | null l = Left ("Assertion for an empty list failed", show l)
                 | otherwise = Right l

mkSizeBoundedList :: Show a => (Int -> Bool) -> [a] -> List a
mkSizeBoundedList f = mkListWithChecks [\x -> g x . f . length $ x]
    where
      g x True = Right x
      g x False = Left ("Size bounded list failed check", show x)

                               
type MStack = Either Err
mkListWithChecks :: [[a] -> MStack [a]] -> [a] ->  List a
mkListWithChecks additional list = mkData checks () list
  where
    checks (_, a) = traverse ($ a) additional
                    *> pure ((), list)


    
