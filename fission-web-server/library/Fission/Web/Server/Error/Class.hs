{-# LANGUAGE UndecidableInstances #-}

module Fission.Web.Server.Error.Class (ToServerError (..)) where

import qualified RIO.ByteString.Lazy                                as Lazy

import           Servant.Server                                     as Server

import qualified Network.IPFS.Error                                 as IPFS
import           Network.IPFS.Types

import qualified Network.IPFS.Add.Error                             as Add
import qualified Network.IPFS.Get.Error                             as Get
import qualified Network.IPFS.Peer.Error                            as Peer

import           Fission.Prelude

import qualified Fission.User.Username.Error                        as Username

import           Fission.Error.AlreadyExists.Types
import           Fission.Error.InvalidURL.Types
import           Fission.Error.NotFound.Types

import           Fission.Web.Auth.Error                             as Web.Auth

import           Fission.Web.Server.Error.ActionNotAuthorized.Types

import           Fission.Web.Auth.Token.JWT.Claims.Error            as JWT.Claims
import           Fission.Web.Auth.Token.JWT.Error                   as JWT
import           Fission.Web.Auth.Token.JWT.Header.Error            as JWT.Header
import           Fission.Web.Auth.Token.JWT.Proof.Error             as JWT.Proof
import           Fission.Web.Auth.Token.JWT.Resolver.Error          as JWT.Resolver
import           Fission.Web.Auth.Token.JWT.Signature.Error         as JWT.Signature

import qualified Fission.Web.Server.Error.Message                   as Error

class ToServerError err where
  toServerError :: err -> ServerError

instance ToServerError ServerError where
  toServerError = identity

instance ToServerError Int where
  toServerError = \case
    300 -> err300
    301 -> err301
    302 -> err302
    303 -> err303
    304 -> err304
    305 -> err305
    307 -> err307

    400 -> err400
    401 -> err401
    402 -> err402
    403 -> err403
    404 -> err404
    405 -> err405
    406 -> err406
    407 -> err407
    409 -> err409
    410 -> err410
    411 -> err411
    412 -> err412
    413 -> err413
    414 -> err414
    415 -> err415
    416 -> err416
    417 -> err417
    418 -> err418
    422 -> err422

    500 -> err500
    501 -> err501
    502 -> err502
    503 -> err503
    504 -> err504
    505 -> err505

    n -> error (show n <> " is not an error status code")

instance ToServerError IPFS.Error where
  toServerError = \case
    IPFS.AddErr           addErr -> toServerError addErr
    IPFS.GetErr           getErr -> toServerError getErr
    IPFS.LinearizationErr linErr -> toServerError linErr

instance ToServerError Get.Error where
  toServerError = \case
    Get.InvalidCID txt ->
      err422 { errBody = displayLazyBS txt }

    Get.UnexpectedOutput txt ->
      err502 { errBody = "Unexpected IPFS result: " <> displayLazyBS txt }

    Get.UnknownErr txt ->
      err502 { errBody = "Unknown IPFS error" <> displayLazyBS txt}

    Get.TimedOut (CID hash) txt ->
      err504 { errBody = "IPFS timed out looking for " <> displayLazyBS hash <> " / Detail: " <> displayLazyBS txt}

instance ToServerError Add.Error where
  toServerError = \case
    Add.InvalidFile        -> err422 { errBody = "File not processable by IPFS" }
    Add.UnknownAddErr    _ -> err502 { errBody = "Unknown IPFS error" }
    Add.RecursiveAddErr  _ -> err502 { errBody = "Error while adding directory" }
    Add.UnexpectedOutput _ -> err502 { errBody = "Unexpected IPFS result" }
    Add.IPFSDaemonErr  msg -> err502 { errBody = "IPFS Daemon Error: " <> displayLazyBS msg}

instance ToServerError Peer.Error where
  toServerError = \case
    Peer.DecodeFailure _ -> err500 { errBody = "Peer list decode error" }
    Peer.CannotConnect _ -> err503 { errBody = "Unable to connect to peer" }
    Peer.UnknownErr    _ -> err500 { errBody = "Unknown peer list error" }

instance ToServerError IPFS.Linearization where
  toServerError _ = err500 { errBody = "Unable to linearize IPFS result" }

instance ToServerError (OpenUnion '[]) where
  toServerError = absurdUnion

instance (ToServerError a, ToServerError (OpenUnion as)) => ToServerError (OpenUnion (a ': as)) where
  toServerError err = openUnion toServerError toServerError err

instance Display (AlreadyExists entity) => ToServerError (AlreadyExists entity) where
  toServerError alreadyExists = Error.withMessage alreadyExists err409

instance ToServerError (ActionNotAuthorized entity) where
  toServerError _ = err401

instance ToServerError InvalidURL where
  toServerError err = err422 { errBody = displayLazyBS err }

instance Display (NotFound entity) => ToServerError (NotFound entity) where
  toServerError err = err404 { errBody }
    where
      errBody = Lazy.fromStrict . encodeUtf8 $ textDisplay err

instance ToServerError Username.Invalid where
  toServerError Username.Invalid =
    err422 { errBody = displayLazyBS Username.Invalid }

instance ToServerError Web.Auth.Error where
  toServerError err = Error.withMessage err Server.err401

instance ToServerError JWT.Header.Error where
  toServerError = \case
    UnsupportedAlgorithm -> err422 { errBody = displayLazyBS UnsupportedAlgorithm }
    UnsupportedVersion   -> err404 { errBody = displayLazyBS UnsupportedVersion   }

instance ToServerError JWT.Resolver.Error where
  toServerError = \case
    err@(CannotResolve _ _) -> err504 { errBody = displayLazyBS err }
    err@(InvalidJWT _)      -> err422 { errBody = displayLazyBS err }

instance ToServerError JWT.Signature.Error where
  toServerError err = err422 { errBody = displayLazyBS err }

instance ToServerError JWT.Proof.Error where
  toServerError = \case
    ResolverError err     -> toServerError err
    ScopeOutOfBounds      -> err401 { errBody = displayLazyBS ScopeOutOfBounds      }
    PotencyEscelation     -> err401 { errBody = displayLazyBS PotencyEscelation     }
    TimeNotSubset         -> err422 { errBody = displayLazyBS TimeNotSubset         }
    InvalidSignatureChain -> err422 { errBody = displayLazyBS InvalidSignatureChain }

instance ToServerError JWT.Claims.Error where
  toServerError = \case
    ProofError    err -> toServerError err
    IncorrectReceiver -> err401 { errBody = displayLazyBS IncorrectReceiver }
    Expired           -> err401 { errBody = displayLazyBS Expired }
    TooEarly          -> err401 { errBody = displayLazyBS TooEarly }

instance ToServerError JWT.Error where
  toServerError = \case
    ParseError         -> err400 { errBody = displayLazyBS ParseError }
    HeaderError    err -> toServerError err
    ClaimsError    err -> toServerError err
    SignatureError err -> toServerError err
