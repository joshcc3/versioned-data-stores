module Application.PathComponent where

import Data.ByteString as BS
import Application.Data

type PathComponent = SimpleData PathMetadata ByteString
type PathMetadata = ()

mkPath :: BS.ByteString -> PathMetadata -> PathComponent
mkPath pth m = mkData checks m pth
  where
    checks = Right
