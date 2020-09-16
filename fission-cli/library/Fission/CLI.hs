module Fission.CLI (cli, interpret) where

import qualified Crypto.PubKey.Ed25519                          as Ed25519
import           Options.Applicative

import qualified RIO.Text                                       as Text

import           Network.HTTP.Client                            as HTTP
import           Network.HTTP.Client.TLS                        as HTTP
import qualified Network.IPFS.URL.Types                         as IPFS
import           Servant.Client.Core

import           Fission.Prelude

import qualified Fission.CLI.Meta                               as Meta
import           Fission.Error

import           Fission.User.DID.Types

import           Fission.CLI.Environment                        as Env
import qualified Fission.CLI.Environment.OS                     as OS

import qualified Fission.CLI.Base.Types                         as Base
import qualified Fission.CLI.Handler                            as Handler

import qualified Fission.CLI.Handler.Setup                      as Setup

import           Fission.CLI.Parser                             as CLI
import           Fission.CLI.Parser.Command.Setup.Types         as Setup
import           Fission.CLI.Parser.Command.Types
import           Fission.CLI.Parser.Command.User.Types
import           Fission.CLI.Parser.Types                       as Parser
import           Fission.CLI.Parser.Verbose.Types

import qualified Fission.CLI.App                                as App
import           Fission.CLI.Types

import           Fission.Internal.Orphanage.Yaml.ParseException ()

type Errs
   = OS.Unsupported
  ': AlreadyExists Ed25519.SecretKey
  ': OS.Unsupported
  ': ClientError
  ': App.Errs

cli :: MonadUnliftIO m => m (Either (OpenUnion Errs) ())
cli = do
  Parser.Options {fissionDID, fissionURL, cmd} <- liftIO $ execParser CLI.parserWithInfo

  let
    VerboseFlag isVerbose = getter cmd
    ipfsURL = IPFS.URL $ BaseUrl Https "ipfs.io" 443 ""
    Right fallbackDID = eitherDecode "\"did:key:zStEZpzSMtTt9k2vszgvCwF4fLQQSyA15W5AQ4z3AR6Bx4eFJ5crJFbuGxKmbma4\""

    rawHTTPSettings =
      case baseUrlScheme fissionURL of
        Http  -> defaultManagerSettings
        Https -> tlsManagerSettings

  httpManager <- liftIO $ HTTP.newManager rawHTTPSettings
    { managerResponseTimeout = responseTimeoutMicro 1_800_000_000 }

  processCtx <- mkDefaultProcessContext
  logOptions <- logOptionsHandle stderr isVerbose

  withLogFunc logOptions \logFunc -> do
    finalizeDID fissionDID Base.Config {serverDID = fallbackDID, ..} >>= \case
      Right serverDID -> interpret Base.Config {..} fissionURL cmd
      Left  err       -> return . Left $ include err

interpret ::
  MonadIO m
  => Base.Config
  -> BaseUrl
  -> Command
  -> m (Either (OpenUnion Errs) ())
interpret baseCfg fissionURL cmd =
  runFissionCLI baseCfg do
    logDebug . Text.pack $ show cmd

    case cmd of
      Version _ ->
        logInfo $ maybe "unknown" identity (Meta.version =<< Meta.package)

      Setup Setup.Options {forceOS} ->
        Setup.setup forceOS fissionURL

      App subCmd ->
        App.interpret baseCfg subCmd

      User subCmd ->
        case subCmd of
          Register _ -> Handler.register
          WhoAmI   _ -> Handler.whoami

finalizeDID ::
  MonadIO m
  => Maybe DID
  -> Base.Config
  -> m (Either (OpenUnion Errs) DID)
finalizeDID (Just did) _ =
  pure $ Right did

finalizeDID Nothing baseCfg =
  runFissionCLI baseCfg do
    Env {serverDID} <- Env.get
    return serverDID
