module Fission.Web.IPFS
  ( API
  , AuthedAPI
  , PublicAPI
  , authed
  , server
  ) where

import RIO
import RIO.Process (HasProcessContext)

import Data.Has
import Database.Selda
import qualified Network.HTTP.Client as HTTP
import Servant

import           Fission.IPFS.Types        as IPFS
import           Fission.User

import           Fission.Web.Server
import qualified Fission.Web.IPFS.CID      as CID
import qualified Fission.Web.IPFS.Upload   as Upload
import qualified Fission.Web.IPFS.Download as Download
import qualified Fission.Web.IPFS.Pin      as Pin

type API = AuthedAPI
      :<|> PublicAPI

type AuthedAPI = BasicAuth "registered users" User
                 :> AuthedAPI'

type AuthedAPI' = "cids" :> CID.API
             :<|> Upload.API
             :<|> Pin.API

type PublicAPI = Download.API

server :: HasLogFunc        cfg
       => Has HTTP.Manager  cfg
       => HasProcessContext cfg
       => MonadSelda   (RIO cfg)
       => Has IPFS.BinPath  cfg
       => Has IPFS.URL      cfg
       => Has IPFS.Timeout  cfg
       => RIOServer         cfg API
server = authed
    :<|> Download.get

authed :: HasLogFunc        cfg
       => HasProcessContext cfg
       => MonadSelda   (RIO cfg)
       => Has HTTP.Manager  cfg
       => Has IPFS.BinPath  cfg
       => Has IPFS.URL      cfg
       => Has IPFS.Timeout  cfg
       => RIOServer         cfg AuthedAPI
authed usr = CID.allForUser usr
        :<|> Upload.add usr
        :<|> Pin.server usr
