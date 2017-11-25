{-# LANGUAGE OverloadedStrings #-}
module Main where

import Data.Text (Text)
import qualified Data.Map.Lazy as ML
import qualified Data.ByteString.Lazy as BL
import qualified Data.Text.Lazy.IO as TLIO

import Data.JSString
import GHCJS.Types (JSVal)
import GHCJS.Marshal.Pure (pToJSVal)
import qualified GHCJS.Foreign.Export as Ex

import qualified Dhall.JSON
import qualified Dhall.Core as DhC
import qualified Data.Aeson.Text as AT

main = do
  exportWindow_ "test" (pToJSVal ("I am here!"::Text))
  let (Right json) = Dhall.JSON.dhallToJSON
        $ DhC.RecordLit $ ML.fromList
          [ ("foo", DhC.BoolIf (DhC.BoolLit False) (DhC.IntegerLit 42) (DhC.IntegerLit 23))
          , ("bar", DhC.TextLit "Hello DhallJS!") ]
  -- TLIO.putStrLn $ AT.encodeToLazyText json
  print json

foreign import javascript unsafe
  "global[$1] = $2"
  exportWindow_ :: JSString -> JSVal -> IO ()


