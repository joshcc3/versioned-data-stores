{-# LANGUAGE DeriveGeneric, OverloadedStrings #-}

import Data.Vector as V
import Data.Csv
import Data.Text    (Text)
import GHC.Generics (Generic)
import qualified Data.ByteString.Lazy as LBS

data Person = Person { name :: !Text , salary :: !Int }
    deriving (Generic, Show)

instance FromRecord Person
instance ToRecord Person

a = encode [("John" :: Text, 27 :: Int), ("Jane", 28)]
testFile = "tmp.csv"
