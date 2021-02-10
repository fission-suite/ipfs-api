-- | Username validation

module Fission.User.Username.Validation
  ( isValid
  , isUsernameChar
  ) where

import qualified Data.Char       as Char
import qualified RIO.Text        as Text

import           Fission.Prelude

-- $setup
-- >>> :set -XOverloadedStrings

-- | Confirm that a username is valid
--
-- >>> isValid "simple"
-- True
--
-- >>> isValid "happy-name"
-- True
--
-- Blocklisted words are not allowed
--
-- >>> isValid "recovery"
-- False
--
-- They're not case sensitive
--
-- >>> isValid "reCovErY"
-- False
--
-- They can't contain uppercase characters at all
--
-- >>> isValid "hElLoWoRlD"
-- False
--
-- Nor are various characters
--
-- >>> isValid "under_score"
-- False
--
-- >>> isValid "plus+plus"
-- False
--
-- >>> isValid "-startswith"
-- False
--
-- >>> isValid "endswith-"
-- False
--
-- >>> isValid "with.space"
-- False
--
-- >>> isValid "with.dot"
-- False
--
-- >>> isValid "has.two.dots"
-- False
--
-- >>> isValid "name&with#chars"
-- False
isValid :: Text -> Bool
isValid rawUsername =
  all (== True) preds
  where
    preds :: [Bool]
    preds = [ okChars
            , not blank
            , not startsWithHyphen
            , not endsWithHyphen
            , not inBlocklist
            ]

    blank = Text.null username

    inBlocklist = elem username blocklist
    okChars     = Text.all isUsernameChar username

    startsWithHyphen = Text.isPrefixOf "-" username
    endsWithHyphen   = Text.isSuffixOf "-" username

    username = Text.toLower rawUsername

isUsernameChar :: Char -> Bool
isUsernameChar c =
     Char.isAsciiLower c
  || Char.isDigit      c
  || c == '-'

-- | Dangerous potential usernames
blocklist :: [Text]
blocklist =
  [ "ipfs"
  , "ipns"
  , "did"
  , "id"
  , "identity"
  , "drive"
  , ".htaccess"
  , "htaccess"
  , ".htpasswd"
  , "htpasswd"
  , ".well-known"
  , "well-known"
  , "400"
  , "401"
  , "403"
  , "404"
  , "405"
  , "406"
  , "407"
  , "408"
  , "409"
  , "410"
  , "411"
  , "412"
  , "413"
  , "414"
  , "415"
  , "416"
  , "417"
  , "421"
  , "422"
  , "423"
  , "424"
  , "426"
  , "428"
  , "429"
  , "431"
  , "500"
  , "501"
  , "502"
  , "503"
  , "504"
  , "505"
  , "506"
  , "507"
  , "508"
  , "509"
  , "510"
  , "511"
  , "_domainkey"
  , "about"
  , "about-us"
  , "abuse"
  , "access"
  , "account"
  , "accounts"
  , "ad"
  , "add"
  , "admin"
  , "administration"
  , "administrator"
  , "ads"
  , "ads.txt"
  , "advertise"
  , "advertising"
  , "aes128-ctr"
  , "aes128-gcm"
  , "aes192-ctr"
  , "aes256-ctr"
  , "aes256-gcm"
  , "affiliate"
  , "affiliates"
  , "ajax"
  , "alert"
  , "alerts"
  , "alpha"
  , "amp"
  , "analytics"
  , "api"
  , "app"
  , "app-ads.txt"
  , "apps"
  , "asc"
  , "assets"
  , "atom"
  , "auth"
  , "authentication"
  , "authorize"
  , "autoconfig"
  , "autodiscover"
  , "avatar"
  , "backup"
  , "banner"
  , "banners"
  , "bbs"
  , "beta"
  , "billing"
  , "billings"
  , "blog"
  , "blogs"
  , "board"
  , "bookmark"
  , "bookmarks"
  , "broadcasthost"
  , "business"
  , "buy"
  , "cache"
  , "calendar"
  , "campaign"
  , "captcha"
  , "careers"
  , "cart"
  , "cas"
  , "categories"
  , "category"
  , "cdn"
  , "cgi"
  , "cgi-bin"
  , "chacha20-poly1305"
  , "change"
  , "channel"
  , "channels"
  , "chart"
  , "chat"
  , "checkout"
  , "clear"
  , "client"
  , "close"
  , "cloud"
  , "cms"
  , "com"
  , "comment"
  , "comments"
  , "community"
  , "compare"
  , "compose"
  , "config"
  , "connect"
  , "contact"
  , "contest"
  , "cookies"
  , "copy"
  , "copyright"
  , "count"
  , "cp"
  , "cpanel"
  , "create"
  , "crossdomain.xml"
  , "css"
  , "curve25519-sha256"
  , "customer"
  , "customers"
  , "customize"
  , "dashboard"
  , "db"
  , "deals"
  , "debug"
  , "delete"
  , "desc"
  , "destroy"
  , "dev"
  , "developer"
  , "developers"
  , "diffie-hellman-group-exchange-sha256"
  , "diffie-hellman-group14-sha1"
  , "disconnect"
  , "discuss"
  , "dns"
  , "dns0"
  , "dns1"
  , "dns2"
  , "dns3"
  , "dns4"
  , "docs"
  , "documentation"
  , "domain"
  , "download"
  , "downloads"
  , "downvote"
  , "draft"
  , "drop"
  , "ecdh-sha2-nistp256"
  , "ecdh-sha2-nistp384"
  , "ecdh-sha2-nistp521"
  , "edit"
  , "editor"
  , "email"
  , "enterprise"
  , "error"
  , "errors"
  , "event"
  , "events"
  , "example"
  , "exception"
  , "exit"
  , "explore"
  , "export"
  , "extensions"
  , "false"
  , "family"
  , "faq"
  , "faqs"
  , "favicon.ico"
  , "features"
  , "feed"
  , "feedback"
  , "feeds"
  , "file"
  , "files"
  , "filter"
  , "follow"
  , "follower"
  , "followers"
  , "following"
  , "fonts"
  , "forgot"
  , "forgot-password"
  , "forgotpassword"
  , "form"
  , "forms"
  , "forum"
  , "forums"
  , "friend"
  , "friends"
  , "ftp"
  , "get"
  , "git"
  , "go"
  , "graphql"
  , "group"
  , "groups"
  , "guest"
  , "guidelines"
  , "guides"
  , "head"
  , "header"
  , "help"
  , "hide"
  , "hmac-sha"
  , "hmac-sha1"
  , "hmac-sha1-etm"
  , "hmac-sha2-256"
  , "hmac-sha2-256-etm"
  , "hmac-sha2-512"
  , "hmac-sha2-512-etm"
  , "home"
  , "host"
  , "hosting"
  , "hostmaster"
  , "htpasswd"
  , "http"
  , "httpd"
  , "https"
  , "humans.txt"
  , "icons"
  , "images"
  , "imap"
  , "img"
  , "import"
  , "index"
  , "info"
  , "insert"
  , "internal"
  , "investors"
  , "invitations"
  , "invite"
  , "invites"
  , "invoice"
  , "is"
  , "isatap"
  , "issues"
  , "it"
  , "jobs"
  , "join"
  , "js"
  , "json"
  , "keybase.txt"
  , "learn"
  , "legal"
  , "license"
  , "licensing"
  , "like"
  , "limit"
  , "live"
  , "load"
  , "local"
  , "localdomain"
  , "localhost"
  , "lock"
  , "login"
  , "logout"
  , "lost-password"
  , "m"
  , "mail"
  , "mail0"
  , "mail1"
  , "mail2"
  , "mail3"
  , "mail4"
  , "mail5"
  , "mail6"
  , "mail7"
  , "mail8"
  , "mail9"
  , "mailer-daemon"
  , "mailerdaemon"
  , "map"
  , "marketing"
  , "marketplace"
  , "master"
  , "me"
  , "media"
  , "member"
  , "members"
  , "message"
  , "messages"
  , "metrics"
  , "mis"
  , "mobile"
  , "moderator"
  , "modify"
  , "more"
  , "mx"
  , "mx1"
  , "my"
  , "net"
  , "network"
  , "new"
  , "news"
  , "newsletter"
  , "newsletters"
  , "next"
  , "nil"
  , "no-reply"
  , "nobody"
  , "noc"
  , "none"
  , "noreply"
  , "notification"
  , "notifications"
  , "ns"
  , "ns0"
  , "ns1"
  , "ns2"
  , "ns3"
  , "ns4"
  , "ns5"
  , "ns6"
  , "ns7"
  , "ns8"
  , "ns9"
  , "null"
  , "oauth"
  , "oauth2"
  , "offer"
  , "offers"
  , "online"
  , "openid"
  , "order"
  , "orders"
  , "overview"
  , "owa"
  , "owner"
  , "page"
  , "pages"
  , "partners"
  , "passwd"
  , "password"
  , "pay"
  , "payment"
  , "payments"
  , "photo"
  , "photos"
  , "pixel"
  , "plans"
  , "plugins"
  , "policies"
  , "policy"
  , "pop"
  , "pop3"
  , "popular"
  , "portal"
  , "portfolio"
  , "post"
  , "postfix"
  , "postmaster"
  , "poweruser"
  , "preferences"
  , "premium"
  , "press"
  , "previous"
  , "pricing"
  , "print"
  , "privacy"
  , "privacy-policy"
  , "private"
  , "prod"
  , "product"
  , "production"
  , "profile"
  , "profiles"
  , "project"
  , "projects"
  , "public"
  , "purchase"
  , "put"
  , "quota"
  , "recover"
  , "recovery"
  , "redirect"
  , "reduce"
  , "refund"
  , "refunds"
  , "register"
  , "registration"
  , "remove"
  , "replies"
  , "reply"
  , "report"
  , "request"
  , "request-password"
  , "reset"
  , "reset-password"
  , "response"
  , "return"
  , "returns"
  , "review"
  , "reviews"
  , "robots.txt"
  , "root"
  , "rootuser"
  , "rsa-sha2-2"
  , "rsa-sha2-512"
  , "rss"
  , "rules"
  , "sales"
  , "save"
  , "script"
  , "sdk"
  , "search"
  , "secure"
  , "security"
  , "select"
  , "services"
  , "session"
  , "sessions"
  , "settings"
  , "setup"
  , "share"
  , "shift"
  , "shop"
  , "signin"
  , "signup"
  , "site"
  , "sitemap"
  , "sites"
  , "smtp"
  , "sort"
  , "source"
  , "sql"
  , "ssh"
  , "ssh-rsa"
  , "ssl"
  , "ssladmin"
  , "ssladministrator"
  , "sslwebmaster"
  , "stage"
  , "staging"
  , "stat"
  , "static"
  , "statistics"
  , "stats"
  , "status"
  , "store"
  , "style"
  , "styles"
  , "stylesheet"
  , "stylesheets"
  , "subdomain"
  , "subscribe"
  , "sudo"
  , "super"
  , "superuser"
  , "support"
  , "survey"
  , "sync"
  , "sysadmin"
  , "system"
  , "tablet"
  , "tag"
  , "tags"
  , "team"
  , "telnet"
  , "terms"
  , "terms-of-use"
  , "test"
  , "testimonials"
  , "theme"
  , "themes"
  , "today"
  , "tools"
  , "topic"
  , "topics"
  , "tour"
  , "training"
  , "translate"
  , "translations"
  , "trending"
  , "trial"
  , "true"
  , "umac-128"
  , "umac-128-etm"
  , "umac-64"
  , "umac-64-etm"
  , "undefined"
  , "unfollow"
  , "unlike"
  , "unsubscribe"
  , "update"
  , "upgrade"
  , "usenet"
  , "user"
  , "username"
  , "users"
  , "uucp"
  , "var"
  , "verify"
  , "video"
  , "view"
  , "void"
  , "vote"
  , "vpn"
  , "webmail"
  , "webmaster"
  , "website"
  , "widget"
  , "widgets"
  , "wiki"
  , "wpad"
  , "write"
  , "www"
  , "www-data"
  , "www1"
  , "www2"
  , "www3"
  , "www4"
  , "you"
  , "yourname"
  , "yourusername"
  , "zlib"
  ]
