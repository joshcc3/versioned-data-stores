module Application.Score where
import Application.Data

type Score = Data () Double

mkBin :: Double -> Score
mkBin a = Data checks () a
  where
    checks = Right
