module Util where

abort :: (Show a) => a -> b
abort = error . show
