module Application.Config where

import Application.Data
import Application.FilePath
    
import Control.Applicative
import System.Directory
import Control.Monad.Trans.Either
import Control.Monad.Trans


data Cfg = Cfg { inputRoot :: FilePth, expectedInputRoot :: FilePth, outputRoot :: FilePth } deriving (Eq, Ord, Show)

type Config = SimpleData () Cfg

    
mkCfg :: String -> String -> String -> Config
mkCfg inp exp out = mkData check () (Cfg (mkNonEmptyFPath inp) (mkNonEmptyFPath exp) (mkEmptyFPath out))
    where
      check x@(_, Cfg a b c)
            | a /= b && a /= c && b /= c = Right x
            | otherwise = Left ("A pair(s) for the provided roots were duplicated", show x)

type Args = SimpleData () [String]
data As = Args { arg1 :: String, arg2 :: String, arg3 :: String }

mkArgs :: [String] -> Args
mkArgs = mkData check ()
    where
      check (m, x@[_, _, _]) = Right (m, x)
      check (_, as) = Left ("You must supply 3 arguments: the binned tickdata root, the expected outcome data root, evaluation output root", show as)
