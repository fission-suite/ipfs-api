{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}

module Fission.Web.IPFS where

import RIO

import Servant

import           Fission.IPFS.Peer       as Peer
import           Fission.Web.Internal
import qualified Fission.Web.IPFS.Upload as Upload

type API = {- Root -} Upload.API
      :<|> "peers" :> Get '[JSON] [Peer]

server :: FissionServer API
server = Upload.server :<|> Peer.all

api :: Proxy API
api = Proxy
