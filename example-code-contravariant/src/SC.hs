module SC where

import Data.Functor.Contravariant hiding ((>$<))
import Data.Functor.Contravariant.Divisible
import Data.Semigroup
import Data.Void

data Printer a = Printer { runPrinter :: a -> String }

instance Contravariant Printer where
  contramap ba (Printer as) = Printer (as . ba)

instance Divisible Printer where
  conquer = Printer (const mempty)
  divide cab (Printer as) (Printer bs) = Printer $ \c ->
    case cab c of
      (a,b) -> as a <> bs b

instance Decidable Printer where
  lose av = Printer (absurd . av)
  choose cab (Printer as) (Printer bs) = Printer $ \c ->
    case cab c of
      Left  a -> as a
      Right b -> bs b

prettyEot :: Printer (Either (Int,String) ((String, String), String))
prettyEot =
  chosen (divided int string) (divided (divided string string) string)

-- primitives
konst :: String -> Printer a
konst s = Printer (const s)

showP :: Show a => Printer a
showP = Printer show

string :: Printer String
string = Printer id

int :: Printer Int
int = showP

space :: Printer ()
space = konst " "

newline :: Printer ()
newline = konst "\n"

-- combinators
(>$<) :: Contravariant f => (b -> a) -> f a -> f b
(>$<) = contramap
infixr 3 >$<

(>*<) :: Divisible f => f a -> f b -> f (a,b)
(>*<) = divided
infixr 4 >*<

between :: Printer a -> Printer b -> String -> Printer (a,b)
between a b sep = a >*< (konst sep *< b)

(>*~<) :: Printer a -> Printer b -> Printer (a,b)
(>*~<) a b = (a >* konst " ") >*< b 

(>*|<) :: Printer a -> Printer b -> Printer (a,b)
(>*|<) a b = (a >* konst "\n") >*< b 

(>|<) :: Decidable f => f a -> f b -> f (Either a b)
(>|<) = chosen
infixr 3 >|<

(>*) :: Divisible f => f a -> f () -> f a
(>*) = divide (\a -> (a,()))
infixr 4 >*

(*<) :: Divisible f => f () -> f a -> f a
(*<) = divide (\a -> ((),a))
infixr 4 *<

-- types
data Engine = Pistons Int | Rocket

data Car = Car
  { make   :: String
  , model  :: String
  , engine :: Engine
  }

--putting it together
engineToEither :: Engine -> Either Int ()
engineToEither e = case e of
  Pistons i -> Left i
  Rocket    -> Right ()

enginePrint :: Printer Engine
enginePrint =
      engineToEither >$< konst "Pistons: " *< int
  >|< konst "Rocket"

carToTuple :: Car -> (String, (String, Engine))
carToTuple (Car ma mo e) = (ma, (mo, e))

carPrint :: Printer Car
carPrint =
      carToTuple
  >$< (konst "Make:  " *< string >* newline)
  >*< (konst "Model: " *< string >* newline)
  >*< enginePrint

car :: Car
car = Car "Toyota" "Corolla" (Pistons 4)

main :: IO ()
main = putStrLn $ runPrinter carPrint car

