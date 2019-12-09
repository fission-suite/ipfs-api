module Fission.Web.IPFS.CID
  ( API
  , allForUser
  ) where

import           Database.Selda
import           Servant

import           Fission.Prelude
import qualified Fission.IPFS.Types     as IPFS
import           Fission.IPFS.CID.Types as IPFS.CID

import           Fission.User           (User (..))
import           Fission.User.CID.Query

import           Fission.Web.Server

type API = Get '[JSON, PlainText] [CID]

allForUser :: MonadSelda (RIO cfg) => User -> RIOServer cfg API
allForUser User { userID } = do
  hashes <- query do
    uCIDs <- select Table.userCIDs
    restrict <| uCIDs `byUser` userID
    return   <| uCIDs ! #cid

  return <| IPFS.CID <$> hashes
