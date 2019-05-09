{-# LANGUAGE NoImplicitPrelude #-}

module Fission.Web.Internal where

import RIO
import Servant

type RIOServer cfg a = ServerT a (RIO cfg)

-- | Natural transformation `Fission -> Handler`
toHandler :: cfg -> RIO cfg m -> Servant.Handler m
toHandler cfg = liftIO . runRIO cfg
