{-# LANGUAGE TupleSections #-}
{-# LANGUAGE DeriveFunctor, GeneralizedNewtypeDeriving #-}
{-# LANGUAGE DeriveGeneric #-}

module Application.Main where

import Application.Data
import Application.Tree
import Application.PathComponent
import Application.Price
import qualified Application.Score as Score
import Application.CSVRecord
import Application.Bin
import Application.Config
import Application.FilePath    

import Control.Monad.Trans
import Control.Monad
import Data.Monoid
import qualified Control.Exception as E
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
observed filepth = do
  root <- eitherT abort pure . dat . unwrap $ filepth
  anchored <- buildL root
  toDataSample (dirTree anchored)

toDataSample :: DirTree String -> IO (Tree [PathComponent] ClosePrice)
toDataSample = expandOutUnderliers
  where
    expandOutUnderliers :: DirTree String -> IO (Tree [PathComponent] ClosePrice)
    expandOutUnderliers (Failed name err) = E.throw err
    expandOutUnderliers (Dir n c) = do
      sdirs <- mapM expandOutUnderliers c
      return (Node [mkPath n ()] sdirs)
    expandOutUnderliers (File n f) = do
      fcontents <- LBS.readFile f
      let
          records :: [CSVRecordIn]
          records = map mkCSVRecord . V.toList . either abort id . decode NoHeader $ fcontents
          cs = map formatAsFile records
          formatAsFile :: CSVRecordIn -> Tree [PathComponent] ClosePrice
          formatAsFile record =
            let InRec u p = either abort id (dat record)
            in Leaf [mkPath u ()] (mkPrice (PMetadata (Just [f]) (Just 0, Nothing) (Just ["Price for " ++ u])) p)
      return (Node [mkPath n ()] cs)


binned :: FilePth -> IO Binned
binned fp = do
  root <- eitherT abort pure . dat . unwrap $ fp
  anchored <- buildL root
  let toBinned (s, e, t) = toDataSample t >>= pure . (mkBin (s, e),)
      triples = do
           Dir s cs  <- [dirTree anchored]
           Dir e cs' <- cs
           t         <- cs'
           return (s, e, t)
  paired <- mapM toBinned triples
  return $ M.fromList paired


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
              | checkPathComponents m = do
                            underlier <- dat (last m)
                            price <- dat a
                            pure $ M.fromList [(underlier, Score.mkScore price underlier)]
              | otherwise = error $ "Path components aren't the same: " ++ show m
          deconstruct (Node x ts) = fmap mergeScores (traverse deconstruct ts)
          checkPathComponents m = all id (zipWith (==) m (tail m))
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

