module Application.CSVRecord where
import Application.Data
import Application.Bin    

data Rec = Rec { underlier :: String, windowStart :: String, windowEnd :: String, scoreValue :: Double }

type CSVRecord = Data () Rec

mkCSVRrcord :: Rec -> CSVRecord
mkCSVRrcord a = Data noCheck () a
