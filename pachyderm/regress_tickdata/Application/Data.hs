module Application.Data where

type Err a = (String, a)
type Check f a = a -> f a

data Data f m a = Data { checks :: Check f (m, a), metadata :: m, dat :: f a, uncheckedDat :: a }
type SimpleData m a = Data (Either (Err a)) m a

mkData checks meta a = Data checks meta (snd <$> checks (meta, a)) a

noCheck = Right
