module Bin where


type Bin = Data () (String, String)

mkBin :: (String, String) -> Bin
mkbin a = Data checks () a
  where
    checks = Right