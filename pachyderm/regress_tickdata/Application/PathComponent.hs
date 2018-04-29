module Application.PathComponent where

import Data.ByteString as BS
import Application.Data

type PathComponent = Data PathMetadata ByteString
type PathMetadata = ()

mkPath :: BS.ByteString -> PathMetadata -> PathComponent
mkPath pth m = Data checks m pth
  where
    checks = Right
