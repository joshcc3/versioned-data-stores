module CSVRecord where


data Rec = Rec { underlier :: String, windowStart :: String, windowEnd :: String, scoreValue :: Double }

type CSVRecord = Data () Rec

mkCSVRrcord :: (String, String) -> Bin
mkCSVRrcord a = Data checks () a
  where
    checks (m, a) = windowStart a < windowEnd a