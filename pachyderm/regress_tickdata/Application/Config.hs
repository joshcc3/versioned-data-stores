module Application.Config where

import Application.Data
import Application.FilePath
    
import Control.Applicative
import System.Directory
import Control.Monad.Trans.Either
import Control.Monad.Trans


data Cfg = Cfg { inputRoot :: FilePth, outputRoot :: FilePth }

type Config = SimpleData () Cfg

    
mkCfg :: String -> String -> Config
mkCfg inp out = mkData noCheck () (Cfg (mkFPath inp) (mkFPath out))
