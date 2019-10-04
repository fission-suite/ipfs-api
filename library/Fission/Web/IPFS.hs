module Fission.Web.IPFS
  ( API
  , Auth
  , AuthedAPI
  , PublicAPI
  , SimpleAPI
  , UnauthedAPI
  , authed
  , public
  , server
  ) where

import RIO
import RIO.Process (HasProcessContext)

import Data.Has
import Database.Selda

import qualified Network.HTTP.Client as HTTP
import           Servant

import           Fission.IPFS.Types        as IPFS
import           Fission.User

import           Fission.Web.Server
import qualified Fission.Web.IPFS.CID           as CID
import qualified Fission.Web.IPFS.Upload        as Upload
import qualified Fission.Web.IPFS.Upload.Simple as Upload.Simple
import qualified Fission.Web.IPFS.Download      as Download
import qualified Fission.Web.IPFS.Pin           as Pin
import qualified Fission.Web.IPFS.DAG           as DAG
import qualified Fission.Web.IPFS.Peer         as Peer

type API = AuthedAPI
      :<|> PublicAPI

type Auth = BasicAuth "registered users" User

type AuthedAPI = Auth :> UnauthedAPI

type UnauthedAPI = "cids" :> CID.API
              :<|> Upload.API
              :<|> Pin.API
              :<|> "dag" :> DAG.API

type SimpleAPI = "cids" :> CID.API
            :<|> Upload.Simple.API
            :<|> Pin.API
            :<|> "dag" :> DAG.API

type PublicAPI = "peerid" :> Peer.API
            :<|> Download.API

server :: HasLogFunc        cfg
       => HasProcessContext cfg
       => MonadSelda   (RIO cfg)
       => Has HTTP.Manager  cfg
       => Has IPFS.URL      cfg
       => Has IPFS.BinPath  cfg
       => Has IPFS.Timeout  cfg
       => RIOServer         cfg API
server = authed :<|> public

authed :: HasLogFunc        cfg
       => HasProcessContext cfg
       => MonadSelda   (RIO cfg)
       => Has HTTP.Manager  cfg
       => Has IPFS.URL      cfg
       => Has IPFS.BinPath  cfg
       => Has IPFS.Timeout  cfg
       => RIOServer         cfg AuthedAPI
authed usr = CID.allForUser usr
        :<|> Upload.add usr
        :<|> Pin.server usr
        :<|> DAG.put usr -- Question: why is the function naming convention so all over the place?
                         -- Answer: it's not! This is what they're called in IPFS!

public :: HasLogFunc        cfg
       => HasProcessContext cfg
       => MonadSelda   (RIO cfg)
       => Has HTTP.Manager  cfg
       => Has IPFS.URL      cfg
       => Has IPFS.BinPath  cfg
       => Has IPFS.Timeout  cfg
       => RIOServer         cfg PublicAPI
public = Peer.get
    :<|> Download.get
