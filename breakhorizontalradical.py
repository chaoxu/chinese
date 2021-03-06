#!/usr/bin/python
# coding=utf-8
import sys
from cjklib import characterlookup

def get_first(list):
   return list[0]

twocomp   = u'⿰'
threecomp = u'⿲'
s         = u"郦橙"

if len(sys.argv)>1 :
  s = sys.argv[1].decode('UTF-8')

cjk = characterlookup.CharacterLookup('C')

result = ""
for c in s:
  t = cjk.getDecompositionEntries(c)
  w = ""+c;
  for l in t:
    v = l.pop(0)
    if (v==twocomp and len(l) == 2) or (v==threecomp and len(l)==3):
      w = ''.join(map(get_first,l));
      break;
  result+=w

print result
