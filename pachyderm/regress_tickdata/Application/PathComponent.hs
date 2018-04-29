module PathComponent where

import Data.Lazy.ByteString as lbs
import Application.Data

type PathComponent = Data PathMetadata ByteString { checks :: Check (m, a), metadata :: m, price :: a }
type PathMetadata = ()

mkPath :: String -> PathMetadata -> PathComponent
mkPath pth = Data checks metadata pth
  where
    checks = Right
