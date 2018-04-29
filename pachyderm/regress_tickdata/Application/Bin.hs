module Application.Bin where
import Application.Data

type Bin = SimpleData () (String, String)

mkBin :: (String, String) -> Bin
mkBin a = mkData checks () a
  where
    checks x@(m, a)
           | fst a > snd a = Left ("Empty Bounds", a)
           | otherwise = Right x
