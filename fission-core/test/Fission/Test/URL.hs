module Fission.Test.URL (spec) where

import           Fission.Test.Prelude

import qualified Fission.Test.URL.Validation as URL.Validation

spec :: Spec
spec =
  describe "URL" do
    URL.Validation.spec
