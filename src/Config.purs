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

-- read config from JS environment
-- note that this relies on config being constant
-- you can put raw values in here instead if you want

module Config where

import Control.Monad.Eff
import Data.DOM.Simple.Types (HTMLWindow ())

foreign import siteId
    "var siteId = site_id" :: String

foreign import apiHost
    "var apiHost = api_host" :: String

foreign import getPath
    "function getPath(win) { \
    \   return function () { \
    \       return win.location.pathname; \
    \   } \
    \}" :: forall t. HTMLWindow -> Eff t String
