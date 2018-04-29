module Application.Score where
import Application.Data

type Score = SimpleData () Double

mkBin :: Double -> Score
mkBin a = mkData checks () a
  where
    checks = Right
