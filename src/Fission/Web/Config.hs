{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE LambdaCase        #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE RecordWildCards   #-}

module Fission.Web.Config
  ( Config (..)
  , get
  ) where

import RIO
import Data.Has

import Network.Wai.Handler.Warp
import System.Envy

import Fission.Internal.Constraint

data Config = Config { port :: Port }
  deriving (Generic, Show)

instance DefConfig Config where
  defConfig = Config 1337

instance FromEnv Config

get :: (MonadRIO cfg m, HasLogFunc cfg) => m Config
get = liftIO (decodeEnv :: IO (Either String Config)) >>= \case
  Right config ->
    return config

  Left err -> do
    logError $ displayShow err
    return defConfig
