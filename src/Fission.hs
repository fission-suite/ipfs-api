module Fission (fromConfig) where

import RIO

import Data.Has

-- | Get a value from the reader config
--
-- >>> newtype Example = Example Text deriving Show
-- >>> data ExCfg = ExCfg { example :: Text }
-- >>>
-- >>> :set -XMultiParamTypeClasses
-- >>> instance Has ExCfg Example where hasLens = example
-- >>>
-- >>> runRIO (ExCfg "hello world") (fromConfig :: Example)
-- Example "hello world"
fromConfig :: (MonadReader cfg m, Has a cfg) => m a
fromConfig = view hasLens
