module Application.Bin where
import Application.Data
import Data.Char

type Bin = SimpleData () (String, String)

mkBin :: (String, String) -> Bin
mkBin a = mkData checks () a
  where
    checks x@(m, a)
           | any (not . isDigit) (fst a ++ snd a) = Left ("Bounds are not digits", show a)
           | otherwise = Right x
