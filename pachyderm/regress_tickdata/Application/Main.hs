{-# LANGUAGE DeriveFunctor, GeneralizedNewtypeDeriving #-}
{-# LANGUAGE DeriveGeneric #-}


import Application.Data
import Application.Tree
import Application.PathComponent
import Application.Price
import qualified Application.Score as Score
import Application.CSVRecord
import Application.Bin
import Application.Config
import Application.FilePath    

import Data.Monoid
import qualified Data.Semigroup as S
import Control.Monad.Trans.Either
import qualified Data.Vector as V
import qualified Data.ByteString.Lazy as LBS
import System.Directory.Tree
import Data.Csv
import qualified Data.Map as M

type ClosePrice = Price Double


type DataSample = Tree [PathComponent] ClosePrice


type Observed = DataSample
type Expected = DataSample
type Binned = M.Map Bin Observed
type Evaluated = M.Map Bin [Score.Score]
type ScoreAsCSV = CSVRecord
type FPath = String
type OutputRecord = Rec


observed :: FilePth -> IO Expected
observed = undefined

binned :: FilePth -> IO Binned
binned = undefined

evaluate :: Expected -> Binned -> Evaluated
evaluate expected binned
   = M.mapWithKey (toScore expected) binned
     where
       toScore :: Expected -> Bin -> Observed -> [Score.Score]
       toScore e b o = map snd . M.toList . either abort id $ deconstruct foldable
         where 
          foldable = squaredDiff <$> e <*> o
          deconstruct :: Tree [PathComponent] ClosePrice -> Either Err (M.Map String Score.Score)
          deconstruct (Leaf m a)
              | all id (zipWith (==) m (tail m)) = do
                                                     underlier <- dat (last m)
                                                     price <- dat a
                                                     pure $ M.fromList [(underlier, Score.mkScore price underlier)]
              | otherwise = error $ "Path components aren't the same: " ++ show m
          deconstruct (Node _ ts) = fmap mergeScores (traverse deconstruct ts)
          mergeScores = foldl (M.unionWith (S.<>)) M.empty


squaredDiff x y = (**) <$> (x - y) <*> 2       

csvRecord :: FilePth -> Evaluated -> M.Map FilePth [CSVRecord]
csvRecord outputFp evaled = M.mapKeys toFname (M.mapWithKey toCsvRecord evaled)
    where
      toFname bin = fmap (flip pathAppend . either abort binToFname $ dat bin) outputFp
          where
            pathAppend a b = a ++ "/" ++ b
            binToFname (l, u) = l ++ "-" ++ u ++ ".csv"
      toCsvRecord :: Bin -> [Score.Score] -> [CSVRecord]
      toCsvRecord bin scores = either abort id $ do
        (windowStart, windowEnd) <- dat bin
        traverse (\score -> do
                    underlier <- dat . Score.underlier . metadata $ score
                    scoreVal <- dat score
                    pure . mkCSVRecord $
                          Rec underlier windowStart windowEnd scoreVal)
                 scores

-- What happens to stuff like open file handles and all the other bits of global state left lying around?
writeRecord :: FileName -> [Rec] -> IO ()
writeRecord fname recs = do
  result <- LBS.writeFile fname (encode recs)
  putStrLn $ "Wrote csv records to " ++ fname ++ ": " ++ show result

abort :: (Show a) => a -> b
abort = error . show
        
main :: IO ()
main = do
  let config = mkCfg "/pfs/tickdata" "/pfs/out"
      Cfg inputRoot outputRoot = either (\_ -> error "Config check failed") id (dat config)
  expected <- observed inputRoot
  bins <- binned inputRoot
  let evaluated = evaluate expected bins
      recs = csvRecord outputRoot evaluated
      handleRecord fname csvrecs = writeRecord fname . either abort id . traverse dat $ csvrecs
  mapM_ (\(fpth, csvrecs) -> do
           fname <- eitherT abort pure (dat . unwrap $ fpth)
           handleRecord fname csvrecs)
        (M.toList recs)

