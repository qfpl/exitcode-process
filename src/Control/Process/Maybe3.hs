{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TemplateHaskell #-}

module Control.Process.Maybe3(
  Maybe3(..)
, IsMaybe3(..)
, HasMaybe3(..)
, AsMaybe3(..)
, ManyMaybe3(..)
, maybe3Prism
, maybe3Product
, mStdin
, tStdin
, mStdout
, tStdout
, mStderr
, tStderr
) where

import Control.Applicative(Applicative(pure, (<*>)), Alternative((<|>), empty), liftA3)
import Control.Category((.), id)
import Control.Lens(Field1(_1), Field2(_2), Field3(_3), Prism', Lens', Traversal', Iso, Iso', lens, prism', iso, _Just, view, FunctorWithIndex, FoldableWithIndex, TraversableWithIndex(itraversed), traversed, Each(each))
import Control.Monad(Monad(return, (>>=)))
import Control.Monad.Zip(MonadZip(mzip))
import Data.Deriving(deriveEq1, deriveOrd1, deriveShow1)
import Data.Eq(Eq)
import Data.Foldable(Foldable(foldr))
import Data.Functor(Functor(fmap), (<$>))
import Data.Functor.Alt(Alt((<!>)))
import Data.Functor.Apply(Apply((<.>)))
import Data.Functor.Bind(Bind((>>-)))
import Data.Functor.Extend(Extend(duplicated))
import Data.Functor.Product
import Data.Int(Int)
import Data.Maybe(Maybe(Just, Nothing), maybe)
import Data.Monoid(Monoid(mappend, mempty))
import Data.Ord(Ord)
import Data.Semigroup(Semigroup((<>)))
import Data.Traversable(Traversable(traverse))
import Data.Witherable(Filterable(mapMaybe), Witherable(wither))
import GHC.Generics(Generic)
import Prelude(Show)

data Maybe3 a =
  Maybe3
    (Maybe a)
    (Maybe a)
    (Maybe a)
  deriving (Eq, Ord, Show, Generic)

class IsMaybe3 f where
  _Maybe3_ ::
    Iso'
      (f a)
      (Maybe3 a)

instance IsMaybe3 Maybe3 where
  _Maybe3_ =
    id
    
class HasMaybe3 f where
  maybe3 ::
    Lens'
      (f a)
      (Maybe3 a)

instance HasMaybe3 Maybe3 where
  maybe3 =
    id

class AsMaybe3 f where
  _Maybe3 ::
    Prism'
      (f a)
      (Maybe3 a)

instance AsMaybe3 Maybe3 where
  _Maybe3 =
    id
    
class ManyMaybe3 f where
  _ManyMaybe3 ::
    Traversal'
      (f a)
      (Maybe3 a)

instance ManyMaybe3 Maybe3 where
  _ManyMaybe3 =
    id

$(deriveShow1 ''Maybe3) 
$(deriveEq1 ''Maybe3) 
$(deriveOrd1 ''Maybe3) 

instance Functor Maybe3 where
  fmap f (Maybe3 m1 m2 m3) =
    Maybe3 (fmap f m1) (fmap f m2) (fmap f m3)

instance Apply Maybe3 where
  Maybe3 m1 m2 m3 <.> Maybe3 n1 n2 n3 =
    Maybe3 (m1 <*> n1) (m2 <*> n2) (m3 <*> n3)

instance Applicative Maybe3 where
  pure a =
    Maybe3 (Just a) (Just a) (Just a)
  (<*>) =
    (<.>)

instance Bind Maybe3 where
  Maybe3 a1 a2 a3 >>- f =
    let ex j k = k >>- view j . f
    in  Maybe3
          (ex _1 a1)
          (ex _2 a2)
          (ex _3 a3)

instance Monad Maybe3 where
  (>>=) =
    (>>-)
  return =
    pure

instance Alt Maybe3 where
  Maybe3 m1 m2 m3 <!> Maybe3 n1 n2 n3 =
    Maybe3 (m1 <!> n1) (m2 <!> n2) (m3 <!> n3)

instance Alternative Maybe3 where
  (<|>) =
    (<!>)
  empty =
    mempty

instance Foldable Maybe3 where
  foldr f z (Maybe3 m1 m2 m3) =
    foldr (maybe id f) z [m1, m2, m3]

instance Traversable Maybe3 where
  traverse f (Maybe3 m1 m2 m3) =
    Maybe3 <$> traverse f m1 <*> traverse f m2 <*> traverse f m3

instance Extend Maybe3 where
  duplicated (Maybe3 m1 m2 m3) =
    let ex = fmap pure
    in  Maybe3 (ex m1) (ex m2) (ex m3)

instance Semigroup (Maybe3 a) where
  Maybe3 m1 m2 m3 <> Maybe3 n1 n2 n3 =
    Maybe3 (m1 <|> n1) (m2 <|> n2) (m3 <|> n3)

instance Monoid (Maybe3 a) where
  mappend =
    (<>)
  mempty =
    Maybe3 Nothing Nothing Nothing

instance Field1 (Maybe3 a) (Maybe3 a) (Maybe a) (Maybe a) where
  _1 =
    lens
      (\(Maybe3 m1 _ _) -> m1)
      (\(Maybe3 _ m2 m3) m1 -> Maybe3 m1 m2 m3)

instance Field2 (Maybe3 a) (Maybe3 a) (Maybe a) (Maybe a) where
  _2 =
    lens
      (\(Maybe3 _ m2 _) -> m2)
      (\(Maybe3 m1 _ m3) m2 -> Maybe3 m1 m2 m3)

instance Field3 (Maybe3 a) (Maybe3 a) (Maybe a) (Maybe a) where
  _3 =
    lens
      (\(Maybe3 _ _ m3) -> m3)
      (\(Maybe3 m1 m2 _) m3 -> Maybe3 m1 m2 m3)

instance FunctorWithIndex Int Maybe3

instance FoldableWithIndex Int Maybe3

instance TraversableWithIndex Int Maybe3 where
  itraversed =
    traversed

instance Each (Maybe3 a) (Maybe3 b) a b where
  each =
    traverse

instance MonadZip Maybe3 where
  mzip (Maybe3 x1 x2 x3) (Maybe3 y1 y2 y3) =
    Maybe3 (x1 `mzip` y1) (x2 `mzip` y2) (x3 `mzip` y3)

instance Filterable Maybe3 where
  mapMaybe f (Maybe3 m1 m2 m3) = 
    Maybe3 (m1 >>= f) (m2 >>= f) (m3 >>= f)

instance Witherable Maybe3 where
  wither f (Maybe3 m1 m2 m3) = 
    let r Nothing = pure Nothing
        r (Just a) = f a
    in  Maybe3 <$> r m1 <*> r m2 <*> r m3

maybe3Prism ::
  Prism'
    (Maybe3 a)
    (a, a, a)
maybe3Prism =
  prism'
    (\(m1, m2, m3) -> Maybe3 (Just m1) (Just m2) (Just m3))
    (\(Maybe3 m1 m2 m3) -> liftA3 (,,) m1 m2 m3)

maybe3Product ::
  Iso
    (Maybe3 a)
    (Maybe3 b)
    (Product Maybe (Product Maybe Maybe) a)
    (Product Maybe (Product Maybe Maybe) b)
maybe3Product =
  iso
    (\(Maybe3 m1 m2 m3) -> Pair m1 (Pair m2 m3))
    (\(Pair m1 (Pair m2 m3)) -> Maybe3 m1 m2 m3)

mStdin ::
  Lens'
    (Maybe3 a)
    (Maybe a)
mStdin =
  _1

tStdin ::
  Traversal'
    (Maybe3 a)
    a
tStdin =
  mStdin . _Just

mStdout ::
  Lens'
    (Maybe3 a)
    (Maybe a)
mStdout =
  _2

tStdout ::
  Traversal'
    (Maybe3 a)
    a
tStdout =
  mStdout . _Just

mStderr ::
  Lens'
    (Maybe3 a)
    (Maybe a)
mStderr =
  _3

tStderr ::
  Traversal'
    (Maybe3 a)
    a
tStderr =
  mStderr . _Just
