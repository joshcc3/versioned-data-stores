module Price where

import Application.Data

type Price = Data PriceMetadata

mkPrice :: PriceMetadata -> Double -> Price
mkPrice price m = Data checks metadata price
  where
    checks (m, a) = check (a >=) (fst (bound m)) && check (a <=) (snd (bound m))
    check f = maybe True f

data PriceMetadata = PMetadata { source :: Maybe String, bound :: Bounds Double, description :: Maybe String }

type Bounds a = (Maybe a, Maybe b)
