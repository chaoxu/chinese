import Data.Monoid hiding (Any)

data Gender = Male | Female | Unknown deriving (Eq, Show, Ord)
data Birth = Younger | Older | Any deriving (Eq, Show, Ord)
data Relation = Self | Spouse | Parent Gender |
                Child Gender | Sibling Gender Birth |
                Composed [Relation] | Gender Gender | Birth Birth
  deriving (Show, Eq, Ord)

chineseRelation x
 | Composed xs <- x = init $ concat $ zipWith (++) (map chineseRelation xs)
                                              (repeat "的")
 | x == Sibling Male Older = "長兄"
 | x == Sibling Male Younger = "幼弟"
 | x == Sibling Male Any = "兄弟"
 | x == Sibling Female Older = "長姊"
 | x == Sibling Female Younger = "幼妹"
 | x == Sibling Female Any = "姊妹"
 | x == Sibling Unknown Any = "同胞兄妹"
 | x == Self = "自己"
 | x == Child Male = "兒子"
 | x == Child Female = "女兒"
 | x == Child Unknown = "孩子"
 | x == Parent Male = "父親"
 | x == Parent Female = "母親"
 | x == Parent Unknown = "父母"
 | x == Spouse = "配偶"

self = Self

child x = x <> (Child Unknown)
parent x = x <> (Parent Unknown)
spouse x = x <> (Spouse)
sibling x = x <> (Sibling Unknown Any)

setBirth b (Sibling x _) = (Sibling x b)
setBirth b (Composed xs) = setBirth b (last xs)
setBirth _ x = x

younger = setBirth Younger
older = setBirth Older
clearBirth = setBirth Any

setGender g (Parent _) = (Parent g )
setGender g (Child _) = (Child g )
setGender g (Sibling _ x) = (Sibling g  x)
setGender g (Composed xs) = setGender g (last xs)
setGender _ x = x

male = setGender Male
female = setGender Female
clearGender = setGender Unknown

genderFlip x
 | x == Male = Female
 | x == Female = Male
 | otherwise = Unknown

isComposed (Composed _) = True
isComposed _ = False

decompose (Composed x) = x
decompose _ = []

--set of interesting functions
brother = male . sibling
sister = female . sibling

youngerBrother = younger . brother
youngerSister = younger . sister

olderBrother = older . brother
olderSister = older . sister


-- We try to do some primarily reductions
instance Monoid Relation where
  mempty = Self

-- Self is the identity
  mappend Self x = x
  mappend x Self = x

-- Child
  mappend (Child x) (Sibling a Any) = Child a

-- Parent
  mappend (Parent _) (Child x) = Sibling x Any
  mappend (Parent a) Spouse    = Parent (genderFlip a)

-- Spouse
  mappend Spouse (Child a) = Child a
  mappend Spouse Spouse    = Self

-- Sibling
  mappend (Sibling _ _) (Parent x) = Parent x
  mappend (Sibling _ _) (Sibling b Any) = Sibling b Any
  mappend (Sibling _ Older) (Sibling b Older) = Sibling b Older
  mappend (Sibling _ Older) (Sibling b Younger) = Sibling b Any
  mappend (Sibling _ Younger) (Sibling b Younger) = Sibling b Younger
  mappend (Sibling _ Younger) (Sibling b Older) = Sibling b Any

-- Genders and birth are commutative
  mappend x (Gender y)
   | y == Male   = male x
   | y == Female = female x
   | otherwise   = clearGender x

-- Apply births
  mappend x (Birth y)
   | y == Younger = younger x
   | y == Older   = older x
   | otherwise    = clearBirth x

-- Apply Composed Relations
  mappend (Composed xs) (Composed ys) = mconcat ([Composed xs]++ys)
  mappend (Composed xs) t
   | isComposed d = Composed ((init xs) ++ decompose d)
   | otherwise    = Composed ((init xs) ++ [d])
    where d = mappend (last xs) t
  mappend t (Composed xs) = mconcat ([t]++xs)
-- Remaining
  mappend a b = Composed [a,b]
