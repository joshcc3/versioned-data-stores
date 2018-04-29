module Application.Bin where
import Application.Data

type Bin = Data () (String, String)

mkBin :: (String, String) -> Bin
mkBin a = Data checks () a
  where
    checks x@(m, a)
           | fst a < snd a = Left ("Empty Bounds", x)
           | otherwise = Right x
