{-# LANGUAGE DeriveGeneric, OverloadedStrings #-}

module Application.CSVRecord where
import Application.Data
import Application.Bin    
import GHC.Generics
import Data.Csv

data Rec = Rec { underlier :: String, windowStart :: String, windowEnd :: String, scoreValue :: Double }  deriving (Generic, Show)

instance FromRecord Rec
instance ToRecord Rec

type CSVRecord = SimpleData () Rec

mkCSVRrcord :: Rec -> CSVRecord
mkCSVRrcord a = mkData noCheck () a
