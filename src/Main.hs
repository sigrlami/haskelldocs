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
import Control.Applicative
import Control.Concurrent
import Control.Lens
import Snap
import Snap.Snaplet.Heist
import Snap.Snaplet.Session
import Snap.Snaplet.Auth
import Snap.Snaplet.Auth.Backends.SqliteSimple
import Snap.Snaplet.Session.Backends.CookieSession
import Snap.Snaplet.SqliteSimple
import Snap.Util.FileServe
import Heist.SpliceAPI
import Application
import Db
import Data.Time
import Text.Read
import qualified Heist.Interpreted as I
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import qualified Data.ByteString as BS

--------------------------------------------------------------------------------    

-- | Build a new Docs snaplet.
docsInit :: SnapletInit Docs Docs
docsInit = 
  makeSnaplet "HaskellDocs" 
              "Community-powered documentation" 
              Nothing 
  $ do
      h <- nestSnaplet "heist" heist $
             heistInit "templates"
      d <- nestSnaplet "db" db sqliteInit 
      s <- nestSnaplet "sess"  sess  $
             initCookieSessionManager "site_key.txt" "sess" (Just 3600)
      a <- nestSnaplet "auth"  auth  $
             initSqliteAuth sess d
      
      let c = sqliteConn $ d ^# snapletValue
      liftIO $ withMVar c $ \conn -> Db.createTables conn

      addRoutes routes
      addAuthSplices h auth
      return $ Docs { _heist = h, _sess = s, _auth = a , _db=d}
             
main :: IO ()
main = do
  (_, site, _) <- runSnaplet Nothing docsInit
  quickHttpServe site

