module Application.FilePath where

import Application.Data
import Control.Applicative
import System.Directory
import Control.Monad.Trans.Either
import Control.Monad.Trans


type FilePth = Data (EitherT (Err String) IO) () String

    
mkFPath :: String -> FilePth
mkFPath fpath = mkData checks () fpath
  where
    checks (_, a) = isDir a *> pure ((), fpath)
    isDir a = do
      b <- liftIO (doesPathExist a)
      if b then pure () else left ("Not a valid filepath", a)


