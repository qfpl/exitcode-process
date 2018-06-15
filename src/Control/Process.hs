{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE DeriveGeneric #-}

module Control.Process where

import Control.Applicative(Applicative(pure, (<*>)), Alternative((<|>), empty), liftA3)
import Control.Category((.), id)
import Control.Lens(Field1(_1), Field2(_2), Field3(_3), Prism', Lens', Traversal', lens, prism', _Just, view)
import Control.Monad(Monad(return, (>>=)))
import Data.Eq(Eq)
import Data.Foldable(Foldable(foldr))
import Data.Functor(Functor(fmap), (<$>))
import Data.Functor.Alt(Alt((<!>)))
import Data.Functor.Apply(Apply((<.>)))
import Data.Functor.Bind(Bind((>>-)))
import Data.Functor.Extend(Extend(duplicated))
import Data.Maybe(Maybe(Just, Nothing), maybe)
import Data.Monoid(Monoid(mappend, mempty))
import Data.Ord(Ord)
import Data.Semigroup(Semigroup((<>)))
import Data.Traversable(Traversable(traverse))
import GHC.Generics(Generic)
import Prelude(Show)

data Maybe3 a =
  Maybe3
    (Maybe a)
    (Maybe a)
    (Maybe a)
  deriving (Eq, Ord, Show, Generic)

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

maybe3Prism ::
  Prism'
    (Maybe3 a)
    (a, a, a)
maybe3Prism =
  prism'
    (\(m1, m2, m3) -> Maybe3 (Just m1) (Just m2) (Just m3))
    (\(Maybe3 m1 m2 m3) -> liftA3 (,,) m1 m2 m3)

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
