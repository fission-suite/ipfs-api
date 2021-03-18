module Fission.Test.Web.Server.Auth.Token.JWT (spec) where

import qualified Data.Aeson                                        as JSON
import qualified Data.ByteString.Lazy.Char8                        as Lazy.Char8
import qualified RIO.ByteString.Lazy                               as Lazy

import           Fission.Web.Auth.Token.JWT

import qualified Fission.Test.Web.Server.Auth.Token.JWT.Validation as Validation
import           Fission.Test.Web.Server.Prelude

import qualified Fission.Test.Web.Server.Auth.Token.JWT.Proof      as Proof

spec :: Spec
spec =
  describe "Fission.Web.Auth.Token.JWT" $ parallel do
    Proof.spec
    Validation.spec

    describe "serialization" $ parallel do
      itsProp' "serialized is isomorphic to ADT" \(jwt :: JWT) ->
        JSON.eitherDecode (JSON.encode jwt) `shouldBe` Right jwt

      describe "format" $ parallel do
        itsProp' "contains exactly two '.'s" \(jwt :: JWT) ->
          jwt
            |> JSON.encode
            |> Lazy.count (fromIntegral $ ord '.')
            |> shouldBe 2

        itsProp' "contains only valid base64 URL characters" \(jwt :: JWT) ->
          let
            encoded = JSON.encode jwt
          in
            encoded
              |> Lazy.take (Lazy.length encoded - 2)
              |> Lazy.drop 2
              |> Lazy.filter (not . isValidChar)
              |> shouldBe mempty

isValidChar :: Word8 -> Bool
isValidChar w8 = Lazy.elem w8 validB64URLChars

validB64URLChars :: Lazy.ByteString
validB64URLChars = Lazy.Char8.pack chars
  where
    chars :: [Char]
    chars = ['a'..'z']
         <> ['A'..'Z']
         <> ['0'..'9']
         <> ['_', '-', '.']