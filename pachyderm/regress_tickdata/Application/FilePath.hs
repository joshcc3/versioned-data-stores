{-# LANGUAGE DeriveFunctor, GeneralizedNewtypeDeriving #-}
module Application.FilePath where

import Application.Data
import Control.Applicative
import System.Directory
import Control.Monad.Trans.Either
import Control.Monad.Trans

(//) :: FilePth -> FilePth -> FilePth
(//) fp1 fp2 = (\a b -> a ++ "/" ++ b) <$> fp1 <*> fp2        


newtype FilePth_ a = F { unwrap :: Data (EitherT (Err String) IO) () a }
    deriving (Functor, Applicative)

type FilePth = FilePth_ String

instance Eq a => Eq (FilePth_ a) where
    F d == F d' = uncheckedDat d == uncheckedDat d'

instance Ord a => Ord (FilePth_ a) where
    compare (F d) (F d') = compare (uncheckedDat d) (uncheckedDat d')


mkFPath :: String -> FilePth
mkFPath fpath = F $ mkData checks () fpath
  where
    checks (_, a) = isDir a *> pure ((), fpath)
    isDir a = do
      b <- liftIO (doesPathExist a)
      if b then pure () else left ("Not a valid filepath", a)


