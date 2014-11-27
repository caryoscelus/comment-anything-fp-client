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

-- | Generate required HTML
module HTML where

import Data.Foldable
import Data.Array

import Text.Smolder.HTML (div, h2, p, form, input, br, textarea)
import Text.Smolder.HTML.Attributes (className, type', value)
import Text.Smolder.Markup (text, attribute, (!), Markup())
import Text.Smolder.Renderer.String (render)

import Post

renderPost :: Post -> String
renderPost (Post post) = render $
    div ! className "comment" $ do
        h2 $ text post.nick
        p $ text post.text

renderPosts :: Posts -> String
renderPosts (Posts posts) = mconcat $ map renderPost posts

renderForm :: String
renderForm = render $
    div ! attribute "id" "comment_input_form" $ do
        form $ do
            text "Nick:"
            input ! attribute "id" "comment_input_nick" ! type' "text"
            br
            text "Message:"
            br
            textarea ! attribute "id" "comment_input_text" $ text ""
            br
            input ! type' "button" ! attribute "onClick" "PS.Comments.postComment()" ! value "Send!"

renderFull :: Posts -> String
renderFull p = renderPosts p ++ renderForm
