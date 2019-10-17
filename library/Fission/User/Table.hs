module Fission.User.Table
  ( name
  , users
  ) where

import Database.Selda

import qualified Fission.Platform.Heroku.AddOn as Heroku
import qualified Fission.Storage.Table  as Table
import           Fission.User.Types

-- | The name of the 'users' table
name :: Table.Name User
name = "users"

-- | The 'User' table
users :: Table User
users = Table.lensPrefixed (Table.name name)
  [ #_userID        :- autoPrimary
  , #_username      :- index
  , #_username      :- unique
  , #_active        :- index
  , #_secretDigest  :- index
  , #_secretDigest  :- unique
  , #_herokuAddOnID :- foreignKey Heroku.addOns Heroku.addOnID'
  ]
