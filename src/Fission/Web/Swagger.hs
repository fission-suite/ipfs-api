module Fission.Web.Swagger
  ( API
  , docs
  , server
  ) where

import RIO

import           Control.Lens
import Data.Swagger
import Servant
import Servant.Swagger (toSwagger)
import Servant.Swagger.UI.ReDoc

import qualified Fission.Web.Routes as Web
import Fission.Web.Server

type API = SwaggerSchemaUI "swagger-ui" "swagger.json"

server :: RIOServer cfg API
server = hoistServer (Proxy :: Proxy API) fromHandler (redocSchemaUIServer docs)

docs :: Swagger
docs =
  toSwagger (Proxy :: Proxy Web.API)
  & info . title       .~ "FISSION's IPFS API"
  & info . version     .~ "1.0.0"
  & info . description ?~ "Easily use IPFS from Web 2.0 applications"
  & info . contact     ?~ fissionContact
  & info . license     ?~ projectLicense
  where
    fissionContact = Contact
      { _contactName  = Just "FISSION Team"
      , _contactUrl   = Just (URL "https://fission.codes")
      , _contactEmail = Just "support@fission.codes"
      }

    projectLicense = "Apache 2.0"
                   & url ?~ URL "http://www.apache.org/licenses/LICENSE-2.0"
