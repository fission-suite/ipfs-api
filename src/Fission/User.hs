{-# LANGUAGE DeriveAnyClass    #-}
{-# LANGUAGE FlexibleContexts  #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedLabels  #-}
{-# LANGUAGE OverloadedStrings #-}

module Fission.User
  ( User (..)
  , mkTable
  , setup
  , tableName
  ) where

import RIO hiding (id)

import Data.Has
import Database.Selda

import Fission.Platform
import qualified Fission.Platform.Heroku as Heroku

import Fission.Storage.SQLite
import Fission.Internal.Constraint
import Fission.Config

data User = User
  { id            :: ID User
  , platform      :: Platform
  , herokuAddOnId :: Maybe (ID Heroku.AddOn)
  } deriving ( Show
             , Eq
             , SqlRow
             , Generic
             )

tableName :: TableName
tableName = "users"

mkTable :: Table User
mkTable = table tableName [#id :- autoPrimary]

setup :: MonadRIO cfg m
      => HasLogFunc cfg
      => Has DBPath cfg
      => m ()
setup = setupTable mkTable tableName
