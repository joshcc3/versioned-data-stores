{-# LANGUAGE DeriveFunctor #-}
module Application.Data where
import Control.Applicative
import Data.Monoid


type Err = (String, String)
type Check f a = a -> f a

data Data f m a = Data { metadata :: m, dat :: f a, uncheckedDat :: a } deriving (Functor, Eq, Ord, Show, Read)

instance (Monoid m, Applicative f) => Applicative (Data f m) where
    pure x = Data mempty (pure x) x
    Data m d u <*> Data m' d' u' = Data (m <> m') (d <*> d') (u u')

                
type SimpleData m a = Data (Either Err) m a

mkData checks meta a = Data meta (snd <$> checks (meta, a)) a

noCheck = Right

instance (Monoid m, Applicative f, Num a) => Num (Data f m a) where
    (+) = liftA2 (+)
    (*) = liftA2 (*)
    abs = fmap abs
    signum = fmap signum
    fromInteger = pure . fromInteger
    negate = fmap negate
    
    
    
