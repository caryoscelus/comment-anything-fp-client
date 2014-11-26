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

module Post where

import Text.Smolder.HTML (div, h2, p)
import Text.Smolder.HTML.Attributes (className)
import Text.Smolder.Markup (text, (!), Markup())
import Text.Smolder.Renderer.String (render)

import Data.JSON
import qualified Data.Map as M
import Data.Array
import Data.Either
import Data.Maybe
import Data.Foldable
import Data.Traversable

import Util

data Post = Post
    { nick :: String
    , text :: String
    }

data Posts = Posts [Post]

instance showPosts :: Show Posts where
    show (Posts posts) = show posts

instance showPost :: Show Post where
    show _ = "post"

instance postFromJSON :: FromJSON Post where
    parseJSON (JObject obj) = do
        JString nick <- maybeFail "no nick" $ M.lookup "nick" obj
        JString text <- maybeFail "no text" $ M.lookup "text" obj
        return $ Post
            { nick : nick
            , text : text
            }
    parseJSON _ = fail "Post parse fail: should be Object"

instance postsFromJSON :: FromJSON Posts where
    parseJSON (JObject obj) = do
        JArray comments <- maybeFail "no comments" $ M.lookup "comments" obj
        cs <- traverse parseJSON comments
        return $ Posts cs
    parseJSON _ = fail "Posts parse fail: should be Object"

renderPost :: Post -> String
renderPost (Post post) = render $
    div ! className "post" $ do
        h2 $ text post.nick
        p $ text post.text

renderPosts :: Posts -> String
renderPosts (Posts posts) = mconcat $ map renderPost posts
