module Application.Config where

import Application.Data
import Application.FilePath
    
import Control.Applicative
import System.Directory
import Control.Monad.Trans.Either
import Control.Monad.Trans


data Cfg = Cfg { inputRoot :: FilePth, expectedInputRoot :: FilePth, outputRoot :: FilePth }

type Config = SimpleData () Cfg

    
mkCfg :: String -> String -> String -> Config
mkCfg inp exp out = mkData noCheck () (Cfg (mkFPath inp) (mkFPath exp) (mkFPath out))

type Args = SimpleData () [String]
data As = Args { arg1 :: String, arg2 :: String, arg3 :: String }

mkArgs :: [String] -> Args
mkArgs = mkData check ()
    where
      check (m, x@[_, _, _]) = Right (m, x)
      check (_, as) = Left ("You must supply 3 arguments: the binned tickdata root, the expected outcome data root, evaluation output root", show as)
