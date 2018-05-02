module Application.FileUtil where

import Application.List
import Data.ByteString.Lazy as LBS    
import Data.Csv
    
abort = error . show
writeRecord :: FileName -> [Rec] -> IO ()
writeRecord fname recs = do
  let rs = either abort id . dat $ mkSizeBoundedList (>= 3) recs
  result <- LBS.writeFile fname (encode rs)
  putStrLn $ "Wrote csv records to " ++ fname ++ ": " ++ show result
    
