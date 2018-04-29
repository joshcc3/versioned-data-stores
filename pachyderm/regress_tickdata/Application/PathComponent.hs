module Application.PathComponent where

import Application.Data

type PathComponent = SimpleData PathMetadata String
type PathMetadata = ()

mkPath :: String -> PathMetadata -> PathComponent
mkPath pth m = mkData checks m pth
  where
    checks x@(_, s)
           | not (elem '/' s) = Right x
           | otherwise = Left ("/ in path component", s)
