module Calculator.MegaLexer where

import Text.Megaparsec
import Text.Megaparsec.String
import qualified Text.Megaparsec.Lexer as L
import Data.Map.Strict (Map)
import Control.Monad.Reader
import Calculator.Types

type PReader = ReaderT (Map String (Int,Assoc)) Parser

sc :: PReader ()
sc = L.space (void spaceChar) (L.skipLineComment "#") (L.skipBlockComment "{" "}")

lexeme :: PReader a -> PReader a
lexeme = L.lexeme sc

symbol :: String -> PReader String
symbol = L.symbol sc

parens :: PReader a -> PReader a
parens = between (symbol "(") (symbol ")")

number :: PReader (Either Integer Double)
number = lexeme L.number

comma :: PReader String
comma = symbol ","

identifier :: PReader String
identifier = lexeme p
  where p = (:) <$> (letterChar  <|> char '_') <*> many (alphaNumChar <|> char '_')

opSymbols :: String
opSymbols = "+-/*%$^!~&|=><"

operator :: PReader String
operator = lexeme (many . oneOf $ opSymbols)

exactOper :: String -> PReader String
exactOper s = symbol s <* notFollowedBy (oneOf opSymbols)

eq :: PReader String
eq = symbol "=" <* notFollowedBy (symbol "=")