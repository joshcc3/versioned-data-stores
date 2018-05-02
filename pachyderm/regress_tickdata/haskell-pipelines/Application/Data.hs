{-# LANGUAGE DeriveTraversable #-}
{-# LANGUAGE DeriveFoldable #-}
{-# LANGUAGE DeriveFunctor #-}
module Application.Data where
import Control.Applicative
import Data.Monoid


type Err = (String, String)
type Check f a = a -> f a

data Data f m a = Data { metadata :: m, dat :: f a, uncheckedDat :: a } deriving (Functor, Eq, Ord, Show, Read, Foldable, Traversable)

instance (Monoid m, Applicative f) => Applicative (Data f m) where
    pure x = Data mempty (pure x) x
    Data m d u <*> Data m' d' u' = Data (m <> m') (d <*> d') (u u')

                
instance (Monoid m, Monad f) => Monad (Data f m) where
    return = pure
    Data m d u >>= f = Data (m <> metadata m1) m2 (uncheckedDat m1)
        where
          m1 = f u
          m2 = d >>= dat . f


type SimpleData m a = Data (Either Err) m a

mkData :: Functor f => ((m, a) -> f (m, a)) -> m -> a -> Data f m a
mkData checks meta a = Data meta (snd <$> checks (meta, a)) a

noCheck = Right

instance (Monoid m, Applicative f, Num a) => Num (Data f m a) where
    (+) = liftA2 (+)
    (*) = liftA2 (*)
    abs = fmap abs
    signum = fmap signum
    fromInteger = pure . fromInteger
    negate = fmap negate
    
    
    
