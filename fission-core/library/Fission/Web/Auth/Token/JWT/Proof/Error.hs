module Fission.Web.Auth.Token.JWT.Proof.Error (Error (..)) where

import           Fission.Prelude

import qualified Fission.Web.Auth.Token.JWT.Resolver as JWT.Resolver

data Error
  = InvalidSignatureChain
  | ScopeOutOfBounds
  | PotencyEscelation
  | TimeNotSubset
  | MissingExpectedFact
  | ResolverError JWT.Resolver.Error
  deriving (Show, Eq, Exception)

instance Display Error where
  display = \case
    InvalidSignatureChain -> "Invalid signature chain"
    ScopeOutOfBounds      -> "Path scope not in delegated rights"
    PotencyEscelation     -> "Potency escelation"
    TimeNotSubset         -> "Time bounds are not a subset"
    MissingExpectedFact   -> "Expected fact not present"
    ResolverError resErr  -> "Unable to resolve CID proof: " <> display resErr
