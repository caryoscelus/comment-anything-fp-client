--
--  Copyright (C) 2014 caryoscelus
--  
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--  
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--  
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--

module Comments where

import Debug.Trace (Trace(), trace)

import Control.Monad.Eff

import Data.Maybe
import Data.Tuple

import Data.DOM.Simple.Document ()
import Data.DOM.Simple.Element (querySelector, setInnerHTML, value)
import Data.DOM.Simple.Window (globalWindow, document, location, getLocation)
import Data.DOM.Simple.Types
import Data.DOM.Simple.Events (UIEvent, UIEventType(..), addUIEventListener)

import Network.XHR (get, defaultAjaxOptions, onSuccess, Response(), getResponseText, rawBody, ajax)
import Network.XHR.Internal (Ajax(..))

import Data.JSON (decode, encode)

import Post
import Config
import HTML
import Date

main = do
    addUIEventListener LoadEvent onLoad globalWindow

onLoad :: DOMEvent -> Eff (dom :: DOM, trace :: Trace, ajax :: Ajax) Unit
onLoad _ = do
    reloadComments "loading comments.."
    return unit

reloadComments :: String -> Eff (dom :: DOM, trace :: Trace, ajax :: Ajax) Unit
reloadComments msg = do
    trace "loading comments.."
    Just posts_div <- document globalWindow >>= querySelector "#comments"
    setInnerHTML msg posts_div
    loc <- getPath globalWindow
    _ <- get defaultAjaxOptions
        { onReadyStateChange = onSuccess $ commentsUpdate posts_div
        , onTimeout = commentsTimeout posts_div
        , onError = commentsError posts_div
        } (apiCallAddr "get_comments/" ++ siteId ++ "/root" ++ loc) {}
    return unit

apiCallAddr :: forall t. String -> String
apiCallAddr api = apiHost ++ api

commentsUpdate :: HTMLElement -> Response -> Eff (dom :: DOM, trace :: Trace, ajax :: Ajax) Unit
commentsUpdate div response = do
    txt <- getResponseText response
    let postsHtml = maybe "wrong json reply" renderFull (decode txt :: Maybe Posts)
    setInnerHTML postsHtml div

commentsTimeout :: HTMLElement -> Response -> Eff (dom :: DOM, ajax :: Ajax, trace :: Trace) Unit
commentsTimeout div response = do
    setInnerHTML "timeout" div

commentsError :: HTMLElement -> Response -> Eff (dom :: DOM, ajax :: Ajax, trace :: Trace) Unit
commentsError div response = do
    setInnerHTML "error" div

-- | This is called when user clicks "Send button"
postComment :: Eff (dom :: DOM, ajax :: Ajax, trace :: Trace) Unit
postComment = do
    trace "sending message.."
    Just nick_input <- document globalWindow >>= querySelector "#comment_input_nick"
    Just text_input <- document globalWindow >>= querySelector "#comment_input_text"
    nick <- value nick_input
    text <- value text_input
    date <- getDate
    loc <- getPath globalWindow
    
    let msg = encode $ Post { nick : nick, text : text, date : date }
    _ <- ajax defaultAjaxOptions
        { method = "POST"
        , headers = [Tuple "Content-Type" "application/json"]
        , onReadyStateChange = onSuccess $ \_ -> reloadComments "Comment added, reloading.."
        , url = apiCallAddr "add_comment/" ++ siteId ++ "/root" ++ loc
        } {} (rawBody msg)
    
    return unit
