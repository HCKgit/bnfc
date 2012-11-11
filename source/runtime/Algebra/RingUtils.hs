{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Algebra.RingUtils
  ( module Prelude
  , AbelianGroup(..)
  , AbelianGroupZ(..)
  , Ring(..)
  , RingP(..)
  , Pair(..), select, onlyLeft, onlyRight
  , O(..)
  , sum
  )
 where

import qualified Prelude as P
import Prelude hiding ( (+), (*), splitAt, sum )
import Control.Applicative

class AbelianGroup a where
    zero :: a
    (+)  :: a -> a -> a

instance AbelianGroup Int where
    zero = 0
    (+)  = (P.+)

class AbelianGroup a => AbelianGroupZ a where
    isZero :: a -> Bool

instance AbelianGroupZ Int where
    isZero x = x == 0

class AbelianGroupZ a => Ring a where
    (*) :: a -> a -> a

class AbelianGroupZ a => RingP a where
    mul :: Bool -> a -> a -> Pair a

onlyLeft  x = x  :/: []
onlyRight x = [] :/: x

select p = if p then onlyRight else onlyLeft

data Pair a = (:/:) {leftOf :: a, rightOf :: a}
  deriving (Show)

instance Functor Pair where
  fmap f (a :/: b) = f a :/: f b

newtype O f g a = O {fromO :: f (g a)}
  deriving (AbelianGroup, AbelianGroupZ, Show)
           
instance (Functor f,Functor g) => Functor (O f g) where
   fmap f (O x) = O (fmap (fmap f) x)

instance Applicative Pair where
  pure a = a :/: a
  (f :/: g) <*> (a :/: b) = f a :/: g b

instance AbelianGroup a => AbelianGroup (Pair a) where
  zero = (zero:/:zero)
  (a:/:b) + (x:/:y) = (a+x) :/: (b+y)

instance AbelianGroupZ a => AbelianGroupZ (Pair a) where
  isZero (a:/:b)  = isZero a && isZero b

instance Ring Int where
    (*)  = (P.*)

infixl 7  *
infixl 6  +
infixl 2  :/:

sum :: AbelianGroup a => [a] -> a
sum = foldr (+) zero

instance AbelianGroup Bool where
  zero = False
  (+) = (||)