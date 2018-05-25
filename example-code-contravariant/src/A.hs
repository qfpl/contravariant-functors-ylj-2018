module A where

import Prelude (fmap, Maybe (..), Either (..))
import Control.Applicative ((<$>), Applicative (..))
import Data.Void (Void, absurd)

class Applicative f => Alter f where
  (<||>) :: f a -> f b -> f (Either a b)
  void :: f Void

instance Alter Maybe where
  (<||>) ma mb =
    case ma of
      Just a -> Just (Left a)
      Nothing ->
        case mb of
          Just b -> Just (Right b)
          Nothing -> Nothing

  void = Nothing

codiagonal :: Either a a -> a
codiagonal (Left  a) = a
codiagonal (Right a) = a

(<|>) :: Alter f => f a -> f a -> f a
(<|>) fx fy = codiagonal <$> (fx <||> fy)

empty :: Alter f => f a
empty = fmap absurd void

