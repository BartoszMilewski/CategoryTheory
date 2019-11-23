{-# LANGUAGE GADTs #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE TypeFamilies #-}

module STLC where
  
{- From Derek Elkins

Attached is some Haskell code to compile the STLC to categorical combinators 
of a Cartesian closed category and pretty print that as executable code 
(using (&&&) from Control.Arrow). 
The Haskell code will take an extra argument corresponding to the context 
and () should suffice for any closed term. 
Prim can lead to broken generated Haskell. 
There's an extra swap that makes the generated code look ugly because 
Haskell's curry takes things in an inconvenient order. 
The code could be made to look a little nicer by defining some helpers 
e.g. "swap" and "eval = uncurry id".

-}

import Control.Arrow  -- for testing 

data Var :: [*] -> * -> * where
    Here  :: Var (a:as) a
    There :: Var as b -> Var (a:as) b

{- 
   These types are sort of backwards. 
   An STLC expression is given a type
   and that type is backpropagated. From
     Lam (Var Here) :: STLC '[] (a -> a)
   which encodes
     \x:a -> x
   we can deduce that (Var Here) is
     STLC (a:'[]) a
   which was constructed using
     Here :: Var (a:'[]) a
   
-}

data STLC :: [*] -> * -> * where
    Var  :: Var v a -> STLC v a
    App  :: STLC v (a -> b) -> STLC v a -> STLC v b
    Lam  :: STLC (a:v) b -> STLC v (a -> b)
    Prj1 :: STLC v (a, b) -> STLC v a
    Prj2 :: STLC v (a, b) -> STLC v b
    Pair :: STLC v a -> STLC v b -> STLC v (a, b)
    Unit :: STLC v ()
    Prim :: String -> STLC v a

data CCC :: * -> * -> * where
      -- ! :: a -> ()
    Bang :: CCC a ()
      -- π₁ :: (a, b) -> a
    Pi1 :: CCC (a, b) a
      -- π₂ :: (a, b) -> a
    Pi2 :: CCC (a, b) b
      -- tuple :: (c -> a) -> (c -> b) -> (c -> (a, b))
    Tuple :: CCC c a -> CCC c b -> CCC c (a, b)
      -- eval :: (a -> b, a) -> b
    Eval :: CCC (a -> b, a) b
      -- curry :: ((a, b) -> c) -> (a -> (b -> c))
    Curry :: CCC (a, b) c -> CCC a (b -> c)
      -- id :: a -> a
    Id :: CCC a a
      -- ∘ :: (b -> c) -> (a -> b) -> (a -> c)
    O :: CCC b c -> CCC a b -> CCC a c
      -- primitive
    Arr :: String -> CCC a b

instance Show (CCC a b) where
    showsPrec _ Bang = ("(const ())"++)
    showsPrec _ Pi1 = ("fst"++)
    showsPrec _ Pi2 = ("snd"++)
    showsPrec n (Tuple x y) = showParen (n > 0) $ showsPrec 1 x . (" &&& "++) . showsPrec 1 y
    showsPrec _ Eval = ("(uncurry ($))"++)
    showsPrec n (Curry f) = showParen (n > 0) $ ("curry "++) . showsPrec 1 f
    showsPrec _ Id = ("id"++)
    showsPrec n (f `O` g) = showParen (n > 0) $ showsPrec 1 f . (" . "++) . showsPrec 1 g
    showsPrec _ (Arr s) = ("const "++) . (s++)

-- Turns a list of types into a (nested) tuple type
type family Context (v :: [*]) :: * where
    Context '[] = ()
    Context (t:ts) = (t, Context ts)

-- Produces an arrow from context to a
compile :: STLC v a -> CCC (Context v) a  
  
compile (Var v) = lookupVar v
compile (App f x) = Eval `O` Tuple (compile f) (compile x)
compile (Lam f) = Curry (compile f `O` swap)
    where swap = Tuple Pi2 Pi1
compile (Prj1 p) = Pi1 `O` compile p
compile (Prj2 p) = Pi2 `O` compile p
compile (Pair x y) = Tuple (compile x) (compile y)
compile Unit = Bang
compile (Prim s) = Arr s

-- returns an arrow that is a composition of Pi1 after zero or more Pi2s
lookupVar :: Var v a -> CCC (Context v) a
lookupVar Here = Pi1                      -- Here  :: Var (a:as) a
lookupVar (There v) = lookupVar v `O` Pi2 -- `O` is composition

-- \x -> x
example1 :: forall a. CCC () (a -> a)
example1 = compile (Lam (Var Here) :: STLC '[] (a -> a))

tuple :: (a -> b) -> (a -> b') -> (a -> (b, b'))
tuple f g = \a -> (f a, g a)

f1 :: a -> b -> b
f1 = curry (fst . swap)

-- \x y -> x + y
-- \x (\ y -> (+ x) y)
ex2 :: STLC '[] (Int -> Int -> Int)
ex2 = Lam 
          (Lam 
               (App 
                    (App (Prim "(+)") 
                         (Var (There Here))
                    ) 
                    (Var Here)
               )
          ) 
{-
    Lam  :: STLC (Int:'[]) (Int -> Int)      -> STLC '[] (Int -> (Int -> Int))
      Lam  :: STLC (Int:Int:'[]) Int         -> STLC (Int:'[]) (Int -> Int)
        App  :: STLC (Int:Int:'[]) (a -> Int) 
             -> STLC (Int:Int:'[]) a         -> STLC (Int:Int:'[]) Int
          App  :: STLC (Int:Int:'[]) (a -> (a -> Int))
               -> STLC (Int:Int:'[]) a       -> STLC (Int:Int:'[]) (a -> Int)
             Prim :: "(+)" -> STLC (Int:Int:'[]) (a -> (a -> Int))
             Var  :: Var (Int:Int:'[]) a     -> STLC (Int:Int:'[]) a
                There :: Var (Int:'[]) a     -> Var (Int:Int:'[]) a
                  Here  :: (Int:'[]) a     [This unifies a with Int]
          Var  :: Var (Int:Int:'[]) a        -> STLC (Int:Int:'[]) a
             Here  :: Var (Int:Int:'[]) a. [This also unifies a with Int]
-}  

example2 :: forall a. CCC () (Int -> Int -> Int)
example2 = compile ex2

eval = uncurry id
swap = snd &&& fst

f2 :: Num b => a -> b -> b -> b
f2 = curry ((curry ((eval . ((eval . (const (+) &&& (fst . snd))) &&& fst)) . 
       swap)) . 
       swap)

main = print example1
