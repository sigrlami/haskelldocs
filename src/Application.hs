{-# LANGUAGE TemplateHaskell #-}

-- |
-- Module:      Main
-- Copyright:   (c) 2015 Sergey Bushnyak
-- License:     LGPL-3
-- Maintainer:  Sergey Bushnyak <sergey.bushnyak@sigrlami.eu>
-- Stability:   experimental
-- Portability: portable
--
-- Entry point for Haskell Docs web-app
-- 

module Application where

import Control.Lens
import Snap
import Snap.Snaplet.Heist
import Snap.Snaplet.Auth
import Snap.Snaplet.Session
import Snap.Snaplet.SqliteSimple    

--------------------------------------------------------------------------------    

data Docs 
  = Docs { _heist :: Snaplet (Heist Pollock)
         , _sess  :: Snaplet SessionManager
         , _auth  :: Snaplet (AuthManager Pollock)
         , _db    :: Snaplet Sqlite            
         }

makeLenses ''Docs

instance HasHeist Docs where
  heistLens = subSnaplet heist
