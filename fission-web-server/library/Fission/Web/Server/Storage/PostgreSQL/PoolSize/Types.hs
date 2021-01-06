module Fission.Web.Server.Storage.PostgreSQL.PoolSize.Types (PoolSize (..)) where

import           Fission.Prelude

newtype PoolSize = PoolSize { connCount :: Natural }
  deriving (Show, Eq)
