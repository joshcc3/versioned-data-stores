{-# LANGUAGE DeriveFunctor, GeneralizedNewtypeDeriving #-}
module Application.FilePath where

import Application.Data
import Control.Applicative
import System.Directory
import Control.Monad.Trans.Either
import Control.Monad.Trans

(//) :: FilePth -> FilePth -> FilePth
(//) fp1 fp2 = (\a b -> a ++ "/" ++ b) <$> fp1 <*> fp2        

type MStack = EitherT Err IO
newtype FilePth_ a = F { unwrap :: Data MStack () a }
    deriving (Functor, Applicative)

type FilePth = FilePth_ String

instance Show a => Show (FilePth_ a) where
    show = show . uncheckedDat . unwrap

instance Eq a => Eq (FilePth_ a) where
    F d == F d' = uncheckedDat d == uncheckedDat d'

instance Ord a => Ord (FilePth_ a) where
    compare (F d) (F d') = compare (uncheckedDat d) (uncheckedDat d')

mkFPath :: String -> FilePth
mkFPath = mkWithChecks [] 

mkEmptyFPath :: String -> FilePth
mkEmptyFPath = mkWithChecks [dirCondition (\b -> length b == 0)]

mkNonEmptyFPath = mkWithChecks [dirCondition (\b -> length b > 0)]

dirCondition cond a = do
  b <- liftIO (listDirectory a)
  if cond b then pure a else left ("Empty Directory is not empty", a)



mkWithChecks :: [String -> MStack String] -> String ->  FilePth
mkWithChecks additional fpath = F $ mkData checks () fpath
  where
    checks (_, a) = isDir a
                    *> traverse ($ a) additional
                    *> pure ((), fpath)
    isDir a = do
      b <- liftIO (doesPathExist a)
      if b then pure () else left ("Not a valid filepath", a)


