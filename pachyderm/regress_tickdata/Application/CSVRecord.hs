{-# LANGUAGE DeriveGeneric, OverloadedStrings #-}

module Application.CSVRecord where
import Application.Data
import Application.Bin    
import GHC.Generics
import Data.Csv

data Rec = Rec { underlier :: String, windowStart :: String, windowEnd :: String, scoreValue :: Double }  deriving (Generic, Show)

instance FromRecord Rec
instance ToRecord Rec

type CSVRecord_ a = SimpleData () a
type CSVRecord = CSVRecord_ Rec    
type CSVRecordIn = CSVRecord_ InRec

mkCSVRecord :: a -> CSVRecord_ a
mkCSVRecord a = mkData noCheck () a

data InRec = InRec { inunderlier :: String, price :: Double }  deriving (Generic, Show)
instance FromRecord InRec
instance ToRecord InRec
           
