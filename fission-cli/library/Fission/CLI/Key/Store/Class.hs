module Fission.CLI.Key.Store.Class (MonadKeyStore (..)) where

import qualified RIO.ByteString.Lazy                          as Lazy
import           RIO.FilePath                                 ((</>))
import qualified RIO.Text                                     as Text

import           Data.Binary                                  as Binary
import           Data.ByteArray                               as ByteArray

import           Crypto.Error
import qualified Crypto.PubKey.Ed25519                        as Ed25519
import qualified Crypto.PubKey.RSA                            as RSA
import           Crypto.Random.Types

import           Fission.Prelude

import           Fission.CLI.Environment.Class
import           Fission.CLI.Environment.Path

import           Fission.CLI.Key.Store.Types
import           Fission.Key.Error                            as Key

import           Fission.Internal.Orphanage.Ed25519.SecretKey ()
import           Fission.Internal.Orphanage.RSA2048.Private   ()

class
  ( MonadRandom m
  , ByteArrayAccess (SecretKey keyRole)
  )
  => MonadKeyStore m keyRole where
  type SecretKey keyRole
  type PublicKey keyRole

  getPath  :: Proxy keyRole -> m FilePath
  toPublic :: Proxy keyRole -> SecretKey keyRole -> m (PublicKey keyRole)
  generate :: Proxy keyRole -> m (SecretKey keyRole)
  parse    :: Proxy keyRole -> ScrubbedBytes -> m (Either Key.Error (SecretKey keyRole))

instance
  ( MonadIO          m
  , MonadRandom      m
  , MonadEnvironment m
  )
  => MonadKeyStore m SigningKey where
    type SecretKey SigningKey = Ed25519.SecretKey
    type PublicKey SigningKey = Ed25519.PublicKey

    toPublic _pxy = pure . Ed25519.toPublic
    generate _pxy = Ed25519.generateSecretKey

    getPath _pxy = do
      path <- globalKeyDir
      return $ path </> "machine_id.ed25519"

    parse _pxy bs =
      return case Ed25519.secretKey bs of
        CryptoPassed sk  -> Right sk
        CryptoFailed err -> Left . Key.ParseError . Text.pack $ show err

instance
  ( MonadRandom      m
  , MonadEnvironment m
  )
  => MonadKeyStore m ExchangeKey where
    type SecretKey ExchangeKey = RSA.PrivateKey
    type PublicKey ExchangeKey = RSA.PublicKey

    toPublic _pxy = pure . RSA.private_pub
    generate _pxy = snd <$> RSA.generate 2048 65537

    getPath _pxy = do
      path <- globalKeyDir
      return $ path </> "exchange.rsa2048"

    parse    _pxy scrubbed =
      return case Binary.decodeOrFail (Lazy.pack $ ByteArray.unpack scrubbed) of
        Left  (_, _, msg) -> Left . Key.ParseError $ Text.pack msg
        Right (_, _, key) -> Right key
