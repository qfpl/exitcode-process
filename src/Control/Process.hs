{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FunctionalDependencies #-}

module Control.Process where

import Control.Lens
import Control.Process.Maybe3
import System.Process(ProcessHandle)
import Prelude

data Maybe3ProcessHandle a =
  Maybe3ProcessHandle
    (Maybe3 a)
    ProcessHandle

instance HasMaybe3 Maybe3ProcessHandle where
  maybe3 =
    lens
      (\(Maybe3ProcessHandle m _) -> m)
      (\(Maybe3ProcessHandle _ h) m -> Maybe3ProcessHandle m h)

instance ManyMaybe3 Maybe3ProcessHandle where
  _ManyMaybe3 =
    maybe3

----

class HasStdin f g | f -> g where
  _stdin ::
    Lens'
      (f a)
      (g a)

instance HasStdin Maybe3 Maybe where
  _stdin =
    lens
      (\(Maybe3 i _ _) -> i)
      (\(Maybe3 _ o e) i -> Maybe3 i o e)

instance HasStdin Maybe3ProcessHandle Maybe where
  _stdin =
    maybe3 . _stdin

----


class IsProcessHandle a where
  _ProcessHandle_ ::
    Iso'
      a
      ProcessHandle

instance IsProcessHandle ProcessHandle where
  _ProcessHandle_ =
    id
    
class HasProcessHandle a where
  processHandle ::
    Lens'
      a
      ProcessHandle

instance HasProcessHandle ProcessHandle where
  processHandle =
    id

class AsProcessHandle a where
  _ProcessHandle ::
    Prism'
      a
      ProcessHandle

instance AsProcessHandle ProcessHandle where
  _ProcessHandle =
    id
    
class ManyProcessHandle a where
  _ManyProcessHandle ::
    Traversal'
      a
      ProcessHandle

instance ManyProcessHandle ProcessHandle where
  _ManyProcessHandle =
    id

----

class IsMaybe3ProcessHandle f where
  _Maybe3ProcessHandle_ ::
    Iso'
      (f a)
      (Maybe3ProcessHandle a)

instance IsMaybe3ProcessHandle Maybe3ProcessHandle where
  _Maybe3ProcessHandle_ =
    id
    
class HasMaybe3ProcessHandle f where
  maybe3ProcessHandle ::
    Lens'
      (f a)
      (Maybe3ProcessHandle a)

instance HasMaybe3ProcessHandle Maybe3ProcessHandle where
  maybe3ProcessHandle =
    id

class AsMaybe3ProcessHandle f where
  _Maybe3ProcessHandle ::
    Prism'
      (f a)
      (Maybe3ProcessHandle a)

instance AsMaybe3ProcessHandle Maybe3ProcessHandle where
  _Maybe3ProcessHandle =
    id
    
class ManyMaybe3ProcessHandle f where
  _ManyMaybe3ProcessHandle ::
    Traversal'
      (f a)
      (Maybe3ProcessHandle a)

instance ManyMaybe3ProcessHandle Maybe3ProcessHandle where
  _ManyMaybe3ProcessHandle =
    id
